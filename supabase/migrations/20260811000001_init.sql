-- ═══════════════════════════════════════════════════════════════════════════
-- Pallet — core schema
--
-- Money is ALWAYS bigint cents. Never numeric, never float, never dollars.
-- Every timestamp is timestamptz. Every id is uuid.
-- ═══════════════════════════════════════════════════════════════════════════

create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";

-- ─── Enums ─────────────────────────────────────────────────────────────────

create type user_role as enum ('buyer', 'dealer', 'both', 'admin');

create type lot_condition as enum (
  'new', 'overstock', 'shelf_pull', 'customer_return', 'salvage', 'mixed'
);

create type lot_status as enum (
  'draft',      -- dealer is still writing it
  'live',       -- accepting offers
  'sold',       -- an offer was accepted
  'expired',    -- offer window closed with no acceptance
  'removed'     -- pulled by dealer or admin
);

create type offer_status as enum (
  'pending',        -- submitted, awaiting the dealer
  'accepted',       -- dealer took it; an order exists
  'declined',       -- dealer explicitly declined. Terminal for this buyer.
  'auto_declined',  -- a sibling offer was accepted. Not the buyer's fault.
  'expired'         -- the window closed. Buyer earns exactly one retry.
);

create type order_status as enum (
  'awaiting_payment', 'paid', 'awaiting_shipment', 'in_transit',
  'delivered', 'complete', 'disputed', 'cancelled'
);

create type fulfillment_method as enum ('pickup', 'freight');

create type verification_status as enum ('unverified', 'pending', 'verified', 'rejected');

-- ─── Users and companies ───────────────────────────────────────────────────
-- Mirrors auth.users. Populated by a trigger on signup (see 0004_triggers.sql).

create table profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  email             text not null,
  full_name         text,
  role              user_role not null default 'buyer',
  avatar_url        text,
  -- Offers accepted vs. offers the buyer walked away from. Drives the
  -- reliability figure the dealer sees in the offer inbox.
  offers_honored    integer not null default 0,
  offers_reneged    integer not null default 0,
  suspended_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Accounts are businesses, not people. A profile owns exactly one company.
create table companies (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null unique references profiles (id) on delete cascade,
  name                 text not null,
  slug                 text not null unique,
  logo_url             text,
  bio                  text,
  city                 text,
  state                text,
  postal_code          text,
  years_in_business    smallint,
  verification         verification_status not null default 'unverified',
  verified_at          timestamptz,
  -- Stripe Connect express account. Null until the dealer onboards.
  stripe_account_id    text unique,
  stripe_payouts_ready boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index companies_verification_idx on companies (verification);

-- ─── Categories ────────────────────────────────────────────────────────────

create table categories (
  id         uuid primary key default gen_random_uuid(),
  parent_id  uuid references categories (id) on delete cascade,
  name       text not null,
  slug       text not null unique,
  position   smallint not null default 0,
  image_url  text
);

create index categories_parent_idx on categories (parent_id);

-- ─── Lots ──────────────────────────────────────────────────────────────────

create table lots (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies (id) on delete cascade,
  category_id        uuid references categories (id) on delete set null,

  title              text not null check (char_length(title) between 8 and 140),
  slug               text not null unique,
  description        text,
  condition          lot_condition not null,

  -- Quantities
  quantity           integer not null check (quantity > 0),
  units_per_case     integer check (units_per_case > 0),
  pallet_count       integer check (pallet_count > 0),

  -- Money, in cents. The discount ratio shown everywhere is derived from these
  -- two, never stored — see the generated columns below.
  retail_value_cents bigint not null check (retail_value_cents > 0),
  asking_price_cents bigint not null check (asking_price_cents > 0),
  -- Hidden from buyers. Offers below this are still accepted into the inbox
  -- but flagged, so the dealer can triage. Never surfaced publicly.
  min_offer_cents    bigint check (min_offer_cents > 0),

  discount_bps integer generated always as (
    greatest(0, 10000 - (asking_price_cents * 10000 / nullif(retail_value_cents, 0))::integer)
  ) stored,

  -- Location and pickup
  city          text not null,
  state         text not null,
  postal_code   text,
  allow_pickup  boolean not null default true,

  -- Freight (captured now, brokered in v2 — see docs/PROJECT.md §7)
  weight_lbs    integer check (weight_lbs > 0),
  freight_class text,
  length_in     integer,
  width_in      integer,
  height_in     integer,

  -- Offer rules
  offer_window_hours smallint not null default 48 check (offer_window_hours between 6 and 336),
  allow_partial      boolean not null default false,

  -- Lifecycle. `generation` increments on relist; it is what makes the
  -- one-offer-per-buyer rule resettable without deleting history.
  status       lot_status not null default 'draft',
  generation   smallint not null default 1,
  published_at timestamptz,
  closes_at    timestamptz,
  sold_at      timestamptz,

  -- Manifest verification badge (v1 scope). Set by an admin via the ops queue.
  manifest_verified_at timestamptz,
  manifest_verified_by uuid references profiles (id) on delete set null,

  search_vector tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B')
  ) stored,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint asking_below_retail check (asking_price_cents <= retail_value_cents),
  constraint live_lots_have_a_deadline check (status <> 'live' or closes_at is not null)
);

