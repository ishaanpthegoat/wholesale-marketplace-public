# COMPONENTS_21ST.md — 21st.dev component plan

20 components pulled from the [21st.dev](https://21st.dev) registry (shadcn-compatible,
copy-paste, Tailwind + Radix + Motion). Minimum ask was 15; these 20 are the ones that
actually earn their place in a warm/dry/precise trading floor.

> **Network note (2026-08-11):** `21st.dev` and `ui.shadcn.com` are both unreachable from
> this machine — DNS resolves, TCP 443 times out. Same block that stopped the GitHub push.
> `registry.npmjs.org` responds fine, so npm installs work. **Exact registry slugs below are
> unverified** and must be confirmed against the live registry before install. The *pattern*
> for each is described precisely enough to hand-build if a slug has moved.

## Install

```bash
npx shadcn@latest add "https://21st.dev/r/<author>/<component>"
```

Every component lands in `src/components/ui/` and must then be retinted to the brand tokens
in `src/app/globals.css`. **Nothing ships with its registry defaults.** The retint checklist
is at the bottom of this file.

---

## The 20

### 1. Number Ticker — animated tabular numerals
**Where:** dealer KPI cards (GMV, live lots, offers awaiting decision), the discount
percentage on lot detail, the platform metrics on admin.
**Why it earns it:** BRAND.md mandates tabular figures on every number. A ticker that rolls
digits *while preserving column alignment* is the one animation that makes a dense financial
table feel alive without violating "no bouncing, no confetti". Roll duration 600ms, ease-out,
digits only — the currency symbol and separators stay fixed.
**Taste note:** never animate a price the user is about to commit to. The offer amount in the
confirm modal is static. Motion there would read as slot-machine.

### 2. Countdown Timer — live expiry
**Where:** `Closes in 11h 42m` on lot cards, lot detail, the dealer inbox header, and the
buyer's pending-offer row.
**Why:** the offer window is the pressure in the product and the prototype shows it in five
places. One component, one clock source.
**Spec:** ticks every 1s under 1h, every 30s under 24h, every 60s above. Color scale per
BRAND.md §11(e): `>24h` ink-600, `6–24h` warning-500, `<6h` danger-500. `<1h` adds a 2s
opacity pulse. `aria-live="off"` — a screen reader announcing every tick is torture; expose
the value on a `<time datetime>` and announce only at the 1h and 10m thresholds.

### 3. Blur Fade — staggered entrance
**Where:** the browse results grid, home's "Closing soon" row, dealer offer inbox rows.
**Why:** Emil Kowalski's rule — one well-orchestrated page load beats scattered
micro-interactions. 8px translate-y + opacity, 40ms stagger, 200ms each, ease-out-quint.
**Taste note:** cap the stagger at the first 12 items. A 40-row table that ripples for two
seconds is not elegant, it is slow.

### 4. Bento Grid — dealer dashboard
**Where:** `/dealer` — KPI tiles, offers-needing-decision, revenue sparkline, lots-expiring.
**Why:** the prototype uses a flat 4-up KPI row, which wastes the fact that these tiles have
wildly different information density. Bento lets "3 offers need a decision today" be twice
the size of "Lots live".
**Taste note:** asymmetry is the point, but keep the gutter on the 16px system and every
tile on the 14px card radius. No nested radii.

### 5. File Dropzone — manifests and lot photos
**Where:** create-lot step 3 (photos, min 3) and step 4 (manifest CSV/PDF/XLSX).
**Why:** genuinely functional, not decoration. Photos need drag-reorder and a 4:3 crop
preview; manifests need parse-and-preview so the dealer sees the row count before publishing.
**Spec:** dashed `sand-300` border → `orange-500` on drag-over. Per-file progress. Reject
>10MB with the exact reason. Photos preview through `.photo-tone` so the dealer sees what
buyers will see.

### 6. Photo Gallery + Lightbox
**Where:** lot detail — hero 4:3 plus a 5-up thumbnail strip.
**Why:** these are warehouse phone photos and buyers zoom in to read box labels. That is the
actual job: legibility of a pallet label, not a pretty carousel.
**Spec:** click-to-lightbox with pinch/scroll zoom, arrow-key nav, Esc to close, focus trapped
and returned to the originating thumbnail. Lightbox shows photos **untoned** — `.photo-tone`
is for grid cohesion, but a buyer inspecting a manifest needs the real image.

