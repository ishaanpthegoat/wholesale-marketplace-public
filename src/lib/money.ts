/**
 * Money is bigint cents, everywhere, always. This module is the ONLY place
 * cents become a string. No float ever touches a price. See docs/ARCHITECTURE.md.
 */

const USD_WHOLE = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
});

const USD_EXACT = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

/**
 * Lot prices, offer amounts, retail values — no cents shown. `$6,800`
 * Rounds to the nearest dollar for display only; the stored value is untouched.
 */
export function formatPrice(cents: number | bigint): string {
  return USD_WHOLE.format(Number(cents) / 100);
}

/** Order totals, fees, line items — cents shown. `$6,466.00` */
export function formatTotal(cents: number | bigint): string {
  return USD_EXACT.format(Number(cents) / 100);
}

/** Per-unit and per-pallet figures, which are often under a dollar. `$1.63` */
export function formatUnitPrice(cents: number | bigint): string {
  const n = Number(cents) / 100;
  return n < 10 ? USD_EXACT.format(n) : USD_WHOLE.format(n);
}

/** Basis points → display percent. `8528` → `85%` */
export function formatBps(bps: number, decimals = 0): string {
  return `${(bps / 100).toFixed(decimals)}%`;
}

/** How far off retail this price is, in basis points. 8528 = 85.28% off. */
export function discountBps(retailCents: number, priceCents: number): number {
  if (retailCents <= 0) return 0;
  return Math.max(0, 10_000 - Math.round((priceCents * 10_000) / retailCents));
}

/** An offer as a share of the asking price, in basis points. 8971 = 89.71% of ask. */
export function pctOfAskBps(askCents: number, offerCents: number): number {
  if (askCents <= 0) return 0;
  return Math.round((offerCents * 10_000) / askCents);
}

/** Integer division, matching the SQL in accept_offer() exactly. */
export function platformFeeCents(amountCents: number, feeBps: number): number {
  return Math.floor((amountCents * feeBps) / 10_000);
}

/** Parses a typed offer amount. Accepts `6,100`, `$6100`, `6100.50`. */
export function parseAmountToCents(input: string): number | null {
  const cleaned = input.replace(/[$,\s]/g, "");
  if (!/^\d+(\.\d{0,2})?$/.test(cleaned)) return null;
  return Math.round(Number(cleaned) * 100);
}

export function perUnitCents(totalCents: number, units: number): number {
  return units > 0 ? Math.round(totalCents / units) : 0;
}
