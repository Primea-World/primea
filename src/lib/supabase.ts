import { createClient, type User } from "@supabase/supabase-js";
import {
  PUBLIC_SUPABASE_ANON_KEY,
  PUBLIC_SUPABASE_URL,
} from "$env/static/public";
import { type Writable, writable } from "svelte/store";
import type { Database } from "./database.types";
import type { ParallelProfile } from "./parallelProfile";

const options = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
};

export const supabase = writable(
  createClient<Database>(
    PUBLIC_SUPABASE_URL,
    PUBLIC_SUPABASE_ANON_KEY,
    options,
  ),
);
export const user: Writable<User | undefined> = writable(undefined);

export function userName(
  user?: User,
  parallelProfile?: ParallelProfile | null,
): string {
  return (
    parallelProfile?.django_profile?.username ??
      user?.identities?.at(0)?.identity_data?.["full_name"] ??
      user?.identities?.at(0)?.identity_data?.["name"] ??
      user?.identities?.at(0)?.identity_data?.["nickname"] ??
      user?.email ??
      "unknown"
  );
}
