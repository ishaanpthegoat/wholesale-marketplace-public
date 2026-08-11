# COPY.md — the string inventory

Voice: plain, direct, a little blunt. Trade language, not startup language. No exclamation
marks outside a genuine error. No "Oops". No emoji. Copy is part of the design, not a to-do.

## Offer flow

| Context | String |
|---|---|
| Lot rail CTA | `Review offer` |
| Rail footnote | `One offer per lot. It cannot be edited, raised or withdrawn once submitted.` |
| Quick-offer chips | `Asking` · `−10%` · `−20%` |
| Offer hint, above ask | `That's above the asking price.` |
| Offer hint, normal | `{pct}% of asking · {discount}% off retail` |
| Offer hint, very low | `Dealers rarely take under 50% of asking.` |
| Confirm title | `One offer. No going back.` |
| Confirm body | `If {dealer} accepts, this becomes a binding order. You cannot edit, raise or withdraw it, and you will not get a second offer on this lot.` |
| Confirm checkbox | `I understand this offer is binding and final.` |
| Confirm submit | `Submit {amount}` |
| Confirm cancel | `Back` |
| Post-submit banner | `Offer submitted. {amount} on {lot}.` |
| Post-submit sub | `{dealer} has {hours} hours to accept or decline. We'll email and notify you either way.` |
| Post-submit action | `Keep browsing` |

## Offer statuses

| Status | Label | Treatment |
|---|---|---|
| `pending` | `Pending` | `warning-500` dot, `ink-800` text |
| `accepted` | `Accepted` | `success-700` on `success-100` |
| `declined` | `Declined` | `ink-600` on `sand-100`. **Not red.** |
| `auto_declined` | `Not selected` | `ink-600` on `sand-100` |
| `expired` | `Expired` | `dune-500` on `sand-100` |

`auto_declined` is **"Not selected"**, never "Declined". The buyer did nothing wrong.

## Decline moment

| Context | String |
|---|---|
| Notification | `{dealer} declined your {amount} offer on {lot}.` |
| Not-selected notification | `{lot} sold. Your {amount} offer wasn't selected.` |
| Coaching, close | `Beaten by {gap}. Accepted offers in {category} ran {lo}–{hi}% above yours last month.` |
| Coaching, general | `Median accepted discount in {category} was {pct}% off retail.` |
| Coaching action | `See similar lots` |
| Retry available | `This offer expired. You get one more on this lot while it's live.` |

Never: "Unfortunately", "Sorry", "Better luck", "Don't worry".

## Dealer inbox

| Context | String |
|---|---|
| Header | `Offers — {lot}` |
| Subhead | `Asking {ask} · closes in {countdown} · accepting one declines the rest` |
| Accept | `Accept` |
| Decline | `Decline` |
| Accept a11y | `Accept {amount} offer from {buyer}. This declines {n} other offers.` |
| Decline a11y | `Decline {amount} offer from {buyer}.` |
| Accept confirm | `Accept {amount} from {buyer}? This declines the other {n} offers and marks the lot sold.` |
| Post-accept | `Accepted. {n} other offers were declined and {buyer} has been notified.` |
| Below min flag | `Below your {min} floor` |
| Empty | `No offers yet.` |
| Empty sub | `{countdown} left on the window.` |

## Errors

Every string maps to a Postgres error code in `docs/OFFER_ENGINE.md`.

| Code | String |
|---|---|
| `AUTH_REQUIRED` | `Sign in to make an offer.` |
| `ACCOUNT_SUSPENDED` | `Your account is suspended. Contact support.` |
| `LOT_NOT_LIVE` | `This lot is no longer taking offers.` |
| `LOT_CLOSED` | `Offers closed on this lot.` |
| `CANNOT_OFFER_ON_OWN_LOT` | `You can't offer on your own lot.` |
| `INVALID_AMOUNT` | `Enter an amount above $0.` |
| `WHOLE_LOT_ONLY` | `This lot sells whole only.` |
| `PICKUP_NOT_OFFERED` | `This dealer doesn't offer pickup.` |
| `ALREADY_OFFERED` | `You've already offered on this lot. One offer per lot.` |
| `RETRY_ALREADY_USED` | `You've used both offers on this lot.` |
| `OFFER_NOT_PENDING` | `This offer was already decided.` |
| `OFFER_EXPIRED` | `This offer expired before you could accept it.` |
| `NOT_YOUR_LOT` | `You don't have access to this lot.` |
| Generic 500 | `Something broke on our end. Nothing was submitted.` |

That last one matters: on a failed offer submit, say explicitly that nothing was submitted.

## Empty states

| Screen | Line | Action |
|---|---|---|
| My offers | `No offers yet.` | `Browse live lots` |
| Watchlist | `Nothing on your watchlist.` | `Browse live lots` |
| Search | `No lots match those filters.` | `Clear filters` |
| Dealer lots | `No lots posted.` | `Post a lot` |
| Dealer inbox | `No offers yet.` | — |
| Orders | `No orders yet.` | `Browse live lots` |
| Notifications | `Nothing new.` | — |

## Countdown

| Remaining | Format |
|---|---|
| > 48h | `Closes in 3 days` |
| 2–48h | `Closes in 11h 42m` |
| < 2h | `Closes in 47m` |
| < 1m | `Closing now` |
| passed | `Closed` |

## Notifications

| Type | Line |
|---|---|
| `offer.received` | `New {amount} offer on {lot}.` |
| `offer.accepted` | `{dealer} accepted your {amount} offer.` |
| `offer.declined` | `{dealer} declined your {amount} offer on {lot}.` |
| `offer.auto_declined` | `{lot} sold. Your {amount} offer wasn't selected.` |
| `offer.expired` | `Your {amount} offer on {lot} expired.` |
| `offer.expiring_soon` | `{n} offers on {lot} expire in 4 hours.` |
| `order.paid` | `Payment received for {reference}.` |
| `order.shipped` | `{reference} is in transit. {carrier} {tracking}.` |
| `message.new` | `New message on {reference}.` |
| `search.match` | `{n} new lots match "{search}".` |

## Order

| Context | String |
|---|---|
| Title | `{dealer} accepted your {amount} offer.` |
| Pay CTA | `Pay {total}` |
| Payment note | `Funds are held by Pallet until you confirm pickup. Payment due within {n} business days.` |
| Buyer protection | `If the lot materially differs from the manifest, open a dispute within 3 days of pickup and we hold the funds until it's resolved.` |
| Freight (v2 stub) | `Freight booking is coming. Arrange your own carrier for now — the dealer's dock hours and dimensions are above.` |

## Marketing

| Context | String |
|---|---|
| Hero H1 | `Wholesale lots at 80–95% off retail.` |
| Hero body | `Verified dealers, manifests attached, freight details up front. One offer per lot — so the price you see is the price people actually pay.` |
| Hero primary | `Browse live lots` |
| Hero secondary | `Sell your overstock` |
| Live badge | `{n} lots closing in the next 24 hours` |
| Footer | `Wholesale liquidation for verified businesses. Listing is free; Pallet takes a fee when a lot sells.` |

Note the hero body drops the prototype's "freight quoted before you offer" — freight brokering
is v2 and the copy must not promise it.
