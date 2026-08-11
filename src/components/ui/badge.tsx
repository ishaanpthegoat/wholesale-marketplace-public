import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

/**
 * Status treatments come straight from docs/COPY.md § "Offer statuses".
 *
 * Note `declined` and `notSelected` are NEUTRAL, not red. A declined offer is
 * the worst moment in the product and painting it red makes it feel like the
 * buyer did something wrong. Red belongs to disputes and destructive actions.
 * docs/BRAND.md §11(i).
 */
const badgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full font-semibold whitespace-nowrap",
  {
    variants: {
      variant: {
        neutral: "bg-sand-100 text-ink-800",
        /** The pennies-on-the-dollar badge. One per card. */
        discount: "bg-orange-100 text-orange-700 tnum",
        pending: "bg-sand-100 text-ink-800",
        accepted: "bg-success-100 text-success-700",
        declined: "bg-sand-100 text-ink-600",
        notSelected: "bg-sand-100 text-ink-600",
        expired: "bg-sand-100 text-dune-500",
        warning: "bg-[#F7EEDB] text-[#8A651F]",
        danger: "bg-[#F6E4E1] text-danger-500",
        onDark: "bg-white/10 text-sand-50",
      },
      size: {
        sm: "h-[22px] px-2.5 text-xs",
        default: "h-6 px-3 text-xs",
        lg: "h-[26px] px-3 text-xs",
      },
    },
    defaultVariants: { variant: "neutral", size: "default" },
  },
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {
  /** Renders the small leading status dot. */
  dot?: boolean;
}

function Badge({ className, variant, size, dot = false, children, ...props }: BadgeProps) {
  return (
    <span className={cn(badgeVariants({ variant, size }), className)} {...props}>
      {dot && <span className="size-1.5 rounded-full bg-current" aria-hidden />}
      {children}
    </span>
  );
}

export { Badge, badgeVariants };
