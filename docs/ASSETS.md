# ASSETS.md — Higgsfield generation manifest

All non-UI visuals are generated with the **Higgsfield MCP**. No stock. No hand-drawn SVG
illustration. Everything lands in `public/generated/` and every prompt is recorded here so any
asset can be regenerated later.

**Status: nothing generated yet.** This is the shot list for Phase 6 of `docs/BUILD_PLAN.md`.

## Rules for every generation

1. The palette goes in every prompt, explicitly: *warm sand, dune tones, ink, one Hermès orange
   accent*.
2. Subject matter: pallets, shrink wrap, cardboard, warehouse aisles, forklifts, shipping
   labels, dry desert light. **No faces. No people.**
3. Motion is slow and restrained. Seamless loops under 8 seconds. Nothing spins or flashes.
4. Call `models_explore(action:'recommend')` first when unsure about duration or aspect ratio.
5. Video exports as MP4 + WebM + a poster frame. Images at 1x and 2x.
6. Fill in the actual prompt used in the tables below after generating — an approximation is
   not reproducible.

## Shot list

### Hero background loop

| | |
|---|---|
| File | `public/generated/hero-warehouse.{mp4,webm}` + `hero-warehouse-poster.jpg` |
| Dimensions | 2560×1080, 6–8s seamless loop |
| Used in | Home hero, behind the `ink-900` gradient overlay, `.photo-tone-hero` |
| Tool | `generate_video`, then `motion_control` if the camera move needs shaping |
| Prompt | *(record after generating)* Slow lateral drift across shrink-wrapped pallet stacks in a warehouse aisle, warm dry desert light through high windows, sand and dune tones, deep ink shadows, a single Hermès orange accent on a forklift or strap, no people, no faces, cinematic, seamless loop, subtle dust in the light |

Decorative only. The site works fully with it disabled. `aria-hidden`. Under
`prefers-reduced-motion` the poster frame renders instead — and never autoplay with sound.

### Category tiles — 8, generated as one batch

`generate_image_batch` so they share a look. 800×800, rendered as circles on Home.

| Category | File | Subject |
|---|---|---|
| Electronics | `cat-electronics.jpg` | Boxed consumer electronics banded on a pallet |
| Apparel | `cat-apparel.jpg` | Poly-bagged garments in open cartons |
| Home | `cat-home.jpg` | Stacked flat-pack home goods, shrink-wrapped |
| Tools | `cat-tools.jpg` | Power tool cases stacked on a pallet |
| Beauty | `cat-beauty.jpg` | Small cosmetic cartons in a gaylord box |
| Toys | `cat-toys.jpg` | Toy cartons banded, mixed sizes |
| Grocery | `cat-grocery.jpg` | Shelf-stable cases on a pallet, warehouse aisle |
| Mixed Lots | `cat-mixed.jpg` | Mismatched cartons shrink-wrapped together |

Shared prompt suffix: *warm sand and dune tones, ink shadows, dry desert warehouse light, one
small Hermès orange accent, no people, no faces, no text or legible branding, square crop,
consistent lighting across the set*

"No legible branding" matters — these are category tiles, not endorsements.

### Empty-state illustrations — 5, one batch

400×400, rendered in a 96px circle. Decorative: `alt=""`, `aria-hidden`.

| State | File | Subject |
|---|---|---|
| No offers yet | `empty-offers.jpg` | A single empty pallet on a swept concrete floor |
| No lots yet | `empty-lots.jpg` | An empty warehouse bay, roller door half open |
| No search results | `empty-search.jpg` | An empty aisle receding into warm haze |
| Watchlist empty | `empty-watchlist.jpg` | A bare clipboard hook on a warehouse post |
| No notifications | `empty-notifications.jpg` | A clean, empty shipping label spindle |

Shared suffix: *warm sand and dune palette, ink shadows, dry light, quiet and still, no people,
no text, soft square crop*

Deliberately understated. "No offers yet." is a blunt statement of fact; the art should not
apologise for it either.

### Textures

| Asset | File | Use |
|---|---|---|
| Paper grain | `texture-grain.png` | Optional 2–3% overlay on `sand-50` sections |
| Dune gradient | `texture-dune.jpg` | Fallback behind the hero if video is disabled |

Grain is optional and should be tested at 1x before it ships — at the wrong opacity it just
looks like a compression artifact.

## Not generating

| | Why |
|---|---|
| Product photos | Real user uploads. `.photo-tone` is what makes them cohere. |
| Icons | `lucide-react`, `strokeWidth={2.75}` to match the prototype |
| Avatars | Company initials on `sand-200`. Never a scraped logo. |
| Anything with a face | BRAND.md §10 rule 2 |
| Dashboard ambient loops | Cut. Motion behind a data table is noise, not atmosphere. |
