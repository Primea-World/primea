import { dev } from "$app/environment";
import { PUBLIC_PARALLEL_CLIENT_ID } from "$env/static/public";
import { redirect } from "@sveltejs/kit";

const PARALLEL_CHALLENGE_SIZE = 40;
const PARALLEL_URI = "https://parallel.life";
const PARALLEL_AUTH_URI = `${PARALLEL_URI}/oauth2/authorize/`;

function generateChallenge(): string {
  const characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < PARALLEL_CHALLENGE_SIZE; i++) {
    result += characters.charAt(
      Math.floor(Math.random() * characters.length)
    );
  }
  return result;
}

export const GET = async ({ url, cookies }) => {
  const challenge = generateChallenge();
  const redirectUri = url.searchParams.get("redirect");

  cookies.set("x-challenge", challenge, {
    path: '/',           // Cookie available site-wide
    httpOnly: true,      // Prevent client-side JS access
    secure: !dev, // Secure in production
    maxAge: 60 * 60 * 24 // Expires in 24 hours (in seconds)
  });

  const params = [
    "response_type=code",
    `code_challenge=${challenge}`,
    `client_id=${PUBLIC_PARALLEL_CLIENT_ID}`,
    "scope=pgs_user",
    `redirect_uri=https://primea.world/oauth?redirect=${redirectUri}`,
  ].join("&");

  throw redirect(303, PARALLEL_AUTH_URI + `?${params}`);
}