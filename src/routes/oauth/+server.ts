import { dev } from "$app/environment";
import { PARALLEL_CLIENT_ID, PARALLEL_REDIRECT } from "$env/static/private";
import { error, redirect } from "@sveltejs/kit";

export const GET = async ({ url, cookies, fetch }) => {
  const code = url.searchParams.get("code");
  const redirectUri = url.searchParams.get("redirect");
  const challenge = cookies.get("x-challenge");
  if (!code || !redirectUri || !challenge) {
    throw error(500, "invalid authorization response");
  }
  console.log("found code, redirectUri, and challenge", {
    code,
    redirectUri,
    challenge,
  });

  const response = await fetch(`https://parallel.life/oauth2/token/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      "grant_type": "authorization_code",
      "code": code,
      "client_id": PARALLEL_CLIENT_ID,
      "code_verifier": challenge,
      "redirect_uri": `${PARALLEL_REDIRECT}?redirect=${redirectUri}`,
    }),
  });

  const data = await response.json();
  if (data.error) {
    throw error(500, "error obtaining access token: " + data.error);
  }

  cookies.delete("x-challenge", {
    path: "/", // Cookie available site-wide
    httpOnly: true, // Prevent client-side JS access
    secure: !dev, // Secure in production
    maxAge: 60 * 60 * 24, // Expires in 24 hours (in seconds)
  });

  cookies.set("parallel-auth", JSON.stringify(data), {
    path: "/", // Cookie available site-wide
    httpOnly: true, // Prevent client-side JS access
    secure: true, // Secure in production
    sameSite: "strict", // Prevent CSRF
    maxAge: data.expires_in, // Expires at token expiration
  });

  throw redirect(303, `${redirectUri}`);
};
