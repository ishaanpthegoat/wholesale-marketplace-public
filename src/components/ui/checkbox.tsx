"use client";

import * as React from "react";
import * as CheckboxPrimitive from "@radix-ui/react-checkbox";
import { Check } from "lucide-react";

import { cn } from "@/lib/utils";

const Checkbox = React.forwardRef<
  React.ElementRef<typeof CheckboxPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof CheckboxPrimitive.Root>
>(({ className, ...props }, ref) => (
  <CheckboxPrimitive.Root
    ref={ref}
    className={cn(
      "peer size-[18px] shrink-0 rounded-md border-2 border-sand-300 bg-white",
      "transition-colors duration-[120ms] ease-out hover:border-dune-500",
      "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-500",
      "disabled:cursor-not-allowed disabled:opacity-45",
      // orange-700, not orange-500 — the check mark is white on top of it.
      "data-[state=checked]:border-orange-700 data-[state=checked]:bg-orange-700",
      className,
    )}
    {...props}
  >
    <CheckboxPrimitive.Indicator className="flex items-center justify-center text-white">
      <Check className="size-3" strokeWidth={3.25} />
    </CheckboxPrimitive.Indicator>
  </CheckboxPrimitive.Root>
));
Checkbox.displayName = CheckboxPrimitive.Root.displayName;

export { Checkbox };
