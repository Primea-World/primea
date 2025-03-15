import { TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET, TWITCH_PARALLEL_GAME_ID } from '$env/static/private';
import { json } from '@sveltejs/kit';


type Fetch = {
  (input: RequestInfo | URL, init?: RequestInit): Promise<Response>;
  (input: RequestInfo | URL, init?: RequestInit<RequestInitCfProperties>): Promise<Response>;
  (input: string | URL | globalThis.Request, init?: RequestInit): Promise<Response>;
};

interface AccessToken {
  access_token: string;
  expires_in: number;
  token_type: "bearer";
}

interface StreamResponse {
  id: string;
  user_id: string;
  user_login: string;
  user_name: string;
  game_id: string;
  game_name: string;
  type: string;
  title: string;
  viewer_count: number;
  started_at: string;
  language: string;
  thumbnail_url: URL;
  tag_ids: string[];
  tags: string[];
  is_mature: boolean;
}

async function getTwitchClientToken(fetch: Fetch, twitchClientId: string, twitchClientSecret: string) {
  return await fetch("https://id.twitch.tv/oauth2/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: twitchClientId,
      client_secret: twitchClientSecret,
      grant_type: "client_credentials",
    }),
  }).then((response) => response.json<AccessToken>());
}

export const GET = async ({ fetch, url }) => {
  const accessToken = await getTwitchClientToken(fetch, TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET);
  const limit = parseInt(url.searchParams.get("limit") || "20");
  const streamsUrl = `https://api.twitch.tv/helix/streams?game_id=${TWITCH_PARALLEL_GAME_ID}&first=${limit}`;
  // const clipsUrl = `https://api.twitch.tv/helix/clips?game_id=${PARALLEL_GAME_ID}&first=${limit}`;

  const response = await fetch(
    streamsUrl,
    {
      headers: {
        "Authorization": `Bearer ${accessToken.access_token}`,
        "Client-Id": TWITCH_CLIENT_ID,
      },
    },
  );

  return json(await response.json<{ data: StreamResponse[] }>())
}

export { type StreamResponse };