import type { ParallelPermissions } from "$lib/parallelPermissions";
import type { ProfileDetailsParameters, ProfilePanelParameters } from "$lib/playerCardData";

export const load = async ({ parent, fetch }) => {
  const { supabase, user, account, parallelAuth, pasProfile } = await parent();

  const profileData: ProfileDetailsParameters = {
    linkIdentity: supabase.auth.linkIdentity,
    unlinkIdentity: supabase.auth.unlinkIdentity,
    user,
    account,
  };

  const profilePanel: ProfilePanelParameters = {
    user,
    account,
  };

  if (!parallelAuth || !pasProfile) {
    return {
      profileData,
      profilePanel,
      permissions: null,
    };
  }

  const permissions = pasProfile.then((account) => fetch(
    `/profile/parallel/${account.account_id}/permissions/?token=${parallelAuth.access_token}`
  )).then((response) => response.json<{ settings: ParallelPermissions[] }>()).then((data) => data.settings).catch((error) => {
    console.error("Failed to fetch permissions", error);
    return [];
  });

  return {
    profileData,
    profilePanel,
    permissions,
  }
};
