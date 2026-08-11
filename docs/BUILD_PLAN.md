# BUILD_PLAN.md — the next session, end to end

**v1 target:** the 7 designed screens, full-stack and real. Not mocks.

`Home · Browse · Lot detail · Offer confirm · My offers · Order · Dealer offer inbox`

Everything is scaffolded. Migrations are written. Tokens are in `globals.css`. What follows is
the build order, and it is deliberately dependency-ordered — each phase leaves the app running.

---

## Phase 0 — Environment (~20 min)

1. `npm install` *(may already be done — check for `node_modules/`)*
2. Copy `.env.example` → `.env.local`, fill in Supabase + Stripe test keys.
3. `npm run db:start` — local Supabase stack.
4. `npm run db:reset` — applies all three migrations.
5. `npm run db:types` — generates `src/types/database.ts`.
6. `npm run db:seed` — 3 companies, 8 categories, ~24 lots, ~40 offers across every status.
7. `npm run dev` → verify it boots.

**Blockers to expect.** `ui.shadcn.com` and `21st.dev` were unreachable on 2026-08-11
(TCP timeout; npm was fine). If `npx shadcn add` still fails, the primitives in
`src/components/ui/` are hand-written and complete enough to build on — add the rest by hand
from the Radix docs rather than burning the session on network debugging.

**Exit:** dev server up, seeded lots visible in Supabase Studio.

---

## Phase 1 — Design system foundation (~1h)

Build these before any screen. Every screen composes them and getting them wrong means
rebuilding six times.

- `Money` / `PriceBlock` — cents → display, `.tnum`, size variants (XL/L/M)
- `DiscountBadge` — `orange-100` fill, `orange-700` text, pill. One per card. (BRAND §11(d))
- `StatusPill` — the five offer statuses + eight order statuses, per COPY.md
- `CountdownTimer` — the color scale from BRAND §11(e). **Never orange.**
- `PhotoFrame` — 4:3, `sand-100`, `.photo-tone`, missing-photo fallback
- `VerifiedMark` — `success-500` shield
- `EmptyState`
- `Skeleton` variants that mirror real layout dimensions exactly

**Then the chrome:** `Header` (with taste change §11(a) — search submit is `ink-800`, not
orange), `CategoryStrip` (§11(b) — 34px, plain text, orange underline on active), `Footer`.

**Exit:** a `/kitchen-sink` route renders every primitive in every state. Delete it before merge.

---

## Phase 2 — Auth + accounts (~1h)

- `@supabase/ssr` client/server/middleware in `src/lib/supabase/`
- Middleware refreshes the session on every request
- `/auth/login`, `/auth/signup` (role picker: Buyer / Dealer / Both), `/auth/callback`
- The `handle_new_user` trigger already creates the profile row
- Company creation on first dealer action
- Role switcher in the header ("Switch to selling")

**Exit:** sign up as a dealer, sign up as a buyer, switch roles, sessions survive a refresh.

---

## Phase 3 — Lots: read path (~2h)

- `src/server/queries/lots.ts` — list with filters, detail by slug, facet counts
- **`/browse`** — filter rail (category, condition, price range, discount, location, verified),
  sort, list/grid toggle, pagination. All filter state in the URL via `nuqs`.
- **`/lots/[slug]`** — gallery + lightbox, spec table, manifest mix bars, description,
  dealer card, sticky offer rail
- **`/` (Home)** — hero, category circles, "Closing soon", trust cards, recommendations row
  (from `user_category_affinity`)

Freight estimate card: **omit**. Freight is v2 (see PROJECT.md §7). Do not ship a card that
implies a quote the app cannot produce.

**Exit:** browse and filter real seeded lots, open a lot, everything reads from Postgres.

---

## Phase 4 — The offer engine (~2h) ← the important one

Read `docs/OFFER_ENGINE.md` completely first.

- `src/server/actions/offers.ts` — `placeOffer`, `acceptOffer`, `declineOffer`. RPC calls only;
  never `.from('offers').insert()`.
- `src/lib/errors.ts` — PG code → COPY.md string
- `OfferForm` — amount input, quick-offer chips, live "% of asking / % off retail" hint
- `OfferConfirmDialog` — the 400ms enter, serif amount, no warning triangle, checkbox +
  600ms dwell interlock. Spec in OFFER_ENGINE.md § "The confirmation UX".
- **`/offers`** — tabbed by status, the post-submit banner, the coaching card for declines
- **`/dealer/lots/[id]/offers`** — ranked inbox, buyer rating + verified, Accept/Decline,
  the auto-decline cascade animation (BRAND §11(h)), a11y labels carrying the consequence
- `/api/cron/expire-offers` + `vercel.json` cron entry

**Write the tests from OFFER_ENGINE.md § "Test cases" in this phase, not later.** Cases 1–3
(concurrency) and 11–13 (offer isolation) are non-negotiable. Case 11 is the one that protects
the entire product thesis.

**Exit:** place an offer as a buyer, accept it as the dealer, watch the siblings cascade to
"Not selected", land on a real order.

---

## Phase 5 — Orders + Stripe (~2h)

- `/orders/[reference]` — status timeline, logistics panel, totals rail, pay CTA
- Stripe Connect Express onboarding for dealers
- PaymentIntent on the order, funds held, `application_fee_amount` = platform fee
- `/api/stripe/webhook` — signature-verified, idempotent on `event.id`
- Order state machine: `awaiting_payment → paid → awaiting_shipment → in_transit → delivered → complete`

**Exit:** pay a test order end to end, webhook advances the status.

---

## Phase 6 — Polish (~2h)

- The 20 components from `docs/COMPONENTS_21ST.md`, each run through the retint checklist
- Higgsfield assets per `docs/ASSETS.md` — hero loop, 8 category tiles, 5 empty states
- Loading skeletons on every route
- Accessibility pass against `docs/ACCESSIBILITY.md` — keyboard the whole offer flow, axe clean
- Responsive check at 1024 / 1280 / 1440, including the sticky bottom bar at 1024 (§11(l))
- Reduced-motion pass: every animation, verified

**Exit:** axe reports zero violations on the 7 screens; the offer flow is completable with the
keyboard alone.

---

## Deliberately out of v1

| Deferred | Note |
|---|---|
| Freight quoting and brokering | Fields captured on the lot; no carrier integration, no quote UI, no promise in copy |
| Messaging | Order-scoped threads; schema exists, UI is v2 |
| Ratings UI | Schema and RLS exist |
| Admin screens | Except the manifest-verification queue, which v1 needs for the badge |
| Saved searches + alerts | Schema exists |
| Mobile | Desktop only, 1024 minimum |
| Disputes | Schema has the status; no resolution flow |

## In v1 by explicit decision (2026-08-11)

- **Offer coaching analytics** — the decline moment is the emotional core of the design
- **Manifest verification badge** — plus the minimal admin queue behind it
- **Recommendations row** — heuristic from `user_category_affinity`, no ML

## Definition of done

- [ ] All 7 screens work against real Postgres with no mock data
- [ ] The one-shot rule holds under concurrent load (tests 1–3)
- [ ] A buyer cannot see another buyer's offer amount by any route (tests 11–13)
- [ ] Money is bigint cents end to end; no float in the path
- [ ] Every animation respects `prefers-reduced-motion`
- [ ] Contrast verified for every pair in use; nothing new added without a ratio
- [ ] The offer flow is fully keyboard-operable with visible focus throughout
- [ ] `npm run typecheck && npm run lint && npm run test` clean
