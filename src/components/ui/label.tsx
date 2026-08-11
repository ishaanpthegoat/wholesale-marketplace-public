"use client";

import * as React from "react";
import * as LabelPrimitive from "@radix-ui/react-label";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const labelVariants = cva("select-none peer-disabled:cursor-not-allowed peer-disabled:opacity-45", {
  variants: {
    variant: {
      default: "text-sm font-medium text-ink-800",
      /** The uppercase section label: "YOUR OFFER", "MAX PRICE". BRAND.md §3. */
      section: "text-xs font-semibold uppercase tracking-[0.06em] text-ink-600",
    },
  },
  defaultVariants: { variant: "default" },
});

const Label = React.forwardRef<
  React.ElementRef<typeof LabelPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root> & VariantProps<typeof labelVariants>
>(({ className, variant, ...props }, ref) => (
  <LabelPrimitive.Root ref={ref} className={cn(labelVariants({ variant }), className)} {...props} />
));
Label.displayName = LabelPrimitive.Root.displayName;

export { Label };
