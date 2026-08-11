/**
 * Countdown formatting and the urgency scale. See docs/BRAND.md §11(e) and
 * docs/COPY.md § "Countdown". The countdown is NEVER orange — orange means
 * "this is the primary action", and a clock is not an action.
 */

export type Urgency = "calm" | "soon" | "urgent" | "closed";

export function urgencyOf(closesAt: Date | string, now: Date = new Date()): Urgency {
  const ms = new Date(closesAt).getTime() - now.getTime();
  if (ms <= 0) return "closed";
  const hours = ms / 3_600_000;
  if (hours < 6) return "urgent";
  if (hours < 24) return "soon";
  return "calm";
}

export const urgencyClass: Record<Urgency, string> = {
  calm: "text-ink-600",
  soon: "text-warning-500",
  urgent: "text-danger-500",
  closed: "text-dune-500",
};

/** `3 days` · `11h 42m` · `47m` · `Closing now` · `Closed` */
export function formatRemaining(closesAt: Date | string, now: Date = new Date()): string {
  const ms = new Date(closesAt).getTime() - now.getTime();
  if (ms <= 0) return "Closed";

  const minutes = Math.floor(ms / 60_000);
  if (minutes < 1) return "Closing now";

  const hours = Math.floor(minutes / 60);
  if (hours >= 48) return `${Math.floor(hours / 24)} days`;
  if (hours >= 2) return `${hours}h ${minutes % 60}m`;
  return `${minutes}m`;
}

/**
 * How often the timer should re-render. Ticking every second on a 3-day
 * countdown is pure wasted work.
 */
export function tickIntervalMs(closesAt: Date | string, now: Date = new Date()): number {
  const ms = new Date(closesAt).getTime() - now.getTime();
  if (ms <= 0) return 0;
  const hours = ms / 3_600_000;
  if (hours < 1) return 1_000;
  if (hours < 24) return 30_000;
  return 60_000;
}
