import type { LayoutLoad } from "./$types";

export const load: LayoutLoad = async ({ data, url }) => {
  const accessToken = url.searchParams.get("access_token");
  const refreshToken = url.searchParams.get("refresh_token");
  const expiresIn = url.searchParams.get("expires_in");
  const tokenType = url.searchParams.get("token_type");
  const scope = url.searchParams.get("scope");

  return {
    ...data,
    parallel: {
      accessToken,
      refreshToken,
      expiresIn,
      tokenType,
      scope
    }
  };
}