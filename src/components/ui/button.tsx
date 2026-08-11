import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

/**
 * Every button in Pallet is a pill (999px). See docs/BRAND.md §4.
 *
 * `default` is the one primary orange button allowed per screen. If a screen
 * already has one, the next button is `secondary` or `ghost`.
 *
 * `decline` is deliberately an outline with danger-coloured text, never a
 * filled red button — accepting an offer must feel easier than declining one.
 * BRAND.md §2 rule 4.
 */
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-full font-medium " +
    "transition-colors duration-[120ms] ease-out " +
    "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-500 " +
    "disabled:pointer-events-none disabled:opacity-45 " +
    "[&_svg]:pointer-events-none [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default:
          "bg-orange-700 text-white font-semibold hover:bg-orange-600 active:bg-orange-800",
        secondary:
          "bg-white text-ink-800 border border-sand-200 hover:bg-sand-100 hover:border-sand-300",
        ghost: "bg-transparent text-ink-600 hover:bg-sand-100 hover:text-ink-900",
        /** Dealer's Decline. Quiet on purpose. */
        decline:
          "bg-white text-danger-500 font-semibold border border-sand-200 hover:bg-sand-50 hover:border-sand-300",
        /** Genuinely destructive: cancel an order, delete a lot, resolve a dispute. */
        destructive: "bg-danger-500 text-white font-semibold hover:bg-[#8E3125]",
        /** On the ink-900 header and footer chrome. */
        onDark:
          "bg-transparent text-sand-50 border border-white/30 hover:bg-white/10 hover:border-white/45",
        link: "bg-transparent text-orange-700 underline-offset-4 hover:text-orange-800 hover:underline",
      },
      size: {
        xs: "h-8 px-3 text-[13px]",
        sm: "h-9 px-4 text-[13px]",
        default: "h-10 px-5 text-sm",
        lg: "h-11 px-6 text-[15px]",
        /** The offer CTA and the confirm-modal submit. */
        xl: "h-12 px-6 text-[15px]",
        icon: "size-10 p-0",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />
    );
  },
);
Button.displayName = "Button";

export { Button, buttonVariants };
