import Image from "next/image";
import { Package } from "lucide-react";

import { cn } from "@/lib/utils";

interface PhotoFrameProps {
  src?: string | null;
  alt?: string;
  ratio?: "4/3" | "1/1" | "16/9";
  /**
   * `.photo-tone` is what makes a wall of mismatched user-uploaded warehouse
   * photos read as one palette. Turn it off only in the lightbox, where a buyer
   * is inspecting an actual box label and needs the true image.
   * docs/BRAND.md §7 / §11(c).
   */
  toned?: boolean;
  className?: string;
  sizes?: string;
  priority?: boolean;
}

export function PhotoFrame({
  src,
  alt = "",
  ratio = "4/3",
  toned = true,
  className,
  sizes = "(max-width: 1280px) 33vw, 320px",
  priority = false,
}: PhotoFrameProps) {
  return (
    <div
      className={cn(
        "relative w-full overflow-hidden bg-sand-100",
        ratio === "4/3" && "aspect-[4/3]",
        ratio === "1/1" && "aspect-square",
        ratio === "16/9" && "aspect-video",
        className,
      )}
    >
      {src ? (
        <Image
          src={src}
          alt={alt}
          fill
          sizes={sizes}
          priority={priority}
          className={cn("object-cover", toned && "photo-tone")}
        />
      ) : (
        // Never a broken image icon. A dealer who skipped photos should look
        // under-prepared, not like the site is broken.
        <div className="flex size-full items-center justify-center">
          <Package className="size-8 text-dune-500" strokeWidth={1.5} aria-hidden />
        </div>
      )}
    </div>
  );
}
