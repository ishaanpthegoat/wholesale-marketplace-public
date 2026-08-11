# ARCHITECTURE.md

## Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Next.js 15, App Router, React 19 | Server Components keep the dense data tables off the client bundle |
| Language | TypeScript, `strict` + `noUncheckedIndexedAccess` | Money bugs are the expensive kind |
| Styling | Tailwind CSS v4 (CSS-first `@theme`) | Tokens live in `globals.css`, one source of truth shared with the prototype |
| Components | shadcn/ui (new-york) + Radix + 21st.dev | Copy-paste, so every component gets retinted to the brand |
| Motion | `motion` (Framer Motion v11) | Layout animations for the tab underline and the decline cascade |
| Database | Supabase Postgres | RLS is the security model, not an afterthought |
| Auth | Supabase Auth (email+password, magic link) | `@supabase/ssr` cookie sessions |
| Storage | Supabase Storage | Lot photos, manifests, BOLs |
| Payments | Stripe Connect (Express) | Platform fee + dealer payouts + held funds |
| Forms | react-hook-form + Zod | Same Zod schema validates client and server |
| URL state | `nuqs` | Browse filters must be shareable and back-button-correct |
| Tables | TanStack Table | Four screens, one table |
| Email | Resend | Offer state-change notifications |
| Tests | Vitest (unit/integration) + Playwright (e2e) | Offer engine tests run against real Postgres |

## Directory layout

```
src/
├── app/
│   ├── layout.tsx                     root: fonts, providers, Toaster
│   ├── globals.css                    ALL design tokens live here
│   ├── page.tsx                       Home
│   ├── browse/page.tsx                Search + filters (nuqs URL state)
│   ├── lots/[slug]/page.tsx           Lot detail + offer rail
│   ├── offers/page.tsx                Buyer: My offers
│   ├── orders/[reference]/page.tsx    Order detail
│   ├── dealer/
│   │   ├── page.tsx                   Dealer dashboard
│   │   ├── lots/new/page.tsx          Create lot (5-step)
│   │   └── lots/[id]/offers/page.tsx  THE offer inbox
│   ├── auth/{login,signup,callback}/
│   └── api/
│       ├── stripe/webhook/route.ts
│       └── cron/expire-offers/route.ts
├── components/
│   ├── ui/          shadcn + 21st.dev primitives, retinted
│   ├── site/        Header, CategoryStrip, Footer, CommandMenu, NotificationBell
│   ├── lots/        LotCard, LotRow, PhotoGallery, ManifestMix, SpecTable, FilterRail
│   ├── offers/      OfferForm, OfferConfirmDialog, CountdownTimer, OfferRow,
│   │                OfferInbox, CoachingCard
│   ├── dealer/      KpiCard, LotsTable, CreateLotStepper
│   └── shared/      Money, PriceBlock, DiscountBadge, StatusPill, VerifiedMark,
│                    EmptyState, PhotoFrame
├── lib/
│   ├── supabase/{client,server,middleware}.ts
│   ├── stripe.ts
│   ├── money.ts     cents ↔ display. NEVER float.
│   ├── time.ts      countdown math, expiry thresholds
│   ├── errors.ts    PG error code → user copy (docs/COPY.md)
│   ├── utils.ts     cn()
│   └── validators/  Zod schemas, shared client + server
├── server/
│   ├── actions/     'use server' mutations — offers, lots, orders
│   └── queries/     cached server-side reads
├── types/database.ts   generated: npm run db:types
└── styles/
```

## Data flow

**Reads** — Server Components call `src/server/queries/*` directly. No client fetching for
first paint. RLS runs under the user's JWT, so a query cannot return rows the user should not
see, whatever the query says.

**Writes** — Server Actions in `src/server/actions/*`. They validate with the same Zod schema
the form used, call the Postgres function, map the error code to copy, and
`revalidatePath()`.

**Offer mutations specifically** — Server Actions call `place_offer` / `accept_offer` /
`decline_offer` RPCs. They never write to `offers` directly. There is no RLS INSERT/UPDATE
policy on that table precisely so this cannot be worked around. See `docs/OFFER_ENGINE.md`.

**Realtime** — Supabase Realtime on `offers` (dealer inbox) and `notifications` (bell). Both
are RLS-filtered on the server side, so a buyer subscribing to `offers` receives only their
own rows.

## Security posture

1. **RLS is the security model.** Every table has it enabled. The app layer is convenience.
2. **Buyers never see competing offer amounts.** One RLS policy protects the entire product
   thesis. It has dedicated tests (`OFFER_ENGINE.md` cases 11–13).
3. `SUPABASE_SERVICE_ROLE_KEY` is used in exactly two places — the Stripe webhook and the
   expiry cron. Never imported into anything under `src/app/**` that renders.
4. The Stripe webhook verifies signatures before doing anything, and is idempotent on
   `event.id`.
5. The cron route requires `Authorization: Bearer $CRON_SECRET`.
6. Uploads: signed URLs, server-side MIME and size checks, storage paths scoped by lot id.
7. Money is `bigint` cents end to end. No floats, no `numeric`, no dollar strings. `money.ts`
   is the only place formatting happens.

## Money

```
retail_value_cents   4620000   what it would ring up at retail
asking_price_cents    680000   what the dealer wants
discount_bps            8528   generated column, 85.28% off
offer.amount_cents    610000   what the buyer offered
platform_fee_cents     48800   8% of the offer (fee_bps = 800)
total_cents           610000   buyer pays this; the fee comes out of the dealer's side
```

Display: `$6,800` (no cents on lot prices), `$6,466.00` (cents on order totals). Always
`.tnum`. Always right-aligned in tables.

## Deployment

Vercel + Supabase hosted. `/api/cron/expire-offers` runs every 5 minutes via `vercel.json`
crons. Preview deploys point at a Supabase branch database.
