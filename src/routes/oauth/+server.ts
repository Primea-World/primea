import { PARALLEL_CLIENT_ID, PARALLEL_REDIRECT } from "$env/static/private";
import { error, redirect } from "@sveltejs/kit";

export const GET = async ({ url, cookies, fetch }) => {
  const code = url.searchParams.get("code");
  const redirectUri = url.searchParams.get("redirect");
  const challenge = cookies.get("x-challenge");
  if (!code || !redirectUri || !challenge) {
    throw error(500, "invalid authorization response");
  }

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
  });

  // Set the expiration time to 5 minutes before the token expires
  data.expires_at = Date.now() + (data.expires_in - 300) * 1000;

  cookies.set("parallel-auth", JSON.stringify(data), {
    path: "/", // Cookie available site-wide
    httpOnly: false, // Prevent client-side JS access
    secure: true, // Secure in production
    sameSite: "strict", // Prevent CSRF
    maxAge: 60 * 60 * 24 * 30, // Expires in 30 days, if the token is invalid then attempt to refresh the token
    // maxAge: data.expires_in, // Expires at token expiration
  });

  throw redirect(303, `${redirectUri}`);
};

export const POST = async ({ request }) => {
  const data = await request.json();
  const body = new URLSearchParams({
    "grant_type": "refresh_token",
    "refresh_token": data.refresh_token,
    "client_id": PARALLEL_CLIENT_ID,
    "redirect_uri": `${PARALLEL_REDIRECT}`,
  });
  return await fetch(`https://parallel.life/oauth2/token/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });
};