create index lots_status_closes_idx on lots (status, closes_at) where status = 'live';
create index lots_company_idx        on lots (company_id, status);
create index lots_category_idx       on lots (category_id) where status = 'live';
create index lots_discount_idx       on lots (discount_bps desc) where status = 'live';
create index lots_price_idx          on lots (asking_price_cents) where status = 'live';
create index lots_search_idx         on lots using gin (search_vector);
create index lots_title_trgm_idx     on lots using gin (title gin_trgm_ops);

create table lot_photos (
  id         uuid primary key default gen_random_uuid(),
  lot_id     uuid not null references lots (id) on delete cascade,
  storage_path text not null,
  position   smallint not null default 0,
  width      integer,
  height     integer,
  created_at timestamptz not null default now()
);

create index lot_photos_lot_idx on lot_photos (lot_id, position);

create table lot_manifests (
  id           uuid primary key default gen_random_uuid(),
  lot_id       uuid not null references lots (id) on delete cascade,
  storage_path text not null,
  file_type    text not null check (file_type in ('csv', 'pdf', 'xlsx')),
  row_count    integer,
  -- Parsed category mix, rendered as the bar breakdown on lot detail:
  -- [{"label":"Small kitchen appliances","pct":60}, ...]
  mix_json     jsonb,
  created_at   timestamptz not null default now()
);

create index lot_manifests_lot_idx on lot_manifests (lot_id);

-- ─── Offers ────────────────────────────────────────────────────────────────
-- The one-shot rule lives here. See docs/OFFER_ENGINE.md before touching it.

create table offers (
  id              uuid primary key default gen_random_uuid(),
  lot_id          uuid not null references lots (id) on delete cascade,
  buyer_id        uuid not null references profiles (id) on delete cascade,
  -- Snapshot of lots.generation at submit time. A relist bumps the lot's
  -- generation and every buyer gets a clean slate.
  lot_generation  smallint not null,
  -- 1 on the first attempt, 2 on the one retry earned by an expiry.
  attempt         smallint not null default 1 check (attempt in (1, 2)),

  amount_cents    bigint not null check (amount_cents > 0),
  quantity        integer check (quantity > 0),
  fulfillment     fulfillment_method not null default 'freight',
  -- Informational only. Not a negotiation channel. Hard-capped at 140.
  note            text check (char_length(note) <= 140),

  status          offer_status not null default 'pending',
  expires_at      timestamptz not null,
  decided_at      timestamptz,
  created_at      timestamptz not null default now()
);

-- THE constraint. A buyer can hold at most one live offer on a lot generation.
-- Partial, so expired/declined history stays queryable for the coaching card.
create unique index offers_one_live_per_buyer_idx
  on offers (lot_id, buyer_id, lot_generation)
  where status = 'pending';

-- And at most one accepted offer per lot generation, ever.
create unique index offers_one_accepted_per_lot_idx
  on offers (lot_id, lot_generation)
  where status = 'accepted';

-- The dealer inbox reads this: pending offers on a lot, ranked by amount.
create index offers_inbox_idx on offers (lot_id, amount_cents desc) where status = 'pending';
create index offers_buyer_idx on offers (buyer_id, created_at desc);
-- Drives the expiry sweep.
create index offers_expiry_idx on offers (expires_at) where status = 'pending';

