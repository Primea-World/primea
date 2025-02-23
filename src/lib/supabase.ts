import { createClient } from "@supabase/supabase-js";
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from "$env/static/public"
import { writable } from "svelte/store";

const options = {
  db: {
    schema: 'public',
  },
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
}
export const supabase = writable(createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, options));
