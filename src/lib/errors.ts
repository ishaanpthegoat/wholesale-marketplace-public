/**
 * Postgres error codes raised by the offer engine → the exact strings in
 * docs/COPY.md. A raw Postgres message must never reach a user.
 */

export const OFFER_ERRORS: Record<string, string> = {
  AUTH_REQUIRED: "Sign in to make an offer.",
  ACCOUNT_SUSPENDED: "Your account is suspended. Contact support.",
  LOT_NOT_FOUND: "This lot no longer exists.",
  LOT_NOT_LIVE: "This lot is no longer taking offers.",
  LOT_CLOSED: "Offers closed on this lot.",
  CANNOT_OFFER_ON_OWN_LOT: "You can't offer on your own lot.",
  INVALID_AMOUNT: "Enter an amount above $0.",
  QUANTITY_EXCEEDS_LOT: "That's more units than the lot holds.",
  WHOLE_LOT_ONLY: "This lot sells whole only.",
  PICKUP_NOT_OFFERED: "This dealer doesn't offer pickup.",
  ALREADY_OFFERED: "You've already offered on this lot. One offer per lot.",
  RETRY_ALREADY_USED: "You've used both offers on this lot.",
  OFFER_NOT_FOUND: "That offer no longer exists.",
  OFFER_NOT_PENDING: "This offer was already decided.",
  OFFER_EXPIRED: "This offer expired before you could accept it.",
  NOT_YOUR_LOT: "You don't have access to this lot.",
  LOT_NOT_RELISTABLE: "Only expired or removed lots can be relisted.",
};

/**
 * On a failed submit, saying "nothing was submitted" is the whole point —
 * a buyer who thinks a binding offer might have gone through is worse off
 * than one who knows it didn't.
 */
export const GENERIC_ERROR = "Something broke on our end. Nothing was submitted.";

export function offerErrorMessage(error: unknown): string {
  const message =
    typeof error === "object" && error !== null && "message" in error
      ? String((error as { message: unknown }).message)
      : "";

  for (const code of Object.keys(OFFER_ERRORS)) {
    if (message.includes(code)) return OFFER_ERRORS[code]!;
  }
  return GENERIC_ERROR;
}
