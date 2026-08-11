-- ═══════════════════════════════════════════════════════════════════════════
-- Pallet — the offer engine
--
-- Read docs/OFFER_ENGINE.md before changing anything in this file.
--
-- The one-shot rule is enforced HERE, in the database, not in the app.
-- Server Actions are a convenience layer; these functions are the contract.
-- Every one of them takes a row lock on the lot before it reads offer state,
-- because two dealers clicking Accept on two different offers at the same
-- moment is a real thing that will happen.
-- ═══════════════════════════════════════════════════════════════════════════

create table platform_settings (
  id                 boolean primary key default true check (id),
  fee_bps            integer not null default 800 check (fee_bps between 0 and 3000),
  -- Days after delivery before funds release to the dealer automatically.
  funds_hold_days    smallint not null default 7,
  -- Business days a buyer has to pay after acceptance.
  payment_due_days   smallint not null default 3
);

insert into platform_settings (id) values (true);

create sequence order_reference_seq start with 40817;

create or replace function next_order_reference() returns text
language sql volatile as $$
  select 'PLT-' || nextval('order_reference_seq')::text;
$$;

-- ─── place_offer ───────────────────────────────────────────────────────────
-- One offer per buyer per lot generation. An expiry buys exactly one retry.
-- Raises with a stable error code the UI can map to copy; see docs/COPY.md.

create or replace function place_offer(
  p_lot_id      uuid,
  p_amount_cents bigint,
  p_fulfillment fulfillment_method default 'freight',
  p_quantity    integer default null,
  p_note        text default null
) returns offers
language plpgsql security definer set search_path = public as $$
declare
  v_buyer     uuid := auth.uid();
  v_lot       lots;
  v_expired   integer;
  v_blocking  integer;
  v_expires   timestamptz;
  v_offer     offers;
begin
  if v_buyer is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  if exists (select 1 from profiles where id = v_buyer and suspended_at is not null) then
    raise exception 'ACCOUNT_SUSPENDED' using errcode = 'P0001';
  end if;

  -- Serialize every read of this lot's offer state.
  select * into v_lot from lots where id = p_lot_id for update;

  if not found then
    raise exception 'LOT_NOT_FOUND' using errcode = 'P0002';
  end if;

  if v_lot.status <> 'live' then
    raise exception 'LOT_NOT_LIVE' using errcode = 'P0003';
  end if;

  if v_lot.closes_at <= now() then
    raise exception 'LOT_CLOSED' using errcode = 'P0004';
  end if;

  if exists (select 1 from companies where id = v_lot.company_id and owner_id = v_buyer) then
    raise exception 'CANNOT_OFFER_ON_OWN_LOT' using errcode = 'P0005';
  end if;

  if p_amount_cents <= 0 then
    raise exception 'INVALID_AMOUNT' using errcode = 'P0006';
  end if;

  if v_lot.allow_partial and p_quantity is not null and p_quantity > v_lot.quantity then
    raise exception 'QUANTITY_EXCEEDS_LOT' using errcode = 'P0007';
  end if;

  if not v_lot.allow_partial and p_quantity is not null and p_quantity <> v_lot.quantity then
    raise exception 'WHOLE_LOT_ONLY' using errcode = 'P0008';
  end if;

  if p_fulfillment = 'pickup' and not v_lot.allow_pickup then
    raise exception 'PICKUP_NOT_OFFERED' using errcode = 'P0009';
  end if;

  -- Eligibility. A decided offer of any kind is terminal for this buyer on
  -- this generation. Only an expiry re-opens the door, and only once.
  select
    count(*) filter (where status = 'expired'),
    count(*) filter (where status in ('pending', 'accepted', 'declined', 'auto_declined'))
  into v_expired, v_blocking
  from offers
  where lot_id = p_lot_id and buyer_id = v_buyer and lot_generation = v_lot.generation;

  if v_blocking > 0 then
    raise exception 'ALREADY_OFFERED' using errcode = 'P0010';
  end if;

  if v_expired >= 2 then
    raise exception 'RETRY_ALREADY_USED' using errcode = 'P0011';
  end if;

  -- The offer window never outlives the lot's own deadline.
  v_expires := least(now() + make_interval(hours => v_lot.offer_window_hours), v_lot.closes_at);

  insert into offers (
    lot_id, buyer_id, lot_generation, attempt,
    amount_cents, quantity, fulfillment, note, expires_at
  ) values (
    p_lot_id, v_buyer, v_lot.generation, v_expired + 1,
    p_amount_cents,
    coalesce(p_quantity, v_lot.quantity),
    p_fulfillment,
    nullif(btrim(coalesce(p_note, '')), ''),
    v_expires
  )
  returning * into v_offer;

  insert into notifications (user_id, type, payload)
  select c.owner_id, 'offer.received',
         jsonb_build_object(
           'offer_id', v_offer.id, 'lot_id', v_lot.id, 'lot_title', v_lot.title,
           'amount_cents', v_offer.amount_cents, 'expires_at', v_offer.expires_at)
  from companies c where c.id = v_lot.company_id;

  return v_offer;
