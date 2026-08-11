# PROJECT.md — Wholesale Marketplace

Working name: **Pallet** (placeholder, change freely). Repo: `wholesale-marketplace-public`.

## 0. Locked decisions (2026-08-11)

| Question | Decision |
|---|---|
| Design canon | `design/Pallet Marketplace.dc.html`. `BRAND.md` was rewritten to match it; §11 lists the deliberate deviations. |
| v1 build scope | The **7 designed screens, full-stack**: Home, Browse, Lot detail, Offer confirm, My offers, Order, Dealer offer inbox |
| Freight quoting / brokering | **v2.** Fields are captured on the lot; there is no quote UI, no carrier integration, and no copy promising one |
| Offer coaching analytics | **v1** — the decline moment is the emotional core of the design |
| Manifest verification badge | **v1**, plus the minimal admin queue behind it |
| Recommendations row | **v1**, heuristic from `user_category_affinity`, no ML |
| Stack | Next.js 15 · Tailwind v4 · shadcn/ui · Supabase · Stripe Connect |

Phased build order and exit criteria: `docs/BUILD_PLAN.md`.

## 1. What this is

A marketplace where wholesale dealers unload excess inventory and buyers get it cheap.

Two sides, two goals:

- **Dealer:** has too much product sitting in a warehouse. Wants it gone fast, wants cash, does not want to haggle over email for three weeks.
- **Buyer:** wants product for pennies on the dollar. Resellers, liquidators, discount retailers, exporters.

The whole product is built around one rule: **offers are one shot.**

## 2. The one-shot offer rule

This is the core mechanic. Everything else supports it.

1. Dealer posts a lot with an asking price.
2. Buyer submits **one** offer on that lot. One number. No message thread, no back and forth.
3. Dealer sees the offer and picks: **Accept** or **Decline**. Nothing else.
4. Accepted offer becomes an order. Declined offer is dead.

Rules that make this work:

- A buyer gets **one active offer per lot**. Once submitted, it cannot be edited or raised.
- A buyer may not submit a second offer on the same lot, ever, unless the dealer explicitly relists the lot.
- Dealer cannot counter. There is no counter button. This is on purpose.
- Offers **expire** after a dealer-set window (default 48 hours). Expired offers free the buyer to offer again once, if the lot is still live.
- Dealer sees all offers on a lot ranked by amount. Accepting one **auto-declines the rest** if the lot is sold whole.
- Offers are **binding on the buyer**. Accepting creates a real order. Buyer backing out costs them reputation and can suspend the account.

Why it matters for design: the offer form is the highest-stakes screen in the app. It needs to feel deliberate. Confirmation before submit. Clear "this cannot be changed" language.

## 3. Users and roles

| Role | Can do |
|---|---|
| Guest | Browse lots, see prices, cannot offer |
| Buyer | Everything guest does, plus submit offers, message after acceptance, rate dealers, track orders |
| Dealer | Create/manage lots, review offers, accept/decline, manage shipping, rate buyers |
| Both | One account can hold both roles. Role switcher in the header. |
| Admin | Verify accounts, moderate lots, resolve disputes, view platform metrics |

Accounts are **business accounts**, not personal. Signup collects company name, business type, and optionally a resale certificate / EIN. Verified badge on profiles that pass review.

## 4. Feature areas (full marketplace scope)

### 4.1 Auth and accounts
- Email + password, plus magic link.
- Business profile: company name, logo, location, years in business, categories they deal in.
- Verification flow: upload business docs, admin approves, profile gets a Verified badge.
- Role selection at signup (Buyer / Dealer / Both), switchable later.

### 4.2 Listings ("lots")
A lot is a bundle of product, not a single item. Fields:

- Title, description, category, subcategory
- Condition: New / Overstock / Shelf Pull / Customer Return / Salvage / Mixed
- Quantity (units), units per case, number of pallets
- Retail value (MSRP total) vs asking price — the "pennies on the dollar" ratio is shown prominently
- Photos (multiple, required, min 3), optional manifest file (CSV/PDF)
- Location (city/state) and whether buyer pickup is allowed
- Shipping: freight class, weight, dimensions, who pays
- Offer window (hours), minimum offer threshold (optional, hidden from buyers)
- Sell whole only, or allow partial-quantity offers
- Status: Draft / Live / Offer Pending / Sold / Expired / Removed

### 4.3 Browse and search
- Full-text search plus filters: category, condition, price range, quantity, location/radius, discount % off retail, dealer verified only
- Sort: newest, price low/high, biggest discount, ending soonest
- Saved searches with email alerts
- Watchlist (save a lot without offering)

### 4.4 Offers
- Offer form: amount, quantity (if partial allowed), pickup vs freight, optional short note (140 char cap, informational only, not a negotiation channel)
- Explicit confirm step: "You get one offer on this lot. Submit $X?"
- Buyer offer dashboard: Pending / Accepted / Declined / Expired
- Dealer offer inbox per lot: sorted by amount, shows buyer rating and verified status, Accept / Decline per row
- Notifications on every state change (in-app + email)

### 4.5 Orders and payments
- Accepted offer creates an Order.
- Stripe Connect: platform takes a fee, dealer gets paid out.
- Funds held until buyer confirms pickup/delivery or a hold window elapses (default 7 days after delivery).
- Order states: Awaiting Payment → Paid → Awaiting Shipment → In Transit → Delivered → Complete. Plus Disputed and Cancelled.
- Invoices, downloadable receipts.

