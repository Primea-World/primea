export const GET = async ({ fetch, url }) => {
  const token = url.searchParams.get("token");
  const userId = url.searchParams.get("userId");
  if (!token || !userId) {
    return new Response("Invalid request", { status: 400 });
  }

  const r = await fetch(
    `https://parallel.life/api/pgs-proxy/player/${userId}/publishing-settings/`,
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (!r.ok) {
    return new Response("Error fetching permissions", { status: r.status });
  }

  return new Response(JSON.stringify(await r.json()), {
    headers: {
      "Content-Type": "application/json",
    },
  });
};
