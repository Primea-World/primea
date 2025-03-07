import { SUPABASE_SECRET } from "$env/static/private";
import { PUBLIC_PARALLEL_URL, PUBLIC_SUPABASE_URL } from "$env/static/public";
import type { ParallelPGSAccount } from "$lib/parallelPGSAccount.js";
import { createClient } from "@supabase/supabase-js";
import { error, json } from "@sveltejs/kit";

export const GET = async ({ params, url, fetch }) => {
  const token = url.searchParams.get("token");
  if (!token) {
    throw error(401, "Unauthorized");
  }
  const profileResponse = await fetch(`${PUBLIC_PARALLEL_URL}/api/pgs-proxy/player/public/username/${params.id}/profile/`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return json(await profileResponse.json());
}

const supabase = createClient(PUBLIC_SUPABASE_URL, SUPABASE_SECRET);

export const POST = async ({ params, fetch, url }) => {
  const supabaseId = url.searchParams.get("supabaseId");
  if (!supabaseId) {
    throw error(400, "Invalid request");
  }
  const token = url.searchParams.get("token");
  if (!token) {
    throw error(401, "Unauthorized");
  }
  const accountResponse = await fetch(`/profile/parallel/${params.id}/account?token=${token}`);
  const account = await accountResponse.json() as ParallelPGSAccount;

  if (account.account_uuid != params.id) {
    throw error(400, "Invalid account");
  }

  const result = await supabase.auth.admin.updateUserById(supabaseId, {
    app_metadata: {
      parallel_account: account,
    }
  });

  if (result.error) {
    console.error(result.error);
    throw error(500, "Internal server error");
  }

  return new Response("OK");
}