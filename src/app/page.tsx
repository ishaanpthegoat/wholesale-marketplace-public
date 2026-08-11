import Link from "next/link";

import { Button } from "@/components/ui/button";

/**
 * PLACEHOLDER. The real home page is Phase 3 of docs/BUILD_PLAN.md — hero,
 * category circles, "Closing soon", trust cards, recommendations row. Build it
 * against design/Pallet Marketplace.dc.html.
 */
export default function HomePage() {
  return (
    <main className="mx-auto flex max-w-[720px] flex-1 flex-col justify-center gap-6 px-5 py-24">
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-dune-500">
        Scaffold only
      </p>

      <h1 className="font-display text-[44px] leading-[1.08] tracking-[-0.02em] text-ink-900">
        Wholesale lots at 80–95% off retail.
      </h1>

      <p className="max-w-[46ch] text-base leading-[1.55] text-ink-600">
        Nothing here is built yet. The plan, the schema, and the design system are. Start with{" "}
        <code className="rounded bg-sand-100 px-1.5 py-0.5 text-[13px]">docs/BUILD_PLAN.md</code>.
      </p>

      <div className="flex gap-2.5">
        <Button size="lg" asChild>
          <Link href="/browse">Browse live lots</Link>
        </Button>
        <Button size="lg" variant="secondary" asChild>
          <Link href="/dealer">Sell your overstock</Link>
        </Button>
      </div>
    </main>
  );
}
