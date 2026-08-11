import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

import type { Database } from "@/types/database";

/**
 * Server-side client. Runs under the user's JWT, so RLS applies — a query
 * physically cannot return rows the user shouldn't see, whatever the query says.
 * This is the client you want 99% of the time.
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Called from a Server Component. Middleware refreshes the session,
            // so this is safe to swallow.
          }
        },
      },
    },
  );
}

/**
 * Bypasses RLS entirely. Used in exactly two places: the Stripe webhook and the
 * offer-expiry cron. Never import this into anything that renders.
 * docs/ARCHITECTURE.md § "Security posture".
 */
export function createServiceClient() {
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { cookies: { getAll: () => [], setAll: () => {} } },
  );
}
