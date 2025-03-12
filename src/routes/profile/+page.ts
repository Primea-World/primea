import type { ParallelPermissions } from "$lib/parallelPermissions";
import type { AuthError, OAuthResponse, SignInWithOAuthCredentials, User, UserIdentity } from "@supabase/supabase-js";
import { cardDetails } from "./PageCardDetails.svelte";
import { cardPanel } from "./PageCardPanel.svelte";
import type { ParallelProfile } from "$lib/parallelProfile";

export const ssr = false;

export const load = async ({ parent, fetch }) => {
  const { supabase, user, account, parallelAuth, pasProfile } = await parent();

  const profileData: {
    unlinkIdentity: (identity: UserIdentity) => Promise<
      | {
        data: unknown;
        error: null;
      }
      | {
        data: null;
        error: AuthError;
      }
    >,
    linkIdentity: (
      credentials: SignInWithOAuthCredentials
    ) => Promise<OAuthResponse>,
    user: User | null,
    account: Promise<ParallelProfile> | null
  } = {
    linkIdentity: supabase.auth.linkIdentity,
    unlinkIdentity: supabase.auth.unlinkIdentity,
    user,
    account
  };

  if (!parallelAuth || !pasProfile) {
    return {
      profileData,
      permissions: null,
    };
  }

  const permissions = pasProfile.then((account) => fetch(
    `/profile/parallel/${account.account_id}/permissions/?token=${parallelAuth.access_token}`
  )).then((response) => response.json<{ settings: ParallelPermissions[] }>()).then((data) => data.settings);

  return {
    cardDetails,
    cardPanel,
    profileData,
    permissions,
  }
};
