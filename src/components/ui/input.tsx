import * as React from "react";

import { cn } from "@/lib/utils";

/**
 * Inputs are 12px radius — NOT pills. Only controls that trigger an action are
 * pills. docs/BRAND.md §4.
 */
const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className, type, ...props }, ref) => (
    <input
      type={type}
      ref={ref}
      className={cn(
        "flex h-10 w-full rounded-lg border border-sand-200 bg-white px-3.5 py-2 text-sm text-ink-900",
        "placeholder:text-dune-500",
        "transition-colors duration-[120ms] ease-out hover:border-sand-300",
        "focus-visible:border-orange-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-500",
        "disabled:cursor-not-allowed disabled:border-sand-300 disabled:bg-sand-100 disabled:text-ink-600",
        "aria-invalid:border-danger-500",
        // Money and quantity inputs must never shift width as digits change.
        type === "number" && "tnum",
        className,
      )}
      {...props}
    />
  ),
);
Input.displayName = "Input";

export { Input };
