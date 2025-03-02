import { ParallelProfile } from "$lib/parallelProfile.js";

export const load = async ({ parent, fetch }) => {
  const { parallelAuth, account } = await parent();
  if (!parallelAuth || !account) {
    return {
      permissions: null,
    };
  }

  // const parallelAccount = new ParallelProfile(await account);
  const permissions = account.then((a) => {
    const parallelAccount = new ParallelProfile(a);

    const permissions = fetch(
      `/profile/parallel/permissions/?token=${parallelAuth.access_token}&userId=${parallelAccount.django_profile.account_id}`,
    ).then(async (r) => {
      return await r.text();
    });
    return permissions;
  });

  return {
    permissions,
    account,
  };
};
