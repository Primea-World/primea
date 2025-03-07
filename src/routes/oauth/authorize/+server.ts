import { dev } from "$app/environment";
import { PARALLEL_CLIENT_ID } from "$env/static/private";
import { PUBLIC_PARALLEL_URL } from "$env/static/public";
import { CODE_COOKIE_NAME } from "$lib/parallelToken.js";
import { redirect } from "@sveltejs/kit";

const PARALLEL_CODE_SIZE = 40;
const PARALLEL_URI = PUBLIC_PARALLEL_URL;
const PARALLEL_AUTH_URI = `${PARALLEL_URI}/oauth2/authorize/`;

function generateCode(): string {
  const characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < PARALLEL_CODE_SIZE; i++) {
    result += characters.charAt(
      Math.floor(Math.random() * characters.length),
    );
  }
  return result;
}

export const GET = async ({ url, cookies }) => {
  const code = generateCode();
  const redirectUri = url.searchParams.get("redirect");

  cookies.set(CODE_COOKIE_NAME, code, {
    path: "/", // Cookie available site-wide
    httpOnly: true, // Prevent client-side JS access
    secure: !dev, // Secure in production
    maxAge: 60 * 30, // Expires in 30 minutes (in seconds)
  });

  const params = [
    "response_type=code",
    `code_challenge=${code}`,
    `client_id=${PARALLEL_CLIENT_ID}`,
    "scope=pgs_user",
    `redirect_uri=https://primea.world/oauth?redirect=${redirectUri}`,
  ].join("&");

  throw redirect(303, PARALLEL_AUTH_URI + `?${params}`);
};
