import type { ParallelPermissions } from "$lib/parallelPermissions";

export const load = async ({ parent, fetch }) => {
  const { parallelAuth, pasProfile } = await parent();
  if (!parallelAuth || !pasProfile) {
    return {
      permissions: null,
    };
  }

  const permissions = pasProfile.then((account) => fetch(
    `/profile/parallel/${account.account_id}/permissions/?token=${parallelAuth.access_token}`
  )).then((response) => response.json<{ settings: ParallelPermissions[] }>()).then((data) => data.settings);

  return {
    permissions,
  }
};
