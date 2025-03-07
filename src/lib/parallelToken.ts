import type { Cookies } from "@sveltejs/kit";

export const AUTH_COOKIE_NAME = "parallel-auth";
export const CODE_COOKIE_NAME = "parallel-code";

export interface ParallelToken {
  access_token: string;
  expires_in: number;
  token_type: "Bearer";
  scope: "pgs_user";
  refresh_token: string;
  expires_at?: number;
}


export const getParallelToken = (cookies: Cookies): ParallelToken | null => {
  const authCookie = cookies.get(AUTH_COOKIE_NAME);
  if (authCookie) {
    return JSON.parse(authCookie) as ParallelToken;
  }
  return null;
}