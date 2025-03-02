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

  const authCookie = cookies.get("parallel-auth");
  let parallelAuth: ParallelToken | null = null;
  if (authCookie) {
    parallelAuth = JSON.parse(
      cookies.get("parallel-auth") ?? "{}",
    ) as ParallelToken;
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
    ).then(async (r) => await r.json());
  }

  return {
    season,
    parallelAuth,
    account,
  };
};
