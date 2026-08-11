# BRAND.md — Visual System (v2)

> **v2 supersedes v1.** The `.dc.html` prototype in `design/` is the source of truth for
> shape, chrome, and layout. v1's 6px-radius / borders-only / no-pill rules are dead.
> Everything below matches the prototype, plus the taste changes listed in §11.

## 1. The feeling

Hermès orange over dune. Warm, dry, expensive-looking, restrained.

A sand-colored trading floor. Serious tools for people moving real money. The orange is a
signal, not a wallpaper. If a screen starts to look like a retail flash-sale banner, pull it back.

Three words: **warm, dry, precise.**

## 2. Color tokens

### Brand orange — accent and action only

| Token | Hex | Use |
|---|---|---|
| `orange-900` | `#6E2D07` | Deepest pressed state, rarely used |
| `orange-800` | `#8F3B0B` | Pressed state on primary button; link hover |
| `orange-700` | `#B04A0F` | **Primary button fill.** Orange text on light backgrounds. Links. 5.5:1 with white. |
| `orange-600` | `#D1590F` | Primary button hover |
| `orange-500` | `#E8631A` | The brand orange. Logo mark, focus ring, active underline, icon accents. **Never behind white text** — 3.4:1. |
| `orange-400` | `#EE8342` | Hover tints on dark chrome |
| `orange-300` | `#F4A574` | Orange text on `ink-900` chrome (7.2:1 on `#211D19`). Charts. |
| `orange-200` | `#F9D9C2` | Border on tinted callouts |
| `orange-100` | `#FBE7D8` | Discount badge background, selected rows |
| `orange-50`  | `#FDF4EC` | Faint highlight blocks, the countdown callout |

### Dune neutrals — the actual UI

| Token | Hex | Use |
|---|---|---|
| `sand-50`  | `#FAF7F2` | Page background; text on dark chrome |
| `sand-100` | `#F4EFE6` | Tinted card background, table header, photo frame, hairline dividers |
| `sand-200` | `#E7DFD2` | Card borders, dividers |
| `sand-300` | `#D4C8B5` | Card border on hover, secondary button border, disabled outlines |
| `dune-500` | `#A3937A` | Muted metadata, placeholder text, footer links, strikethrough MSRP |
| `ink-600`  | `#6B6259` | Secondary text, labels, table body secondary |
| `ink-800`  | `#3A342E` | Body text; **secondary nav bar background** |
| `ink-900`  | `#211D19` | Headings, primary text; **header + footer chrome background** |
| `white`    | `#FFFFFF` | Card surfaces, input fields |

### Status

| Token | Hex | On | Use |
|---|---|---|---|
| `success-700` | `#2F5F45` | `success-100` | Accepted badge text |
| `success-500` | `#3F7D5C` | white | Verified mark, accepted fill, "Accepted" pill |
| `success-100` | `#E3EDE6` | — | Accepted badge background |
| `warning-500` | `#B4832B` | — | Countdown 6–24h remaining, pending action |
| `danger-500`  | `#A63A2C` | — | Countdown <6h, decline action label, disputes, destructive |
| `info-500`    | `#4A6B82` | — | Neutral system notices |

Status colors are muted on purpose so they sit next to orange without fighting it.

### Usage rules

1. **One primary orange button per screen.** Everything else is secondary (white fill, `sand-200`
   border, `ink-800` text) or ghost.
2. Page backgrounds are `sand-50`. Chrome (header, footer) is `ink-900`. Never orange surfaces.
3. Orange is reserved for: the primary CTA, the logo mark, the focus ring, the active nav
   underline, the discount badge, the countdown callout, and the dealer's **Accept** action.
4. **Decline is an outline button with `danger-500` text on white** — never a filled red button.
   Accepting must feel easier than declining.
5. **Declined is not an error.** Declined offers render in `ink-600` on `sand-100`. Red is for
   disputes, cancellations, and destructive confirmations only. See §11(i).
6. Body copy is never orange. Use `ink-900` / `ink-800`.
7. Any orange with white text on top must be `orange-700` or darker.

### Verified contrast (WCAG 2.1)

