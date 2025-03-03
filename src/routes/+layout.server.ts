import { createClient } from "@supabase/supabase-js";
import type { LayoutServerLoad } from "./$types";
import type { Database } from "$lib/database.types";
import {
  PUBLIC_SUPABASE_ANON_KEY,
  PUBLIC_SUPABASE_URL,
} from "$env/static/public";
import type { ParallelToken } from "$lib/parallelToken";

const options = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
};

const supabase = createClient<Database>(
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY,
  options,
);

export const load: LayoutServerLoad = async ({ cookies, fetch }) => {
  const nowUTC = new Date().toUTCString();
  const season = supabase
    .from("seasons")
    .select("*")
    .lte("season_start", nowUTC)
    .gte("season_end", nowUTC)
    .single();

  let parallelAuth: ParallelToken | null = null;
  const authCookie = cookies.get("parallel-auth");
  if (authCookie) {
    parallelAuth = JSON.parse(
      cookies.get("parallel-auth") ?? "{}",
    ) as ParallelToken;

    // Check if the token is expired
    if (parallelAuth.expires_at && parallelAuth.expires_at < Date.now()) {
      // Token is expired, set to null
      parallelAuth = await (await fetch("/oauth", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refresh_token: parallelAuth.refresh_token,
        }),
      })).json();
    }
  }

  let account = null;
  if (parallelAuth) {
    account = fetch(
      "https://parallel.life/api/pgs/api/v1/players/0/profiles/parallel/",
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${parallelAuth.access_token}`,
        },
      },
    ).then(async (r) => {
      if (r.status !== 200) {
        return null;
      }
      return await r.json();
    });
  }

  return {
    season,
    parallelAuth,
    account,
  };
};
