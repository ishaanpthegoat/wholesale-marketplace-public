# DESIGN_SYSTEM.md — prototype → components

Maps the inline-styled markup in `design/Pallet Marketplace.dc.html` onto real shadcn
components. The prototype is the layout canon; this file is how it becomes code.

**Every token is in `src/app/globals.css`. Never hard-code a hex in a component.**

## Button

Prototype markup → variant:

| Prototype | Variant | Classes |
|---|---|---|
| `background:#B04A0F; color:#fff` (Browse live lots, Review offer, Accept, Post a lot, Pay) | `default` | `bg-orange-700 hover:bg-orange-600 active:bg-orange-800` |
| `border:1px solid #E7DFD2; background:#fff` (Watch, Keep browsing, I'll arrange my own) | `secondary` | `bg-white border-sand-200 text-ink-800 hover:bg-sand-100` |
| `background:transparent; color:#6B6259` (Message dealer, Clear) | `ghost` | `hover:bg-sand-100` |
| `border:1px solid #E7DFD2; color:#A63A2C` (Decline) | `decline` | outline, `text-danger-500` |
| `border:1px solid rgba(250,247,242,.3)` (Sell your overstock, on hero) | `onDark` | `border-white/30 hover:bg-white/10` |

Sizes: `xs` 32 · `sm` 36 · `default` 40 · `lg` 44 · `xl` 48. All `rounded-full`.

**One `default` per screen.** If a screen already has one, the next is `secondary`.

## Card

| Prototype | Props |
|---|---|
| `background:#fff; border:1px solid #E7DFD2; border-radius:14px` | `<Card>` |
| `background:#F4EFE6; border-radius:14px` (trust cards, dealer bio, coaching, buyer protection) | `<Card tinted>` |
| Hover `border-color:#D4C8B5` on clickable cards | `<Card interactive>` |

No shadows on cards. Ever. Shadows are for dropdowns, modals, sticky bars.

## Badge

| Prototype | Variant |
|---|---|
| `bg:#FBE7D8; color:#B04A0F` — "85% off" | `discount` |
| `bg:#E3EDE6; color:#2F5F45` — Accepted | `accepted` |
| `bg:#F4EFE6; color:#3A342E` — tags, filter chips | `neutral` |
| `bg:rgba(33,29,25,.82); color:#FAF7F2` — countdown over a photo | `onDark` |

`declined` and `notSelected` are neutral, not red. BRAND.md §11(i).

## Screen-by-screen composition

### Home (`/`)
```
Header · CategoryStrip
HeroSection        ink-900, .photo-tone-hero image, 90°→ gradient overlay, live-count Badge,
                   Instrument Serif h1 44/48, Button default + onDark
CategoryCircles    6-up grid, aspect-square rounded-full PhotoFrame, name + count
ClosingSoonRow     4-up LotCard grid + "See all 142 →" link
TrustCards         3-up Card tinted
RecommendationsRow 4-up LotCard, from user_category_affinity
Footer
```

### Browse (`/browse`)
```
Breadcrumb
248px FilterRail (sticky top-96) + fluid results
  FilterRail   checkbox groups w/ counts, dual RangeSlider (COMPONENTS_21ST #10), Clear
  ResultsBar   count · view toggle (list/grid) · sort Select
  list view    LotRow  — 200px PhotoFrame | details | 232px price rail w/ CTA
  grid view    LotCard — 3-up
  Pagination   never infinite scroll
```
All filter state in the URL via `nuqs`. Rail becomes a Sheet below 1024.

### Lot detail (`/lots/[slug]`)
```
Breadcrumb
left column                        right rail (sticky top-96)
  PhotoGallery 4:3 + 5 thumbs        OfferCard
  ManifestCard (mix bars)              asking price XL + discount Badge
  Title + dealer + tags                PriceMeta
  SpecTable (zebra rows)               countdown callout (orange-50 / orange-100)
  Description                          OfferForm: $ input 12px radius, quick chips, hint
  DealerCard (tinted, 4 stats)         Button xl "Review offer"
                                       Button secondary "Add to watchlist"
                                       one-offer footnote
```
Freight estimate card: **omitted in v1.** Freight brokering is v2 — see PROJECT.md §7.
Below 1024, a 64px sticky bottom bar replaces the rail. BRAND.md §11(l).

### Offer confirm (Dialog)
`<DialogContent weight="commit">` — 400ms, `scale(.97)→1`, backdrop blur.
Amount in Instrument Serif, **no warning triangle**, summary table, binding checkbox,
`Submit $6,100`. Full spec in OFFER_ENGINE.md § "The confirmation UX".

### My offers (`/offers`)
```
post-submit banner (orange-50 / orange-100, check mark in an orange-700 circle)
h1 + summary line
Tabs: All · Pending · Accepted · Declined · Expired   (sliding underline, #7)
Table: lot | ask | your offer | when | status
  grid-cols  minmax(0,1fr) 130px 130px 150px 140px, numerics right-aligned .tnum
CoachingCard (tinted) — from offer_outcomes + category_clearing_stats
```

### Order (`/orders/[reference]`)
```
max-w-1120
OrderStatusPill + reference + date · h1 "{dealer} accepted your {amount} offer."
main                                rail (sticky top-96)
  StatusTimeline (dot + line)         line-item summary + Button xl "Pay {total}"
  LogisticsPanel (2-col)              payment note
                                      BuyerProtectionCard (tinted)
```

### Dealer offer inbox (`/dealer/lots/[id]/offers`)
```
h1 + "7 lots live · 3 need a decision today" + Button "Post a lot"
4-up KpiCard (Bento at 1280+, #4) with NumberTicker (#1)
OfferInbox Card
  header: lot · "Asking $6,800 · closes in 11h 42m · accepting one declines the rest"
  rows:   buyer + VerifiedMark + rating | % of ask | amount (Price M) | Accept / Decline
  grid-cols minmax(0,1fr) 120px 130px 170px
  on accept: winner → success-500, siblings cascade to "Not selected", 200ms, 40ms stagger
```

## Component inventory

Built in Phase 1 (`docs/BUILD_PLAN.md`) — everything else composes these:

`Button` `Input` `Label` `Checkbox` `Badge` `Card` `Dialog` `Tabs` `Table` `Select`
`Skeleton` `Separator` `Tooltip` `Avatar` `Progress` `Slider` `Sheet` `Command` `Toaster`

Brand-specific:

`Money` `PriceBlock` `PriceMeta` `DiscountBadge` `OfferStatusPill` `OrderStatusPill`
`CountdownTimer` `PhotoFrame` `VerifiedMark` `EmptyState` `LotCard` `LotRow` `OfferRow`
`ManifestMix` `SpecTable` `StatusTimeline` `CoachingCard` `KpiCard`

## Recurring patterns

**Table header** — `bg-sand-100`, `border-b border-sand-200`, cells
`text-[11px] font-semibold uppercase tracking-[0.08em] text-ink-600`.
Numeric columns right-aligned.

**Row divider** — `border-b border-sand-100` (lighter than the card border, on purpose).

**Section label** — `text-xs font-semibold uppercase tracking-[0.06em] text-ink-600`.

**Sticky rail** — `sticky top-24` (96px = 48px header + 34px strip + gutter).

**Metadata line** — `text-xs text-ink-600 tnum`. Never `dune-500` on light. BRAND.md §11(f).

**Photo** — always `PhotoFrame`, always 4:3 (1:1 for thumbs), always `.photo-tone`.