| Pair | Ratio | Verdict |
|---|---|---|
| `ink-900` on `sand-50` | 14.4:1 | AAA |
| `ink-800` on `white` | 11.0:1 | AAA |
| `ink-600` on `sand-50` | 5.6:1 | AA |
| `ink-600` on `sand-100` | 5.2:1 | AA |
| `dune-500` on `sand-50` | 2.6:1 | **Decorative / non-text only** |
| `dune-500` on `ink-900` | 5.9:1 | AA — this is why footer links use it |
| `sand-50` on `ink-900` | 14.4:1 | AAA |
| white on `orange-700` | 5.5:1 | AA |
| white on `orange-600` | 4.1:1 | Large text only (≥18.66px bold / 24px) |
| white on `orange-500` | 3.4:1 | **UI components only, never text** |
| `orange-700` on `orange-100` | 5.2:1 | AA — the discount badge |
| `orange-300` on `ink-900` | 7.2:1 | AAA — orange text on dark chrome |
| `success-700` on `success-100` | 6.1:1 | AA |
| `danger-500` on `white` | 5.9:1 | AA |
| `warning-500` on `white` | 4.2:1 | Large text / with icon only |
| `ink-900` on `orange-500` | 5.7:1 | AA |

`dune-500` on `sand-50` fails for text. The prototype uses it for metadata lines
(`$566 per pallet`, `Kestrel Liquidation · closes in 4h`). **Fix:** those lines move to
`ink-600` (5.6:1). `dune-500` survives only on `ink-900` chrome and as icon/divider color.

## 3. Typography

Three tiers. This is a taste change from v1 — see §11(j).

| Tier | Family | Where |
|---|---|---|
| **Display** | `Instrument Serif`, 400 | Wordmark, landing hero H1, the confirm-modal amount. Sparingly — three places. |
| **Heading** | `Instrument Sans`, 500/600 | H1–H3, card titles, KPI values, prices |
| **Body / UI** | `Inter`, 400/500/600 | Everything else. All numerals, all tables, all labels. |

Fallback chain if Instrument is unavailable: `Inter Tight` → `system-ui`. The prototype was
built on Inter Tight and still reads correctly with it.

**Numerals: `font-variant-numeric: tabular-nums` on every price, quantity, percentage,
countdown, and table cell.** No exceptions. Prices must align in columns.

### Scale (1280 default)

| Style | Size / Line | Weight | Tracking | Family |
|---|---|---|---|---|
| Hero | 44 / 48 | 400 | -0.02em | Display |
| H1 | 28 / 34 | 600 | -0.015em | Heading |
| H2 | 24 / 30 | 600 | -0.01em | Heading |
| H3 | 17 / 24 | 600 | -0.01em | Heading |
| Price XL | 38 / 42 | 600 | -0.02em | Heading, tabular |
| Price L | 26 / 30 | 600 | -0.015em | Heading, tabular |
| Price M | 22 / 26 | 600 | -0.01em | Heading, tabular |
| Body L | 15 / 23 | 400 | 0 | Body |
| Body | 14 / 20 | 400 | 0 | Body |
| Body S | 13 / 19 | 400 | 0 | Body |
| Meta | 12 / 16 | 400/500 | 0 | Body |
| Label | 12 / 16 | 600 | 0.06em, UPPERCASE | Body |
| Table head | 11 / 14 | 600 | 0.08em, UPPERCASE | Body |

## 4. Shape

| Element | Radius |
|---|---|
| Buttons (all sizes) | `999px` — pill |
| Status badges, pills, filter chips | `999px` |
| Inputs, selects, textareas | `12px` |
| Search field (header) | `999px` |
| Thumbnails, small media | `8–10px` |
| Cards, panels, table containers | `14px` |
| Modals | `18px` |
| Avatars, logo mark, category circles | `999px` |

Pill buttons + 14px cards is the prototype's signature. Do not mix in squared buttons.

## 5. Depth

- **Default card:** `white` surface, `1px solid sand-200`, no shadow. Hover: border → `sand-300`.
- **Tinted panel:** `sand-100` fill, no border, no shadow. Used for trust cards, dealer bio,
  coaching card, buyer-protection note.
- **Shadows only for things that float:**
  - `shadow-sm` `0 1px 2px rgba(33,29,25,.05)` — sticky bars
  - `shadow-md` `0 4px 16px rgba(33,29,25,.08)` — dropdowns, popovers, toasts
  - `shadow-lg` `0 8px 28px rgba(33,29,25,.14)` — modals