### 4.6 Messaging
- **Locked until an offer is accepted.** No pre-offer chat. This protects the one-shot rule.
- Thread scoped to an order. File attachments (BOL, packing lists).

### 4.7 Shipping and logistics
- Dealer enters freight details or uploads a BOL.
- Tracking number field, carrier picker, status updates.
- Pickup option: dealer sets pickup window and address, released to buyer after payment.

### 4.8 Ratings and reputation
- Both sides rate after order completion: 1-5 plus tags (Accurate manifest / Fast shipping / Good communication / As described).
- Public score on profile, count of completed deals, total volume moved.
- Buyer reliability score: offers accepted vs. offers backed out of.

### 4.9 Admin
- Account verification queue
- Lot moderation queue (flagged/reported lots)
- Dispute resolution: view order, message both parties, refund or release funds
- Metrics: GMV, live lots, offer acceptance rate, average discount off retail, active dealers/buyers

### 4.10 Notifications
In-app bell + email for: new offer received, offer accepted, offer declined, offer expiring soon, payment received, shipment update, new message, saved search match.

## 5. Data model (starting point)

```
users            id, email, name, role[buyer|dealer|both|admin], created_at
companies        id, owner_user_id, name, logo_url, bio, city, state,
                 years_in_business, verified_at, stripe_account_id
lots             id, company_id, title, description, category_id, condition,
                 quantity, units_per_case, pallet_count, retail_value_cents,
                 asking_price_cents, min_offer_cents, offer_window_hours,
                 allow_partial, allow_pickup, city, state, weight_lbs,
                 freight_class, status, published_at, expires_at
lot_photos       id, lot_id, url, position
lot_manifests    id, lot_id, file_url, file_type
categories       id, parent_id, name, slug
offers           id, lot_id, buyer_user_id, amount_cents, quantity,
                 fulfillment[pickup|freight], note, status[pending|accepted|
                 declined|expired|withdrawn_by_system], expires_at, created_at
                 UNIQUE (lot_id, buyer_user_id) per lot generation
orders           id, offer_id, lot_id, buyer_user_id, seller_company_id,
                 amount_cents, platform_fee_cents, status, paid_at,
                 shipped_at, delivered_at, completed_at
shipments        id, order_id, carrier, tracking_number, bol_url, status
messages         id, order_id, sender_user_id, body, attachment_url, created_at
ratings          id, order_id, rater_user_id, ratee_user_id, score, tags[], comment
watchlist        id, user_id, lot_id
saved_searches   id, user_id, query_json, alert_frequency
notifications    id, user_id, type, payload_json, read_at
```

Key constraints:
- Unique index on `(lot_id, buyer_user_id)` blocks a second offer on the same lot.
- Accepting an offer runs in a transaction: set offer `accepted`, all sibling offers `declined`, lot `sold`, create order.
- Offers expire via a scheduled job, not on read.

## 6. Page inventory

**Public**

1. Landing page
2. Browse / search results
3. Lot detail
4. Company/dealer public profile
5. Category page
6. Sign up (role picker) / Log in

**Buyer**

7. Buyer dashboard (offers at a glance)
8. Make an offer (modal or page) + confirm step
9. My offers (tabbed by status)
10. Watchlist
11. Saved searches
12. My orders → order detail (payment, shipping, messages)
13. Leave a rating

**Dealer**

14. Dealer dashboard (lots, offers, revenue)
15. Create lot (multi-step form)
16. My lots (table with status)
17. Offer inbox for a lot (the accept/decline screen)
18. My sales → order detail (shipping, messages, payout)
19. Payout / Stripe settings

**Shared**

20. Account settings, business profile, verification upload
21. Notifications
22. Messages (order-scoped)

**Admin**

23. Verification queue
24. Lot moderation
25. Disputes
26. Platform metrics

## 7. Non-goals for v1

Permanent, by design:

- No auctions or bidding wars. One-shot offers only.
- No counter-offers. Ever.
- No public chat before acceptance.
- No mobile app. Desktop web only, 1024 minimum.
- No international shipping / customs handling.
- No consumer buyers. Business accounts only.

Deferred to v2 — schema exists, UI does not:

- **Freight quoting and brokering.** The lot captures weight, class, and dimensions, but there
  is no rate lookup, no "Book freight through Pallet", and no quote on the lot page. The
  prototype shows a freight estimate card; **it is omitted in v1.** Marketing copy must not
  promise it either — see `docs/COPY.md` § Marketing.
- Order-scoped messaging UI
- Ratings UI
- Saved searches and email alerts
- Admin screens, except the manifest-verification queue that v1's badge requires
- Dispute resolution flow (the order status exists; the workflow does not)

## 8. Design direction (summary — see BRAND.md)

Hermès orange over a warm dune palette. Restrained, not loud. Orange is for action and emphasis, not for filling screens. The feel should read as a serious trading floor for businesses, not a flea market. Dense but calm. Lots of warm neutral space, sharp typography, generous data tables.

`BRAND.md` v2 is the current visual system and matches the prototype: pill buttons, 14px cards,
`ink-900` header and footer chrome, three-tier type. Its §11 records every deliberate deviation
from the prototype and why.