### 7. Animated Tabs — sliding underline
**Where:** My Offers (Pending / Accepted / Declined / Expired), order detail, dealer lots.
**Why:** the prototype uses pill tabs, which at four statuses reads as a filter bar. A shared
`layoutId` underline in `orange-500` makes it read as navigation and reuses the one sanctioned
orange accent.
**Spec:** 200ms ease-out-quint on the underline only. Content cross-fades at 120ms. Full
roving-tabindex keyboard support via Radix Tabs underneath.

### 8. Stepper / Multi-step Form — create a lot
**Where:** `/dealer/lots/new`. Five steps: Basics → Quantities & Price → Photos → Manifest &
Freight → Offer rules & Review.
**Why:** DESIGN_PROMPT called this out as "long and needs real thought". It is the highest
abandonment risk in the dealer funnel.
**Spec:** progress rail persists left at 1280+, collapses to a top bar at 1024. Autosaves to
`status='draft'` on every step change — a dealer must never lose 20 minutes of manifest entry.
Per-step Zod validation, but let them move backward freely. Live "pennies on the dollar"
preview updates as they type retail vs asking, because that ratio is the listing's whole pitch.

### 9. Data Table — TanStack + faceted filters
**Where:** dealer lots table, the offer inbox, admin verification queue, admin disputes.
**Why:** four screens, one component. Sorting, column visibility, faceted filters, sticky
header, row selection for bulk decline.
**Spec:** tabular-nums on every numeric column, right-aligned. Zebra rows on `sand-100`.
Sticky header at `top-0` inside the card. Virtualize past 100 rows.

### 10. Dual Range Slider — price and discount filters
**Where:** browse filter rail.
**Why:** the prototype ships a single-value max-price slider, which cannot express "between
$2k and $8k" — the actual query a reseller with a truck budget has.
**Spec:** two thumbs, `orange-500` track fill, `sand-200` rail. Numeric inputs bound to both
thumbs so it is keyboard- and precision-usable. Debounce URL sync at 300ms via `nuqs`.

### 11. Command Menu (⌘K)
**Where:** global, from the header.
**Why:** this is the piece that makes it feel like a trading tool rather than a storefront.
Jump to a lot, a dealer, a category, a saved search, or an order reference. Dealers live in
this app all day.
**Spec:** `cmdk`, grouped results, recents first, debounced server search at 200ms. Arrow keys
+ Enter, Esc closes, focus returns. Registers `⌘K` / `Ctrl+K` globally except inside inputs.

### 12. Sonner Toasts
**Where:** every offer state change, save confirmation, upload result.
**Why:** shadcn's canonical toast, written by the same author as the animation principles this
project follows. Stacking and swipe-dismiss are already right.
**Spec:** bottom-right, `sand-50` surface, `sand-200` border, `shadow-md`, 14px radius (not
pill — it is a surface, not a control). Success gets a `success-500` rule, not a green fill.
4s dismiss; errors are sticky.
**Taste note:** the offer submission does **not** get a toast. It gets a full inline
confirmation banner on My Offers, because a toast is too light for a binding commitment.

### 13. Animated Notification List — the bell
**Where:** header bell dropdown.
**Why:** eight notification types across two roles; the feed needs unread state and enter
animation for realtime arrivals via Supabase Realtime.
**Spec:** new items slide in from the top, 200ms, 8px translate. Unread carries an
`orange-500` 6px dot. Mark-all-read. Caps at 20 with "See all".

### 14. Marquee — the closing tape
**Where:** one line under the home hero: `142 lots closing in the next 24 hours`, scrolling
lot titles + discounts.
**Why:** a trading tape is exactly the right metaphor and it is the only decorative motion the
brand tolerates. It also solves a real cold-start problem — proving the marketplace is liquid.
**Spec:** 60s linear loop, pause on hover, `dune-500` text on `ink-900`. **Hard stop under
`prefers-reduced-motion`** — renders as a static row of three.
**Taste note:** one marquee on the entire site. Two is a casino.