- **Modal backdrop:** `rgba(33,29,25,.5)` + `backdrop-filter: blur(3px)`.
- **Focus ring:** `2px solid orange-500`, `outline-offset: 2px`. Always visible on keyboard focus,
  on every interactive element, on both light and dark chrome.

## 6. Spacing and layout

- 4px base scale: 4, 6, 8, 10, 12, 14, 16, 20, 22, 24, 28, 32, 40, 48, 56, 60.
- **Max content width 1440px**, 20px gutters. Order and settings pages narrow to 1120px.
- Desktop breakpoints: **1024** (min supported) · **1280** (default) · **1440+** (wide).
- Card grids: 4 columns at 1280+, 3 at 1024.
- Browse: `248px` filter rail + fluid results. Rail becomes a Sheet below 1024.
- Lot detail: gallery + specs fluid, `sticky top-96px` offer rail on the right.

## 7. Photography

Product photos are user-uploaded warehouse shots. They will be ugly. Every layout must survive that.

- Fixed **4:3** crop inside a `sand-100` frame. Thumbnails 1:1.
- **Every product image gets the tone treatment:** `filter: saturate(.7) contrast(.95)`.
  This is the single most important thing making mismatched photos cohere. Ship it as one
  utility class (`.photo-tone`), never inline.
- Missing photo → `sand-100` frame with a `dune-500` pallet glyph, never a broken image.
- No stock photos of smiling people. Ever.

## 8. Motion

| Interaction | Duration | Easing |
|---|---|---|
| Hover, color, border | 120ms | `ease-out` |
| Dropdowns, popovers, tooltips | 160ms | `cubic-bezier(.16,1,.3,1)` |
| Panels, sheets, tabs underline | 200ms | `cubic-bezier(.16,1,.3,1)` |
| Modals | 250ms | `cubic-bezier(.16,1,.3,1)` |
| **Offer confirm modal** | 400ms | `cubic-bezier(.22,1,.36,1)` — the one deliberate exception |
| Sibling auto-decline cascade | 200ms per row, 40ms stagger | `ease-out` |

Rules:
- Animate `transform` and `opacity` only. Never `height`, `top`, `width`.
- Enter: ease-out. Exit: faster (~70% of enter duration), ease-in.
- No bounce, no spring overshoot, no confetti, no spinning.
- Everything wrapped in `@media (prefers-reduced-motion: reduce)` → duration `0.01ms`,
  no transform, opacity only.
- Interruptible: a hover-out mid-animation reverses from the current position.

## 9. Voice

Plain, direct, a little blunt. Trade language, not startup language.

- "One offer. No going back." not "Make your best offer!"
- "$4,200 · 91% off retail" not "Amazing savings"
- "No offers yet." not "Looks like it's quiet in here."
- "Declined" not "Rejected" or "Unsuccessful".
- Never exclamation marks outside of a genuine error.

Full string inventory lives in `docs/COPY.md`.

## 10. Generated assets — Higgsfield MCP

All non-UI visual assets are generated with the **Higgsfield MCP**, not stock, not hand-drawn in code.

| Need | Tool |
|---|---|
| Hero background loop | `generate_video` |
| Category tiles, empty-state art | `generate_image_batch` |
| Product cutouts from uploads | `remove_background` |
| Low-res upload repair | `upscale_image` |
| Aspect-ratio refit | `reframe` / `outpaint_image` |
| Camera shaping on hero | `motion_control` |

Rules:
1. Every prompt carries the palette explicitly: *warm sand, dune tones, ink, one Hermès orange accent*.
2. Subject matter: pallets, shrink wrap, cardboard, warehouse aisles, forklifts, shipping labels,
   dry desert light. **No faces.**
3. Slow, restrained motion. Seamless loops under 8 seconds.
4. Hero video is decorative. The site fully works with it disabled and it respects
   `prefers-reduced-motion`.
5. Call `models_explore(action:'recommend')` first if unsure about duration or aspect ratio.
6. Export video as MP4 + WebM + poster frame. Images at 1x and 2x.
7. Everything lands in `public/generated/` with the exact prompt recorded in `docs/ASSETS.md`.

