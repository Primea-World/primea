import { PUBLIC_PARALLEL_URL } from '$env/static/public';
import { error, json } from '@sveltejs/kit';

export const GET = async ({ fetch, url, params }) => {
  const token = url.searchParams.get("token");
  const userId = params.id;
  if (!token || !userId) {
    throw error(400, "Invalid request");
  }

  const permissionsResponse = await fetch(
    `${PUBLIC_PARALLEL_URL}/api/pgs-proxy/player/${userId}/publishing-settings/`,
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    },
  )

  const permissions = await permissionsResponse.json();

  return json(permissions);
};