### 15. Spotlight Border Card — the confirm moment
**Where:** the offer confirmation modal. Nowhere else.
**Why:** BRAND.md §8 gives this one moment permission to be heavier than everything else. A
slow `orange-500` border sweep on modal enter (one pass, 900ms, then stop) makes the commitment
feel sealed rather than dismissed.
**Spec:** one pass only — a looping beam would turn a binding contract into a loading spinner.
Disabled entirely under reduced-motion; the modal then just fades.

### 16. Shimmer Skeletons
**Where:** lot grid, lot detail, offer tables, dashboard KPIs.
**Why:** every list in this app is server-fetched and filter changes are frequent.
**Spec:** skeletons mirror the real layout's exact dimensions — same 4:3 frame, same two text
lines, same price block height. `sand-100` base, `sand-200` sweep, 1.4s. Zero layout shift
between skeleton and content, which is the entire point.

### 17. Empty State
**Where:** no offers yet, no lots yet, no search results, empty watchlist, no notifications.
**Why:** five states, and the brand has strong opinions about their copy ("No offers yet." not
"Looks like it's quiet in here.").
**Spec:** Higgsfield-generated illustration in a 96px circle, one blunt line, one action.
Illustration is decorative — `alt=""`, `aria-hidden`.

### 18. Avatar Group — watchers and competition pressure
**Where:** lot detail (`+ 12 buyers watching`), dealer inbox header (`5 offers`).
**Why:** signals demand without leaking a single offer amount, which RLS forbids and the
product thesis forbids harder. Counts and anonymous avatars only.
**Spec:** stacked, max 4 visible + overflow count, 2px `sand-50` ring. Company initials on
`sand-200`, never a scraped logo.

### 19. Animated Progress Bars — the manifest mix
**Where:** lot detail manifest breakdown (`60% small kitchen appliances / 25% textiles / 15% assorted`).
**Why:** already in the prototype as static bars. Animating the fill on scroll-into-view, once,
staggered 60ms, makes the mix scannable as a composition rather than four unrelated numbers.
**Spec:** 400ms ease-out-quint, `IntersectionObserver`, fires once. Each bar gets a distinct
tone from the dune ramp — never four different hues.

### 20. Scroll Progress + Sticky Action Bar
**Where:** lot detail below 1024, and the create-lot form.
**Why:** BRAND.md §11(l). The offer rail is `sticky top-96px`, which fails at 1024 where it
scrolls out of reach. A 64px bottom bar pins with price, countdown, and "Review offer".
**Spec:** appears when the primary rail's CTA leaves the viewport, 200ms slide + fade,
`shadow-sm`, `sand-50` surface. On create-lot it shows step progress and Save draft.

---

## Retint checklist — run on every component before committing

- [ ] All hard-coded hex swapped for brand tokens (`orange-700`, `sand-200`, `ink-900`…)
- [ ] Buttons are `999px`; surfaces are `14px`; modals are `18px`
- [ ] Every numeral has `.tnum`
- [ ] Focus ring is `2px orange-500 / offset 2px` and visible on dark chrome
- [ ] Motion respects the BRAND.md §8 duration table; nothing bounces or springs
- [ ] `prefers-reduced-motion` path tested and correct
- [ ] Contrast checked against BRAND.md §2 — no new pairs introduced without a ratio
- [ ] No purple, no violet gradients, no glassmorphism, no neon. This is a sand trading floor.
- [ ] Component does not introduce a second primary orange to a screen that already has one

## Deliberately rejected

Things in the registry that would be wrong here, recorded so nobody re-adds them:

| Component | Why not |
|---|---|
| Confetti / party effects | BRAND.md §8 bans it outright. Closing a $6,800 freight deal is not a birthday. |
| Animated gradient / aurora backgrounds | Backgrounds are `sand-50`. Full stop. |
| Testimonial marquee with faces | "No stock photos of smiling people. Ever." |
| Glassmorphism cards | Borders over shadows. Frosted glass reads as consumer SaaS. |
| Typewriter / text-scramble headlines | Blunt trade voice. A headline that types itself is a gimmick. |
| 3D card tilt on hover | Product photos are ugly warehouse shots. Tilting them does not help. |
| Infinite-scroll browse | Wholesale buyers compare and back-navigate. Pagination, always. |
