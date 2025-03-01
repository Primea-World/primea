import { createClient, type User } from "@supabase/supabase-js";
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from "$env/static/public"
import { writable, type Writable } from "svelte/store";
import type { Database } from "./database.types";

const options = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
}

export const supabase = writable(createClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, options));
export const user: Writable<User | undefined> = writable(undefined);

export function userName(user?: User): string {
  return (
    user?.identities?.at(0)?.identity_data?.["full_name"] ??
    user?.identities?.at(0)?.identity_data?.["name"] ??
    user?.identities?.at(0)?.identity_data?.["nickname"] ??
    user?.email ??
    "unknown"
  );
}
