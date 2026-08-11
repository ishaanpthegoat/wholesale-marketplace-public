import { cn } from "@/lib/utils";
import { discountBps, formatBps, formatPrice } from "@/lib/money";
import { Badge } from "@/components/ui/badge";

const sizes = {
  xl: "text-[38px] leading-[42px] tracking-[-0.02em]",
  lg: "text-[26px] leading-[30px] tracking-[-0.015em]",
  md: "text-[22px] leading-[26px] tracking-[-0.01em]",
  sm: "text-base leading-5 tracking-[-0.01em]",
} as const;

interface PriceBlockProps {
  askingCents: number;
  retailCents?: number;
  size?: keyof typeof sizes;
  /**
   * `badge` shows "85% off" next to the price. `strike` shows the crossed-out
   * retail value instead. Never both — one discount treatment per card.
   * docs/BRAND.md §11(d).
   */
  discount?: "badge" | "strike" | "none";
  className?: string;
}

export function PriceBlock({
  askingCents,
  retailCents,
  size = "md",
  discount = "badge",
  className,
}: PriceBlockProps) {
  const bps = retailCents ? discountBps(retailCents, askingCents) : 0;

  return (
    <div className={cn("flex items-baseline gap-2", className)}>
      <span className={cn("tnum font-heading font-semibold text-ink-900", sizes[size])}>
        {formatPrice(askingCents)}
      </span>

      {retailCents && discount === "badge" && (
        <Badge variant="discount" size="sm">
          {formatBps(bps)} off
        </Badge>
      )}

      {retailCents && discount === "strike" && (
        <span className="tnum text-[13px] text-dune-500 line-through">
          {formatPrice(retailCents)}
        </span>
      )}
    </div>
  );
}

/**
 * The metadata line under a price: "Retail $46,200 · $566 per pallet · $1.63 per unit".
 *
 * ink-600, NOT dune-500 — dune-500 on sand-50 is 2.6:1 and fails AA for text.
 * docs/BRAND.md §11(f).
 */
export function PriceMeta({ children, className }: React.PropsWithChildren<{ className?: string }>) {
  return <div className={cn("tnum text-xs text-ink-600", className)}>{children}</div>;
}
