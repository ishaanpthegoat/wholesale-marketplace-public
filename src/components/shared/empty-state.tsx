import Image from "next/image";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

interface EmptyStateProps {
  /** One blunt line. "No offers yet." — never "Looks like it's quiet in here." */
  title: string;
  description?: string;
  /** Higgsfield-generated, from public/generated/. Decorative only. */
  illustration?: string;
  action?: { label: string; href: string };
  className?: string;
}

export function EmptyState({
  title,
  description,
  illustration,
  action,
  className,
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center gap-4 rounded-xl bg-sand-100 px-6 py-14 text-center",
        className,
      )}
    >
      {illustration && (
        <div className="relative size-24 overflow-hidden rounded-full bg-sand-200">
          <Image
            src={illustration}
            alt=""
            aria-hidden
            fill
            sizes="96px"
            className="object-cover photo-tone"
          />
        </div>
      )}

      <div className="space-y-1.5">
        <p className="font-heading text-[17px] font-semibold text-ink-900">{title}</p>
        {description && <p className="max-w-[44ch] text-sm text-ink-600">{description}</p>}
      </div>

      {action && (
        <Button variant="secondary" size="sm" asChild>
          <a href={action.href}>{action.label}</a>
        </Button>
      )}
    </div>
  );
}
