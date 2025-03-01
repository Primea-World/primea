import { PUBLIC_PARALLEL_CLIENT_ID, PUBLIC_PARALLEL_REDIRECT } from "$env/static/public";
import { error, redirect } from "@sveltejs/kit";

export const GET = async ({ url, cookies, fetch }) => {
  const code = url.searchParams.get("code");
  const redirectUri = url.searchParams.get("redirect");
  const challenge = cookies.get("x-challenge");
  if (!code || !redirectUri || !challenge) {
    throw error(500, "invalid authorization response");
  }
  console.log("found code, redirectUri, or challenge", { code, redirectUri, challenge });

  const response = await fetch(`https://parallel.life/oauth2/token/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      "grant_type": "authorization_code",
      "code": code,
      "client_id": PUBLIC_PARALLEL_CLIENT_ID,
      "code_verifier": challenge,
      "redirect_uri": `${PUBLIC_PARALLEL_REDIRECT}?redirect=${redirectUri}`,
    }),
  });

  const data = await response.json();
  if (data.error) {
    throw error(500, "error obtaining access token");
  }
  const { access_token, refresh_token, expires_in, token_type, scope } = data;
  throw redirect(303, `${redirectUri}?access_token=${access_token}&refresh_token=${refresh_token}&expires_in=${expires_in}?token_type=${token_type}&scope=${scope}`);
}