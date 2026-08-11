import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    // Lot photos live in Supabase Storage; generated brand assets are local.
    remotePatterns: [
      { protocol: "https", hostname: "*.supabase.co", pathname: "/storage/v1/object/public/**" },
    ],
    formats: ["image/avif", "image/webp"],
  },
  experimental: {
    // Server Actions carry manifest CSVs and lot photo batches.
    serverActions: { bodySizeLimit: "8mb" },
  },
};

export default nextConfig;