end;
$$;

-- ─── accept_offer ──────────────────────────────────────────────────────────
-- Accept one, auto-decline the rest, mark the lot sold, create the order.
-- All of it, or none of it.

create or replace function accept_offer(p_offer_id uuid) returns orders
language plpgsql security definer set search_path = public as $$
declare
  v_actor    uuid := auth.uid();
  v_offer    offers;
  v_lot      lots;
  v_company  companies;
  v_settings platform_settings;
  v_fee      bigint;
  v_order    orders;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  select * into v_offer from offers where id = p_offer_id;
  if not found then
    raise exception 'OFFER_NOT_FOUND' using errcode = 'P0012';
  end if;

  -- Lock the lot first, then re-read the offer under that lock.
  select * into v_lot from lots where id = v_offer.lot_id for update;
  select * into v_offer from offers where id = p_offer_id;

  select * into v_company from companies where id = v_lot.company_id;

  if v_company.owner_id <> v_actor then
    raise exception 'NOT_YOUR_LOT' using errcode = '42501';
  end if;

  if v_offer.status <> 'pending' then
    raise exception 'OFFER_NOT_PENDING' using errcode = 'P0013';
  end if;

  if v_offer.expires_at <= now() then
    raise exception 'OFFER_EXPIRED' using errcode = 'P0014';
  end if;

  if v_lot.status <> 'live' then
    raise exception 'LOT_NOT_LIVE' using errcode = 'P0003';
  end if;

  select * into v_settings from platform_settings where id = true;

  update offers
     set status = 'accepted', decided_at = now()
   where id = v_offer.id;

  -- The cascade. Everyone else on this generation loses, right now.
  update offers
     set status = 'auto_declined', decided_at = now()
   where lot_id = v_lot.id
     and lot_generation = v_offer.lot_generation
     and status = 'pending'
     and id <> v_offer.id;

  update lots
     set status = 'sold', sold_at = now()
   where id = v_lot.id;

  v_fee := (v_offer.amount_cents * v_settings.fee_bps) / 10000;

  insert into orders (
    reference, offer_id, lot_id, buyer_id, seller_company_id,
    amount_cents, platform_fee_cents, total_cents, fulfillment,
    status, payment_due_at
  ) values (
    next_order_reference(), v_offer.id, v_lot.id, v_offer.buyer_id, v_lot.company_id,
    v_offer.amount_cents, v_fee, v_offer.amount_cents, v_offer.fulfillment,
    'awaiting_payment', now() + make_interval(days => v_settings.payment_due_days)
  )
  returning * into v_order;

  insert into notifications (user_id, type, payload)
  values (
    v_offer.buyer_id, 'offer.accepted',
    jsonb_build_object(
      'offer_id', v_offer.id, 'order_id', v_order.id, 'order_reference', v_order.reference,
      'lot_id', v_lot.id, 'lot_title', v_lot.title, 'amount_cents', v_offer.amount_cents)
  );

  insert into notifications (user_id, type, payload)
  select o.buyer_id, 'offer.auto_declined',
         jsonb_build_object(
           'offer_id', o.id, 'lot_id', v_lot.id, 'lot_title', v_lot.title,
           'amount_cents', o.amount_cents, 'category_id', v_lot.category_id)
  from offers o
  where o.lot_id = v_lot.id
    and o.lot_generation = v_offer.lot_generation
    and o.status = 'auto_declined'
    and o.decided_at >= now() - interval '1 second';

  return v_order;
end;
$$;

-- ─── decline_offer ─────────────────────────────────────────────────────────
-- Explicit, single, terminal. There is no counter. That is the whole point.

create or replace function decline_offer(p_offer_id uuid) returns offers
language plpgsql security definer set search_path = public as $$
declare
  v_actor uuid := auth.uid();
  v_offer offers;
  v_lot   lots;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  select * into v_offer from offers where id = p_offer_id;
  if not found then
    raise exception 'OFFER_NOT_FOUND' using errcode = 'P0012';
  end if;

  select * into v_lot from lots where id = v_offer.lot_id for update;

  if not exists (
    select 1 from companies where id = v_lot.company_id and owner_id = v_actor
  ) then
    raise exception 'NOT_YOUR_LOT' using errcode = '42501';
  end if;

  if v_offer.status <> 'pending' then
    raise exception 'OFFER_NOT_PENDING' using errcode = 'P0013';
  end if;

  update offers set status = 'declined', decided_at = now()
   where id = v_offer.id
  returning * into v_offer;

  insert into notifications (user_id, type, payload)
  values (
    v_offer.buyer_id, 'offer.declined',
    jsonb_build_object(
      'offer_id', v_offer.id, 'lot_id', v_lot.id, 'lot_title', v_lot.title,
      'amount_cents', v_offer.amount_cents, 'category_id', v_lot.category_id)
  );

  return v_offer;