-- ─── Orders ────────────────────────────────────────────────────────────────

create table orders (
  id                  uuid primary key default gen_random_uuid(),
  -- Human-facing: PLT-40817
  reference           text not null unique,
  offer_id            uuid not null unique references offers (id) on delete restrict,
  lot_id              uuid not null references lots (id) on delete restrict,
  buyer_id            uuid not null references profiles (id) on delete restrict,
  seller_company_id   uuid not null references companies (id) on delete restrict,

  amount_cents        bigint not null check (amount_cents > 0),
  platform_fee_cents  bigint not null default 0 check (platform_fee_cents >= 0),
  freight_cents       bigint not null default 0 check (freight_cents >= 0),
  total_cents         bigint not null check (total_cents > 0),
  fulfillment         fulfillment_method not null,

  status              order_status not null default 'awaiting_payment',

  stripe_payment_intent_id text unique,
  stripe_transfer_id       text unique,

  payment_due_at      timestamptz,
  paid_at             timestamptz,
  shipped_at          timestamptz,
  delivered_at        timestamptz,
  -- Funds release to the dealer at this point unless a dispute is open.
  funds_release_at    timestamptz,
  completed_at        timestamptz,
  disputed_at         timestamptz,
  cancelled_at        timestamptz,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index orders_buyer_idx  on orders (buyer_id, created_at desc);
create index orders_seller_idx on orders (seller_company_id, created_at desc);
create index orders_status_idx on orders (status);

create table shipments (
  id              uuid primary key default gen_random_uuid(),
  order_id        uuid not null references orders (id) on delete cascade,
  carrier         text,
  tracking_number text,
  bol_path        text,
  pickup_window   tstzrange,
  pickup_address  text,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index shipments_order_idx on shipments (order_id);

-- ─── Messaging ─────────────────────────────────────────────────────────────
-- Order-scoped only. There is no pre-acceptance chat, by design — it would be
-- a back channel around the one-shot rule.

create table messages (
  id           uuid primary key default gen_random_uuid(),
  order_id     uuid not null references orders (id) on delete cascade,
  sender_id    uuid not null references profiles (id) on delete cascade,
  body         text not null check (char_length(body) between 1 and 4000),
  attachment_path text,
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);

create index messages_order_idx on messages (order_id, created_at);

-- ─── Reputation ────────────────────────────────────────────────────────────

create table ratings (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references orders (id) on delete cascade,
  rater_id   uuid not null references profiles (id) on delete cascade,
  ratee_id   uuid not null references profiles (id) on delete cascade,
  score      smallint not null check (score between 1 and 5),
  tags       text[] not null default '{}',
  comment    text check (char_length(comment) <= 1000),
  created_at timestamptz not null default now(),
  unique (order_id, rater_id)
);

create index ratings_ratee_idx on ratings (ratee_id);

-- ─── Buyer-side saved state ────────────────────────────────────────────────

create table watchlist (
  user_id    uuid not null references profiles (id) on delete cascade,
  lot_id     uuid not null references lots (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, lot_id)
);

create table saved_searches (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references profiles (id) on delete cascade,
  name            text not null,
  query_json      jsonb not null,
  alert_frequency text not null default 'daily' check (alert_frequency in ('off', 'instant', 'daily', 'weekly')),
  last_alerted_at timestamptz,
  created_at      timestamptz not null default now()
);

create index saved_searches_user_idx on saved_searches (user_id);

-- ─── Notifications ─────────────────────────────────────────────────────────

create table notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles (id) on delete cascade,
  type       text not null,
  payload    jsonb not null default '{}',
  read_at    timestamptz,
  emailed_at timestamptz,
  created_at timestamptz not null default now()
);

create index notifications_user_idx on notifications (user_id, created_at desc);
create index notifications_unread_idx on notifications (user_id) where read_at is null;

-- ─── updated_at maintenance ────────────────────────────────────────────────

create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array['profiles','companies','lots','orders','shipments']
  loop
    execute format(
      'create trigger %I_touch before update on %I
         for each row execute function touch_updated_at()', t, t);
  end loop;
end;
$$;
