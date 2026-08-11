"use client";

import * as React from "react";
import { Clock } from "lucide-react";

import { cn } from "@/lib/utils";
import { formatRemaining, tickIntervalMs, urgencyClass, urgencyOf } from "@/lib/time";

interface CountdownTimerProps {
  closesAt: string | Date;
  /** "Closes in 11h 42m" vs bare "11h 42m". */
  prefix?: string;
  showIcon?: boolean;
  className?: string;
}

/**
 * The offer window is the pressure in this product and it appears in five
 * places. One component, one clock.
 *
 * The colour scale is fixed by docs/BRAND.md §11(e) and is deliberately NEVER
 * orange — orange means "this is the primary action", and a clock is not one.
 *
 * `aria-live` is off on purpose. A screen reader announcing every tick is
 * torture; the value is exposed on <time datetime> so it can be read on demand.
 */
export function CountdownTimer({
  closesAt,
  prefix = "Closes in",
  showIcon = true,
  className,
}: CountdownTimerProps) {
  const target = React.useMemo(() => new Date(closesAt), [closesAt]);

  // Render the server-side value first so there is no hydration mismatch,
  // then take over on the client.
  const [now, setNow] = React.useState<Date | null>(null);

  React.useEffect(() => {
    setNow(new Date());
    let timeout: ReturnType<typeof setTimeout>;

    const schedule = () => {
      const interval = tickIntervalMs(target);
      if (interval === 0) return;
      timeout = setTimeout(() => {
        setNow(new Date());
        schedule();
      }, interval);
    };

    schedule();
    return () => clearTimeout(timeout);
  }, [target]);

  const reference = now ?? target;
  const urgency = urgencyOf(target, now ?? undefined);
  const remaining = formatRemaining(target, now ?? undefined);
  const closed = urgency === "closed";
  const underAnHour = !closed && target.getTime() - reference.getTime() < 3_600_000;

  return (
    <span
      className={cn(
        "tnum inline-flex items-center gap-1.5 text-[13px] font-medium",
        urgencyClass[urgency],
        underAnHour && "animate-[urgent-pulse_2s_ease-in-out_infinite] motion-reduce:animate-none",
        className,
      )}
    >
      {showIcon && <Clock className="size-[13px] shrink-0" strokeWidth={2.75} aria-hidden />}
      <time dateTime={target.toISOString()}>{closed ? "Closed" : `${prefix} ${remaining}`}</time>
    </span>
  );
}
