import { BadgeCheck } from "lucide-react";

import { cn } from "@/lib/utils";

/**
 * A verified dealer passed document review. success-500 (#3F7D5C) — muted on
 * purpose so it sits next to the brand orange without fighting it.
 */
export function VerifiedMark({
  size = 13,
  withLabel = false,
  className,
}: {
  size?: number;
  withLabel?: boolean;
  className?: string;
}) {
  return (
    <span className={cn("inline-flex items-center gap-1.5 text-success-500", className)}>
      <BadgeCheck
        style={{ width: size, height: size }}
        strokeWidth={2.75}
        className="shrink-0"
        aria-hidden={withLabel}
        aria-label={withLabel ? undefined : "Verified dealer"}
      />
      {withLabel && <span className="text-[13px] font-medium">Verified dealer</span>}
    </span>
  );
}
