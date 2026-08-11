/**
 * Seed data. Run with `npm run db:seed` against the LOCAL stack only.
 *
 * PLACEHOLDER — implement in Phase 0 of docs/BUILD_PLAN.md.
 *
 * What the 7 screens need in order to be built honestly:
 *
 *  - 8 categories matching docs/ASSETS.md (Electronics, Apparel, Home, Tools,
 *    Beauty, Toys, Grocery, Mixed Lots)
 *  - 3 dealer companies: one verified with a long history (Kestrel Liquidation,
 *    Reno NV, 9 years, 4.8 / 312 deals), one verified and new, one unverified
 *  - 2 buyer profiles, one with a strong reliability record and one with a
 *    renege on file — the dealer inbox has to render both
 *  - ~24 lots across every status: draft, live, sold, expired. Vary the offer
 *    windows so the countdown renders in all four urgency states (>24h, 6-24h,
 *    <6h, closed). Include one lot with 40 offers and one with zero — both are
 *    listed as edge cases in DESIGN_PROMPT and both break naive layouts.
 *  - ~40 offers covering pending / accepted / declined / auto_declined /
 *    expired, including a buyer who used their expiry retry (attempt = 2)
 *  - 3 orders, one at each of awaiting_payment, paid, delivered
 *  - Enough accepted offers in one category that category_clearing_stats
 *    returns a real median — otherwise the coaching card renders empty and you
 *    end up designing against a blank
 *
 * Photos: point at placeholder files in public/generated/ until the Higgsfield
 * assets exist. Do NOT seed with clean studio product shots — the entire layout
 * is designed to survive ugly warehouse phone photos, and seeding pretty images
 * hides the problem the design exists to solve.
 */

async function seed() {
  throw new Error("Not implemented — see docs/BUILD_PLAN.md Phase 0.");
}

seed().catch((error) => {
  console.error(error);
  process.exit(1);
});
