-- ═══════════════════════════════════════════════════════════════════════════
-- Pallet — row level security
--
-- The single most important policy in this file:
--   A BUYER MUST NEVER SEE ANOTHER BUYER'S OFFER AMOUNT.
-- If competing amounts leak, the one-shot offer degrades into a live auction
-- and the entire product thesis collapses. Only the lot's owner sees the
-- ranked inbox. Public surfaces get a COUNT of offers, never the numbers.
-- ═══════════════════════════════════════════════════════════════════════════

alter table profiles       enable row level security;
alter table companies      enable row level security;
alter table categories     enable row level security;
alter table lots           enable row level security;
alter table lot_photos     enable row level security;
alter table lot_manifests  enable row level security;
alter table offers         enable row level security;
alter table orders         enable row level security;
alter table shipments      enable row level security;
alter table messages       enable row level security;
alter table ratings        enable row level security;
alter table watchlist      enable row level security;
alter table saved_searches enable row level security;
alter table notifications  enable row level security;
alter table platform_settings enable row level security;

-- ─── Helpers ───────────────────────────────────────────────────────────────

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

create or replace function owns_company(p_company_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from companies where id = p_company_id and owner_id = auth.uid()
  );
$$;

create or replace function owns_lot(p_lot_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from lots l join companies c on c.id = l.company_id
    where l.id = p_lot_id and c.owner_id = auth.uid()
  );
$$;

-- ─── Profiles ──────────────────────────────────────────────────────────────

create policy "profiles readable by everyone"
  on profiles for select using (true);

create policy "profiles self-update"
  on profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy "profiles admin-all"
  on profiles for all using (is_admin()) with check (is_admin());

-- ─── Companies ─────────────────────────────────────────────────────────────

create policy "companies readable by everyone"
  on companies for select using (true);

create policy "companies owner-insert"
  on companies for insert with check (owner_id = auth.uid());

create policy "companies owner-update"
  on companies for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "companies admin-all"
  on companies for all using (is_admin()) with check (is_admin());

-- ─── Categories ────────────────────────────────────────────────────────────

create policy "categories readable by everyone" on categories for select using (true);
create policy "categories admin-write" on categories for all
  using (is_admin()) with check (is_admin());

-- ─── Lots ──────────────────────────────────────────────────────────────────
-- Guests can browse. Drafts are private to the dealer.

create policy "lots public-read-live"
  on lots for select
  using (status in ('live', 'sold', 'expired') or owns_lot(id) or is_admin());

create policy "lots dealer-insert"
  on lots for insert with check (owns_company(company_id));

create policy "lots dealer-update"
  on lots for update using (owns_lot(id)) with check (owns_lot(id));

create policy "lots admin-all"
  on lots for all using (is_admin()) with check (is_admin());

-- ─── Lot media ─────────────────────────────────────────────────────────────

create policy "lot_photos follow lot visibility"
  on lot_photos for select
  using (exists (
    select 1 from lots l
    where l.id = lot_id
      and (l.status in ('live', 'sold', 'expired') or owns_lot(l.id) or is_admin())
  ));

create policy "lot_photos dealer-write"
  on lot_photos for all using (owns_lot(lot_id)) with check (owns_lot(lot_id));

create policy "lot_manifests follow lot visibility"
  on lot_manifests for select
  using (exists (
    select 1 from lots l
    where l.id = lot_id
      and (l.status in ('live', 'sold', 'expired') or owns_lot(l.id) or is_admin())
  ));

create policy "lot_manifests dealer-write"
  on lot_manifests for all using (owns_lot(lot_id)) with check (owns_lot(lot_id));

-- ─── Offers ────────────────────────────────────────────────────────────────
-- THE policy. A row is visible to exactly two parties: the buyer who wrote it,
-- and the dealer who owns the lot. Nobody else. Not other bidders, not guests.

create policy "offers visible to author and lot owner only"
  on offers for select
  using (buyer_id = auth.uid() or owns_lot(lot_id) or is_admin());

-- Inserts go through place_offer() only. Direct writes would skip the
-- eligibility checks and the row lock, so there is deliberately no INSERT
-- policy here. Same for UPDATE: accept_offer / decline_offer / expire_offers
-- are the only sanctioned transitions.
create policy "offers admin-all"
  on offers for all using (is_admin()) with check (is_admin());

-- ─── Orders ────────────────────────────────────────────────────────────────

create policy "orders visible to both parties"
  on orders for select
  using (buyer_id = auth.uid() or owns_company(seller_company_id) or is_admin());

create policy "orders parties-update"
  on orders for update
  using (buyer_id = auth.uid() or owns_company(seller_company_id) or is_admin())
  with check (buyer_id = auth.uid() or owns_company(seller_company_id) or is_admin());

-- ─── Shipments ─────────────────────────────────────────────────────────────

create policy "shipments visible to both parties"
  on shipments for select
  using (exists (
    select 1 from orders o
    where o.id = order_id
      and (o.buyer_id = auth.uid() or owns_company(o.seller_company_id) or is_admin())
  ));

create policy "shipments dealer-write"
  on shipments for all
  using (exists (
    select 1 from orders o where o.id = order_id and owns_company(o.seller_company_id)
  ))
  with check (exists (
    select 1 from orders o where o.id = order_id and owns_company(o.seller_company_id)
  ));

-- ─── Messages ──────────────────────────────────────────────────────────────
-- Order-scoped. There is no pre-acceptance thread to secure, because there is
-- no pre-acceptance thread.

create policy "messages visible to both parties"
  on messages for select
  using (exists (
    select 1 from orders o
    where o.id = order_id
      and (o.buyer_id = auth.uid() or owns_company(o.seller_company_id) or is_admin())
  ));

create policy "messages parties-insert"
  on messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from orders o
      where o.id = order_id
        and (o.buyer_id = auth.uid() or owns_company(o.seller_company_id))
    )
  );

-- ─── Ratings ───────────────────────────────────────────────────────────────

create policy "ratings readable by everyone" on ratings for select using (true);

create policy "ratings party-insert"
  on ratings for insert
  with check (
    rater_id = auth.uid()
    and exists (
      select 1 from orders o
      where o.id = order_id
        and o.status = 'complete'
        and (o.buyer_id = auth.uid() or owns_company(o.seller_company_id))
    )
  );

-- ─── Buyer-private tables ──────────────────────────────────────────────────

create policy "watchlist self-only" on watchlist for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "saved_searches self-only" on saved_searches for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "notifications self-read" on notifications for select
  using (user_id = auth.uid());

create policy "notifications self-update" on notifications for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ─── Settings ──────────────────────────────────────────────────────────────

create policy "settings readable" on platform_settings for select using (true);
create policy "settings admin-write" on platform_settings for all
  using (is_admin()) with check (is_admin());

-- ─── Views inherit the RLS of their base tables under security_invoker ─────

alter view offer_outcomes            set (security_invoker = on);
alter view category_clearing_stats   set (security_invoker = on);
alter view user_category_affinity    set (security_invoker = on);

-- ─── Signup trigger ────────────────────────────────────────────────────────

create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'full_name',
    coalesce((new.raw_user_meta_data ->> 'role')::user_role, 'buyer')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