## 11. Taste changes applied on top of the prototype

The prototype is the layout canon. These are the deliberate deviations. Each one has a reason.

**(a) The header search submit is no longer orange.**
The prototype fills it `orange-500`. That puts brand orange in the persistent chrome on every
single screen, which breaks the one-primary-orange rule before a page has even rendered — the
"Make an offer" CTA has to compete with it. Change: `ink-800` fill, `sand-50` icon, `orange-500`
focus ring. Orange returns to meaning *action*.

**(b) The double nav bar collapses to one bar plus a quiet category strip.**
`ink-900` over `ink-800` at 76px total is a lot of chrome for a dense app. Change: keep both
rows, but the category row drops to 34px, loses its pill backgrounds, and renders as plain
`dune-500` text with an `orange-500` 2px underline on the active item. Reads as a tool, not a
storefront.

**(c) Photo tone treatment becomes a token, not an inline filter.**
`filter: saturate(.7) contrast(.95)` is repeated 9 times inline in the prototype. It is a great
idea and it becomes `.photo-tone`. Add a `sand-100` frame behind it so transparent PNGs don't
punch holes.

**(d) One discount badge per card, maximum.**
Some prototype cards carry the badge on the image *and* next to the price. Pick one: image
overlay for grid cards, inline-with-price for list rows.

**(e) The countdown color is a formal scale, and it is never orange.**
`>24h` → `ink-600`. `6–24h` → `warning-500`. `<6h` → `danger-500`. `<1h` adds a slow 2s
opacity pulse (disabled under reduced-motion). The `orange-50` countdown callout on the lot
detail rail stays orange because it sits directly above the CTA and reads as one unit.

**(f) Metadata lines move off `dune-500`.**
`dune-500` on `sand-50` is 2.6:1 — it fails AA for text. Every metadata line
(`Retail $46,200 · $1.63 per unit`, `Kestrel Liquidation · Reno, NV`) moves to `ink-600`.
`dune-500` survives on dark chrome, as strikethrough MSRP paired with an adjacent readable
price, and as icon/divider color.

**(g) The confirm modal loses the warning triangle.**
An alert triangle reads as *you have made a mistake*. This is a commitment, not an error. Change:
replace the icon with the offer amount itself, set large in Instrument Serif — the number is the
subject of the screen. Modal enters over 400ms from `scale(.97)` with a backdrop blur. The
submit button unlocks on checkbox + a 600ms dwell, so nobody muscle-memories through it.
Full spec in `docs/OFFER_ENGINE.md`.

**(h) Accepting an offer plays the cascade.**
"Accepting one declines the rest" is the most dramatic beat in the product and the prototype
swaps it instantly. Change: accepted row fills `success-500` first; then sibling rows desaturate
and their action buttons cross-fade to "Auto-declined" on a 40ms stagger down the list. 200ms
each. It takes under a second total and it makes the mechanic legible.

**(i) The declined state is quiet, not red.**
The brief calls this the worst moment in the product. Declined offers render `ink-600` on
`sand-100` with a neutral dot — the same visual weight as "Expired". Red is reserved for
disputes and destructive actions. The decline notice is immediately followed by the coaching
card (how far off, category median) and three similar live lots. No apology copy, no
"unfortunately". Just the number and the next move.

**(j) Three-tier type instead of two.**
Inter Tight everywhere is competent and forgettable. The brief asks for *expensive*.
Change: `Instrument Serif` for the wordmark, the landing hero, and the confirm-modal amount —
three places, nothing else. `Instrument Sans` for headings and prices. `Inter` keeps every
numeral, table, and label, because tabular figures in dense financial tables is exactly what
Inter is for. If this reads too editorial in practice, the fallback is pure Inter Tight and
nothing else changes.

**(k) Screen-reader labels on Accept/Decline carry the consequence.**
`aria-label="Accept $6,100 offer from Ridgeline Trading. This declines 4 other offers."`
The visual design makes the cascade obvious; the label has to as well.

**(l) A compact sticky offer bar at 1024.**
The lot-detail offer rail is `sticky top-96px`, which works at 1280+. At 1024 it scrolls away.
Change: below 1024, a 64px bottom bar pins with the price, countdown, and "Review offer".
