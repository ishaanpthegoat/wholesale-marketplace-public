# Pallet — Wholesale Marketplace

A desktop web marketplace where wholesale dealers unload excess inventory and buyers get it for
pennies on the dollar.

The core mechanic is the **one-shot offer**: one offer per buyer per lot, one number, accept or
decline. No counters, no editing, no haggling. Everything else in the product exists to support
that rule.

**Status:** planned and scaffolded. No features built yet. Start at
[docs/BUILD_PLAN.md](docs/BUILD_PLAN.md).

---

## Quick start

```bash
npm install
cp .env.example .env.local   # fill in Supabase + Stripe test keys
npm run db:start             # local Supabase stack
npm run db:reset             # apply migrations
npm run db:types             # generate src/types/database.ts
npm run dev
```

## What's here

| Path | What |
|---|---|
| `CLAUDE.md` | Working rules — read before any session |
| `docs/BUILD_PLAN.md` | **Start here.** Six phases, dependency-ordered, with exit criteria |
| `docs/PROJECT.md` | Product spec — roles, feature areas, 26-screen inventory, v1 scope |
| `docs/OFFER_ENGINE.md` | The one-shot mechanic: state machine, concurrency, errors, tests |
| `docs/BRAND.md` | Visual system. §11 lists the deliberate deviations from the prototype |
| `docs/DESIGN_SYSTEM.md` | Prototype markup → shadcn component mapping |
| `docs/ARCHITECTURE.md` | Stack, layout, data flow, security posture |
| `docs/COMPONENTS_21ST.md` | 20 components from 21st.dev, with a retint checklist |
| `docs/COPY.md` | Every user-facing string. Copy is designed, not improvised |
| `docs/ACCESSIBILITY.md` | WCAG 2.1 AA target, keyboard maps, contrast table |
| `docs/ASSETS.md` | Higgsfield generation manifest and prompts |
| `design/Pallet Marketplace.dc.html` | **The layout canon.** Open it before building a screen |
| `supabase/migrations/` | Schema, the offer engine functions, RLS |

## Stack

Next.js 15 (App Router) · React 19 · TypeScript · Tailwind v4 · shadcn/ui · Supabase
(Postgres + Auth + Storage) · Stripe Connect · Vitest + Playwright

## The rules that break the product if violated

1. **One offer per buyer per lot generation.** No edit, no raise, no withdraw, no counter.
2. **Buyers must never see another buyer's offer amount.** Enforced in RLS. Leak it and the
   one-shot offer degrades into a live auction.
3. **Never write to `offers` directly** — `place_offer` / `accept_offer` / `decline_offer` are
   the only paths. They hold the row lock.
4. **Money is `bigint` cents.** No floats outside `src/lib/money.ts`.
5. **Offers expire on a cron**, never lazily on read.
6. **No messaging before acceptance.** It becomes the negotiation channel.

## v1 scope

**In:** the 7 designed screens full-stack — Home, Browse, Lot detail, Offer confirm, My offers,
Order, Dealer offer inbox. Plus offer coaching analytics, the manifest-verification badge, and
the recommendations row.

**Out:** freight quoting and brokering (fields captured, no carrier integration), messaging UI,
ratings UI, most admin screens, saved-search alerts, mobile, disputes resolution.

## Known environment issues (2026-08-11)

`github.com`, `ui.shadcn.com`, and `21st.dev` were unreachable from the machine this was
scaffolded on — DNS resolved, TCP 443 timed out. npm and general web access were fine.

- The GitHub repo was **not** created. Run `scripts/create-github-repo.sh` when connectivity
  returns.
- `npx shadcn@latest add` will fail. The primitives in `src/components/ui/` are hand-written
  for this reason.
