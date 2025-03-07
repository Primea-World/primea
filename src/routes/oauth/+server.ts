import { PARALLEL_CLIENT_ID, PARALLEL_REDIRECT } from "$env/static/private";
import { PUBLIC_PARALLEL_URL } from "$env/static/public";
import { AUTH_COOKIE_NAME, CODE_COOKIE_NAME, type ParallelToken } from "$lib/parallelToken.js";
import { error, json, redirect } from "@sveltejs/kit";

export const GET = async ({ url, cookies, fetch }) => {
  const code = url.searchParams.get("code");
  const redirectUri = url.searchParams.get("redirect");
  const challenge = cookies.get(CODE_COOKIE_NAME);
  if (!code || !redirectUri || !challenge) {
    throw error(500, "invalid authorization response");
  }

  const response = await fetch(`${PUBLIC_PARALLEL_URL}/oauth2/token/`, {
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

  const data = await response.json<ParallelToken>();

  cookies.delete(CODE_COOKIE_NAME, {
    path: "/", // Cookie available site-wide
  });

  // Set the expiration time to 5 minutes before the token expires
  data.expires_at = Date.now() + (data.expires_in - 300) * 1000;

  cookies.set(AUTH_COOKIE_NAME, JSON.stringify(data), {
    path: "/", // Cookie available site-wide
    httpOnly: false, // Allow client-side JS access
    secure: true, // Secure in production
    sameSite: "strict", // Prevent CSRF
    maxAge: 60 * 60 * 24 * 30, // Expires in 30 days, if the token is invalid then attempt to refresh the token
    // maxAge: data.expires_in, // Expires at token expiration
  });

  throw redirect(303, `${redirectUri}`);
};

interface RefreshTokenRequest {
  refresh_token: string;
}

export const POST = async ({ request }) => {
  const response = await fetch(`${PUBLIC_PARALLEL_URL}/oauth2/token/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      "grant_type": "refresh_token",
      "refresh_token": (await request.json<RefreshTokenRequest>()).refresh_token,
      "client_id": PARALLEL_CLIENT_ID,
      "redirect_uri": `${PARALLEL_REDIRECT}`,
    }),
  });

  if (!response.ok) {
    console.error("Failed to refresh token", await response.text());
    throw error(500, "Failed to refresh token");
  }

  return json(await response.json<ParallelToken>());
};
