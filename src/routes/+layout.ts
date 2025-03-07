import { browser } from "$app/environment";
import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";
import type { Database } from "$lib/database.types.js";
import { createBrowserClient, createServerClient } from "@supabase/ssr";

export const ssr = false;

export const load = async ({ data, fetch, depends }) => {
  depends('supabase:auth')

  const supabase = browser
    ? createBrowserClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
      global: {
        fetch,
      },
    })
    : createServerClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
      global: {
        fetch,
      },
      cookies: {
        getAll() {
          return data.cookies
        },
      },
    })

  const { data: { session } } = await supabase.auth.getSession();
  const { data: { user } } = await supabase.auth.getUser();
  if (user) {
    const { parallelAuth, pasProfile } = data;
    if (parallelAuth) {
      // Check if the account has changed
      // If it has, update the user metadata
      // This is to ensure that the user is always using the correct account
      pasProfile?.then(async (profile) => {

        if (!user.app_metadata.parallel_account ||
          user.app_metadata.parallel_account.account_id !== profile.account_id
        ) {
          const response = await fetch(`/profile/parallel/${profile.account_id}?token=${parallelAuth.access_token}&supabaseId=${user.id}`, {
            method: "POST",
          });
          if (!response.ok) {
            console.error("Failed to update user metadata");
          }
        }
      });
    }
  }

  return { ...data, supabase, user, session };
}