end;
$$;

-- ─── relist_lot ────────────────────────────────────────────────────────────
-- Bumps the generation, which is the only sanctioned way a buyer who already
-- offered gets another shot.

create or replace function relist_lot(
  p_lot_id uuid,
  p_asking_price_cents bigint default null,
  p_offer_window_hours smallint default null
) returns lots
language plpgsql security definer set search_path = public as $$
declare
  v_actor uuid := auth.uid();
  v_lot   lots;
begin
  select * into v_lot from lots where id = p_lot_id for update;

  if not exists (
    select 1 from companies where id = v_lot.company_id and owner_id = v_actor
  ) then
    raise exception 'NOT_YOUR_LOT' using errcode = '42501';
  end if;

  if v_lot.status not in ('expired', 'removed') then
    raise exception 'LOT_NOT_RELISTABLE' using errcode = 'P0015';
  end if;

  update lots
     set generation = generation + 1,
         status = 'live',
         asking_price_cents = coalesce(p_asking_price_cents, asking_price_cents),
         offer_window_hours = coalesce(p_offer_window_hours, offer_window_hours),
         published_at = now(),
         closes_at = now() + make_interval(
           hours => coalesce(p_offer_window_hours, offer_window_hours)),
         sold_at = null
   where id = p_lot_id
  returning * into v_lot;

  return v_lot;
end;
$$;

-- ─── expire_offers ─────────────────────────────────────────────────────────
-- Offers expire on a schedule, never lazily on read. A buyer must never load
-- a page and discover their offer silently died three hours ago.
-- Called by /api/cron/expire-offers every 5 minutes.

create or replace function expire_offers() returns table (expired_offers int, expired_lots int)
language plpgsql security definer set search_path = public as $$
declare
  v_offers int := 0;
  v_lots   int := 0;
begin
  with done as (
    update offers set status = 'expired', decided_at = now()
     where status = 'pending' and expires_at <= now()
    returning id, buyer_id, lot_id, amount_cents
  ),
  notified as (
    insert into notifications (user_id, type, payload)
    select d.buyer_id, 'offer.expired',
           jsonb_build_object('offer_id', d.id, 'lot_id', d.lot_id,
                              'amount_cents', d.amount_cents)
    from done d
    returning 1
  )
  select count(*) into v_offers from done;

  with closed as (
    update lots set status = 'expired'
     where status = 'live' and closes_at <= now()
    returning id
  )
  select count(*) into v_lots from closed;

  return query select v_offers, v_lots;
end;
$$;

-- ─── Coaching analytics (v1 scope) ─────────────────────────────────────────
-- Powers the panel a buyer sees after a decline: how far off were they, and
-- what does this category actually clear at. This is the softest landing we
-- can give the worst moment in the product. See docs/BRAND.md §11(i).

create or replace view category_clearing_stats as
select
  l.category_id,
  count(*)                                                        as deals_90d,
  percentile_cont(0.5) within group (order by l.discount_bps)     as median_discount_bps,
  percentile_cont(0.5) within group (
    order by (o.amount_cents * 10000 / nullif(l.asking_price_cents, 0))
  )                                                               as median_pct_of_ask_bps
from offers o
join lots l on l.id = o.lot_id
where o.status = 'accepted'
  and o.decided_at >= now() - interval '90 days'
group by l.category_id;

-- Per-offer post-mortem: how far behind the winner was this offer.
create or replace view offer_outcomes as
select
  o.id                as offer_id,
  o.buyer_id,
  o.lot_id,
  o.amount_cents,
  o.status,
  l.category_id,
  l.asking_price_cents,
  w.amount_cents      as winning_amount_cents,
  (w.amount_cents - o.amount_cents)                          as gap_cents,
  case when w.amount_cents > 0
       then ((w.amount_cents - o.amount_cents) * 10000 / w.amount_cents)
  end                                                        as gap_bps
from offers o
join lots l on l.id = o.lot_id
left join offers w
  on w.lot_id = o.lot_id
 and w.lot_generation = o.lot_generation
 and w.status = 'accepted'
where o.status in ('declined', 'auto_declined', 'expired');

-- ─── Recommendations (v1 scope) ────────────────────────────────────────────
-- "Because you bought kitchen appliances". Heuristic, no ML: weight completed
-- orders heaviest, then offers placed, then watchlist.

create or replace view user_category_affinity as
select user_id, category_id, sum(weight) as score
from (
  select o.buyer_id as user_id, l.category_id, 5 as weight
    from orders o join lots l on l.id = o.lot_id
  union all
  select f.buyer_id, l.category_id, 2
    from offers f join lots l on l.id = f.lot_id
  union all
  select w.user_id, l.category_id, 1
    from watchlist w join lots l on l.id = w.lot_id
) s
where category_id is not null
group by user_id, category_id;
