import { cn } from "@/lib/utils";

/**
 * Skeletons must mirror the real layout's exact dimensions — same 4:3 frame,
 * same two text lines, same price-block height. Zero layout shift between
 * skeleton and content is the entire point. docs/COMPONENTS_21ST.md #16.
 */
function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-lg bg-sand-100",
        "after:absolute after:inset-0 after:animate-[shimmer_1.4s_infinite]",
        "after:bg-gradient-to-r after:from-transparent after:via-sand-200/70 after:to-transparent",
        "motion-reduce:after:hidden",
        className,
      )}
      aria-hidden
      {...props}
    />
  );
}

export { Skeleton };
