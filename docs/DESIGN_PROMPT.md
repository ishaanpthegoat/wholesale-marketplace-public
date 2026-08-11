# DESIGN_PROMPT.md

Paste everything below the line into Claude Design. Attach `PROJECT.md` and `BRAND.md` with it.

---

I am building **Pallet**, a desktop web marketplace where wholesale dealers unload excess inventory and buyers get it for pennies on the dollar. I have attached two files: `PROJECT.md` (the product spec) and `BRAND.md` (the visual system). Read both fully before you start. Do not contradict them.

Your job: design the full product and hand me back a single `design.md` file that a developer can build from without asking follow-up questions.

## The one thing that matters most

The core mechanic is the **one-shot offer**. A buyer gets exactly one offer per lot. No editing, no raising, no counter-offers, no haggling. The dealer only sees Accept or Decline.

This has to be felt in the design, not just stated in a tooltip. The offer flow should feel deliberate and slightly heavy, the way signing something feels. Design the confirmation step so a buyer genuinely stops and thinks. On the dealer side, Accept should be the easy path and Decline should be a quieter outline button, so the visual weight nudges toward deals closing.

Show me how you handle these moments specifically:
- Buyer sees a lot they want and hits "Make an offer"
- The confirm step: "One offer. No going back. Submit $X?"
- Buyer's offer sits pending, with a visible countdown to expiry
- Dealer's offer inbox: several offers on one lot, ranked, each with buyer rating and verified status
- Dealer accepts one and the rest auto-decline
- Buyer opens the app to a declined offer (this is the worst moment in the product, make it not feel humiliating)

## Scope

Design all 26 screens listed in section 6 of `PROJECT.md`. Desktop only, 1280px default, degrade cleanly to 1024 and expand to 1440.

Prioritize in this order:
1. Lot detail + offer flow + offer confirmation
2. Dealer offer inbox and accept/decline
3. Browse/search with filters
4. Create lot (multi-step form, this is long and needs real thought)
5. Dealer dashboard and buyer dashboard
6. Orders, shipping, messaging
7. Landing page
8. Admin

## Design constraints from BRAND.md, restated

- Hermès orange (`#E8631A`) is an accent only. Backgrounds are warm sand. One primary orange button per screen.
- Primary buttons fill with `#B04A0F`, not `#E8631A` — the lighter orange fails contrast behind white label text. See the contrast table in `BRAND.md` and do not introduce color pairs that are not on it without checking the ratio.
- Borders over shadows. White cards on `#FAF7F2` page background with 1px `#E7DFD2` borders.
- Prices and quantities use tabular figures and must align in columns.
- Product photos are ugly user-uploaded warehouse shots. Every layout must survive that. Fixed 4:3 crop inside a sand frame.
- No stock photos of smiling people. Copy is blunt trade language, not startup language.
- Warm, dry, precise. If a screen starts to look like a retail flash-sale site, pull it back.

## Use Higgsfield for all generated visuals

Use the **Higgsfield MCP** to actually generate the visual assets, not just describe them. Do not use stock imagery.

Generate and include:
- A hero background video loop for the landing page: slow drift over shrink-wrapped pallets in warm dry warehouse light, sand and ink tones, single orange accent, seamless, 6-8 seconds. Use `generate_video`, then `motion_control` if the camera move needs shaping.
- 6-8 category tiles as images (Electronics, Apparel, Home, Tools, Beauty, Toys, Grocery, Mixed Lots). Use `generate_image_batch` so they share a look.
- Empty-state illustrations: no offers yet, no lots yet, no search results, watchlist empty.
- Ambient loops or subtle motion for the dashboard header and the offer confirmation moment.
- Any decorative texture (paper grain, dune gradient) the system needs.

Rules for every generation:
- Put the palette in the prompt every time: warm sand, dune, ink, one Hermès orange accent.
- Subject matter is pallets, cardboard, shrink wrap, warehouse aisles, forklifts, shipping labels, dry desert light. No faces.
- Motion is slow and restrained. No spinning, flashing, or bouncing.
- Call `models_explore(action:'recommend')` first if unsure which model fits the aspect ratio or duration.
- Export video as MP4 + WebM + a poster frame. Export images at 1x and 2x.
- Record every prompt you used so assets can be regenerated later.

## What `design.md` must contain

Write it so Claude Code can build from it cold. Include:

1. **Design tokens** — full color, type, spacing, radius, shadow, and motion tokens as a table, plus a ready-to-paste Tailwind `theme.extend` config.
2. **Component library** — every component with variants, sizes, all states (default, hover, active, focus, disabled, loading, error, empty), and exact token values. At minimum: Button, Input, Select, Textarea, Checkbox, Radio, Badge, StatusPill, Card, LotCard, PriceBlock, DiscountBadge, Table, Tabs, Modal, Drawer, Toast, Tooltip, Avatar, CompanyBadge, VerifiedMark, FilterPanel, Pagination, Stepper, EmptyState, CountdownTimer, OfferRow, RatingStars, FileUpload, PhotoGallery.
3. **Screen-by-screen specs** — for each of the 26 screens: layout grid, what goes where, component composition, real sample content (real-looking prices, quantities, company names, not lorem ipsum), and the responsive behavior at 1024 / 1280 / 1440.
4. **Flow diagrams** — the offer lifecycle end to end, the create-lot flow, the order/fulfillment flow.
5. **States and edge cases** — loading skeletons, error states, empty states, long text overflow, missing photos, a lot with 40 offers, a lot with 0 offers, an expired lot, a suspended account.
6. **Microcopy** — actual final strings for every button, label, error, confirmation, empty state, and notification. Blunt trade voice. This is part of the design, not a to-do for later.
7. **Accessibility** — WCAG 2.1 AA. Contrast ratios for every color pair you use, keyboard order for the offer flow, focus management in modals, screen reader labels for the accept/decline actions, `prefers-reduced-motion` behavior for all Higgsfield video.
8. **Asset manifest** — every Higgsfield asset you generated: filename, dimensions, format, where it is used, and the exact prompt used to make it.
9. **Open questions** — anything you had to guess at, flagged clearly at the end.

## Format

- One file, `design.md`, plus the generated asset files.
- Use tables for tokens and component states. Use ASCII or Mermaid for layout diagrams and flows.
- Be specific. Write `padding: 16px 24px`, not "generous padding". Write `#E8631A`, not "orange".
- Skip the design philosophy essay. Every section should be something a developer can act on.

Start with the token system and the offer flow. Show me those first before you build out the rest, so I can course-correct early.
