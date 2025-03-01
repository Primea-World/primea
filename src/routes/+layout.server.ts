import { createClient } from "@supabase/supabase-js";
import type { LayoutServerLoad } from "./$types";
import type { Database } from "$lib/database.types";
import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";

const options = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
}

const supabase = createClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, options);

export const load: LayoutServerLoad = async () => {
  const nowUTC = new Date().toUTCString();
  const season = supabase
    .from("seasons")
    .select("*")
    .lte("season_start", nowUTC)
    .gte("season_end", nowUTC)
    .single();

  return {
    season
  };
}