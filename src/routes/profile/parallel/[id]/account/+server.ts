import { PUBLIC_PARALLEL_URL } from "$env/static/public";
import { error, json } from "@sveltejs/kit";

export const GET = async ({ params, url, fetch }) => {
  const token = url.searchParams.get("token");
  if (!token) {
    throw error(401, "Unauthorized");
  }
  const accountResponse = await fetch(`${PUBLIC_PARALLEL_URL}/api/pgs-proxy/player/public/player_id/${params.id}/account/`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return json(await accountResponse.json());
}