import type { Metadata } from "next";
import { Inter, Instrument_Sans, Instrument_Serif } from "next/font/google";

import "./globals.css";

// Three tiers. See docs/BRAND.md §3 and the reasoning in §11(j).
// Inter keeps every numeral and table, because tabular figures in dense
// financial tables is exactly what it is for.
const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const instrumentSans = Instrument_Sans({
  subsets: ["latin"],
  variable: "--font-instrument-sans",
  display: "swap",
});

// Wordmark, landing hero, and the confirm-modal amount. Three places, nothing else.
const instrumentSerif = Instrument_Serif({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-instrument-serif",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Pallet — wholesale lots at 80–95% off retail",
    template: "%s · Pallet",
  },
  description:
    "Verified dealers, manifests attached. One offer per lot — so the price you see is the price people actually pay.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${instrumentSans.variable} ${instrumentSerif.variable}`}
    >
      <body className="flex min-h-screen flex-col bg-sand-50">{children}</body>
    </html>
  );
}
