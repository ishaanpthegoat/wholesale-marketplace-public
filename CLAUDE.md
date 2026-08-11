# CLAUDE.md

Pallet — a wholesale liquidation marketplace built on one-shot offers.

## Read first

| Doc | When |
|---|---|
| `docs/OFFER_ENGINE.md` | **Before touching anything offer-related.** Non-negotiable. |
| `docs/BUILD_PLAN.md` | Start of a build session — phases, order, exit criteria |
| `docs/BRAND.md` | Any visual work. §11 lists deliberate deviations from the prototype. |
| `docs/PROJECT.md` | Product spec, roles, v1 scope |
| `docs/ARCHITECTURE.md` | Stack, directory layout, data flow, security posture |
| `docs/COPY.md` | Any user-facing string. Copy is designed, not improvised. |
| `docs/COMPONENTS_21ST.md` | Adding a component |
| `design/Pallet Marketplace.dc.html` | **The layout canon.** Open it before building a screen. |

## The rules that break the product if violated

1. **One offer per buyer per lot generation.** No edit, no raise, no withdraw, no counter.
2. **Buyers must never see another buyer's offer amount.** Enforced in RLS. If you write a
   query, an API route, or a Realtime subscription that could leak a competing amount, you have
   broken the product thesis, not just a permission.
3. **Never write to `offers` directly.** `place_offer` / `accept_offer` / `decline_offer` /
   `expire_offers` are the only paths. They hold the row lock. There is intentionally no RLS
   INSERT/UPDATE policy on that table.
4. **Money is `bigint` cents.** No floats, no `numeric`, no dollar strings outside
   `src/lib/money.ts`.
5. **Offers expire on the cron, never lazily on read.**
6. **No messaging before acceptance.** It would become the negotiation channel.

## Design rules

- The `.dc.html` prototype is the layout canon. BRAND.md §11 lists the deliberate deviations —
  apply those, follow the prototype for everything else.
- **One primary orange button per screen.** Orange means action. It is not a surface color.
- Pill buttons (`999px`), 14px cards, 18px modals, 12px inputs.
- Every number gets `.tnum`. Prices align in columns. No exceptions.
- Every product photo goes through `.photo-tone` inside a `sand-100` 4:3 frame.
- **Declined is not red.** `ink-600` on `sand-100`. Red is for disputes and destructive actions.
- `auto_declined` reads as "Not selected", never "Declined".
- Motion: transform and opacity only. Durations from BRAND.md §8. Nothing bounces or spins.
  Everything respects `prefers-reduced-motion`.
- Tokens live in `src/app/globals.css`. Never hard-code a hex in a component.

## Commands

```bash
npm run dev          # Next.js, turbopack
npm run db:start     # local Supabase
npm run db:reset     # re-apply migrations
npm run db:types     # regenerate src/types/database.ts — run after every migration
npm run db:seed
npm run typecheck
npm run test         # vitest
npm run test:e2e     # playwright
npm run stripe:listen
```

## Conventions

- Server Components by default. `'use client'` only for genuine interactivity.
- Mutations are Server Actions in `src/server/actions/`, reads are in `src/server/queries/`.
- One Zod schema per form in `src/lib/validators/`, shared by client and server.
- Filter and pagination state lives in the URL via `nuqs`. Browse must be shareable and
  back-button-correct.
- After any migration: `npm run db:types`.
- Error surfaces map Postgres codes through `src/lib/errors.ts` to `docs/COPY.md`. Never show a
  raw Postgres message.

## Known environment issues (2026-08-11)

`github.com`, `api.github.com`, `ui.shadcn.com`, and `21st.dev` were all unreachable from this
machine — DNS resolved, TCP 443 timed out. `registry.npmjs.org` and general web access were
fine, so this looks like host-level filtering rather than an outage.

Consequences:
- The GitHub repo was **not** created. Run `scripts/create-github-repo.sh` once connectivity
  returns.
- `npx shadcn@latest add` will fail. The primitives in `src/components/ui/` are hand-written for
  this reason. Add more by hand from Radix docs rather than debugging the network.
