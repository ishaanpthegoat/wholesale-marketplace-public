# ACCESSIBILITY.md

Target: **WCAG 2.1 AA**. Desktop only, 1024 minimum.

## Contrast

Every pair in use is in the table in `docs/BRAND.md` §2. **Do not introduce a pair that is not
on that table without computing its ratio and adding it.**

Two failures from the prototype are already fixed:

1. `dune-500` on `sand-50` is **2.6:1** — fails for text. Every metadata line moves to
   `ink-600` (5.6:1). `dune-500` survives only on `ink-900` chrome (5.9:1), as strikethrough
   MSRP next to a readable price, and as icon/divider colour. BRAND.md §11(f).
2. `orange-500` behind white text is **3.4:1**. Primary buttons fill `orange-700` (5.5:1).
   `orange-500` is for the logo mark, focus rings, active underlines, and icons only.

## Keyboard

**Focus ring:** `2px solid orange-500`, `outline-offset: 2px`, on every interactive element,
visible on both `sand-50` and `ink-900` chrome. Never `outline: none` without a replacement.

### The offer flow — the path that must be perfect

```
Lot detail
  Tab → skip link → header → search → category strip → gallery thumbs
      → offer amount input → quick-offer chips → Review offer → Add to watchlist
  Enter on "Review offer" opens the dialog

Confirm dialog
  focus moves to the dialog container on open
  focus is trapped
  Tab order: binding checkbox → Submit → Back
  Space toggles the checkbox
  Esc closes (reversible until submit)
  focus returns to "Review offer" on close
  Submit is disabled until checkbox + 600ms dwell — announced via aria-describedby,
    not just visually
```

The 600ms dwell is a safety interlock, not decoration. It applies under reduced motion too.

### Dealer inbox

Accept and Decline are real `<button>`s in DOM order per row. Labels carry the consequence,
because the visual cascade is not available to a screen reader:

```html
<button aria-label="Accept $6,100 offer from Ridgeline Trading. This declines 4 other offers.">
  Accept
</button>
<button aria-label="Decline $5,400 offer from Bayline Wholesale.">Decline</button>
```

After accepting, an `aria-live="polite"` region announces:
`Accepted. 4 other offers were declined and Ridgeline Trading has been notified.`

The cascade animation is decorative — the announcement carries the meaning.

## Screen readers

| Element | Treatment |
|---|---|
| Product photos | `alt` = the lot title. Gallery thumbs: `alt="Photo 2 of 6"` |
| Empty-state illustrations | `alt=""` + `aria-hidden` — decorative |
| Hero video | `aria-hidden`, decorative, site works fully without it |
| Countdown | `<time datetime>`, `aria-live="off"`. Announcing every tick is torture. Announce at the 1h and 10m thresholds only. |
| Discount badge | `aria-label="85 percent off retail"` — "85% off" alone is ambiguous read aloud |
| Status pills | Text, not colour-only. The dot is `aria-hidden`. |
| Verified mark | `aria-label="Verified dealer"` when unlabelled |
| Manifest mix bars | `role="img"` with an `aria-label` summarising the whole mix |
| Offer table | Real `<table>` with `<th scope="col">`. Not a div grid. |
| Toasts | `role="status"`, polite |
| Errors | `role="alert"`, tied to the field via `aria-describedby` |

## Colour is never the only signal

- Offer status: coloured pill **plus** the text label.
- Countdown urgency: colour **plus** the diminishing number **plus** the pulse under 1h.
- Below-minimum offers in the dealer inbox: a text flag, not just a tint.
- Form errors: an icon and text, not a red border alone.

## Motion

Every animation sits inside the reduced-motion guard in `globals.css`. Specifically:

| Animation | Reduced-motion behaviour |
|---|---|
| Confirm dialog 400ms scale + blur | 120ms opacity fade only. Dwell interlock still applies. |
| Auto-decline cascade | Instant state swap; the `aria-live` announcement is unchanged |
| Home marquee | Hard stop — renders as a static row of three |
| Blur-fade stagger | No transform, content appears immediately |
| Number ticker | Final value rendered directly |
| Countdown pulse under 1h | No pulse; colour still shifts to `danger-500` |
| Skeleton shimmer | Static `sand-100` block |
| Border sweep on confirm | Removed entirely |

## Forms

- Every input has a visible `<label>`. Placeholders are never the label.
- The offer amount input is `inputmode="numeric"` with `$` as a static prefix outside the
  field, so screen readers don't read the symbol as part of the value.
- Errors announce on blur, not on every keystroke.
- The create-lot stepper announces step changes via `aria-live` and keeps a heading per step.
- The manifest/photo dropzone has a real `<input type="file">` behind it. Drag-and-drop is an
  enhancement, never the only path.

## Testing

- `axe-core` in Playwright on all 7 screens — zero violations before merge.
- Manual: complete the entire offer flow with keyboard only, then again with VoiceOver.
- Zoom to 200% at 1280 — no horizontal scroll, no clipped content.
- Run with `prefers-reduced-motion: reduce` forced and verify each row of the table above.
- Forced-colors / Windows High Contrast: focus rings and borders must survive.
