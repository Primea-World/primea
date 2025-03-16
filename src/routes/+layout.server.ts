import type { LayoutServerLoad } from "./$types";
import { type ParallelToken } from "$lib/parallelToken";
import { PARALLEL_PROFILE_URL, type ParallelProfile } from "$lib/parallelProfile";
import { PARALLEL_PGS_URL, type ParallelPGSAccount } from "$lib/parallelPGSAccount";
import { PARALLEL_PAS_URL, type ParallelPasProfile } from "$lib/parallelPASProfile";


export const load: LayoutServerLoad = async ({ locals: { supabase }, cookies, fetch, depends }) => {
  depends('supabase:auth');

  const nowUTC = new Date().toUTCString();
  const season = supabase
    .from("seasons")
    .select("*")
    .lte("season_start", nowUTC)
    .gte("season_end", nowUTC)
    .single().then((season) => {
      if (season.error) {
        return null;
      }
      return season.data;
    });

  const { data: { user } } = await supabase.auth.getUser();
  let parallelAuth: ParallelToken | null = user?.user_metadata.parallel;
  let account: Promise<ParallelProfile> | undefined = undefined;
  let pasProfile: Promise<ParallelPasProfile> | undefined = undefined;
  let pgsAccount: Promise<ParallelPGSAccount> | undefined = undefined;

  // Check if the token is expired
  if (parallelAuth?.expires_at && parallelAuth.expires_at < Date.now()) {
    // Token is expired, refresh it
    parallelAuth = await fetch("/oauth", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        refresh_token: parallelAuth.refresh_token,
      }),
    }).then(async (response) => await response.json<ParallelToken>()).catch((e) => {
      console.error("Error refreshing token", e);
      return null;
    });
    if (parallelAuth) {
      parallelAuth.expires_at = Date.now() + (parallelAuth.expires_in - 300) * 1000;
    }
  }

  if (parallelAuth) {
    account = fetch(
      PARALLEL_PROFILE_URL,
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${parallelAuth?.access_token}`,
        },
      },
    )
      .then((response) => response.json<{ parallel_profile: ParallelProfile }>())
      .then((data) => data.parallel_profile);
    pasProfile = fetch(
      PARALLEL_PAS_URL,
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${parallelAuth?.access_token}`,
        },
      },
    )
      .then((response) => response.json<ParallelPasProfile>());
    if (user?.app_metadata?.parallel_account?.account_uuid) {
      pgsAccount = fetch(
        PARALLEL_PGS_URL(user.app_metadata.parallel_account.account_uuid),
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${parallelAuth?.access_token}`,
          },
        },
      )
        .then((response) => response.json<ParallelPGSAccount>());
    }
  }

  return {
    user,
    cookies: cookies.getAll(),
    season,
    parallelAuth,
    account,
    pasProfile,
    pgsAccount
  };
};
