import { PUBLIC_PARALLEL_URL } from '$env/static/public';
import type { ParallelMatchOverview } from '$lib/parallelMatchOverview';
import type { Fetch } from '@supabase/supabase-js/dist/module/lib/types';

interface ParallelMatchOverviewResponse {
  games: ParallelMatchOverview[];
  continuation?: {
    next_token: string,
    has_more: boolean,
  };
}

// Create an AsyncGenerator function to fetch matches and return them as they become available (in batches of 10)
// Batch size is set and unchangeable by parallel
async function* fetchMatches(fetch: Fetch, access_token: string, accountId: string, searchParams: URLSearchParams, latestMatchId: string | null) {
  let offset = parseInt(searchParams.get("offset") ?? "0");
  let hasMore = true;

  try {
    do {
      const response = await fetch(
        `${PUBLIC_PARALLEL_URL}/api/pgs-proxy/player/${accountId}/game/overview/?offset=${offset}`,
        {
          headers: {
            Authorization: `Bearer ${access_token}`,
          },
        },
      );

      if (!response.ok) {
        console.error(`Error fetching matches: ${response.statusText}`);
        throw new Error(`Error fetching matches: ${response.statusText}`);
      }

      const { games, /* continuation */ } = await response.json<ParallelMatchOverviewResponse>();

      if (games.length < 10) {
        hasMore = false;
      } else {
        offset += games.length;
      }
      for (const game of games) {
        if (latestMatchId && game.match_id == latestMatchId) {
          return;
        }
        yield game;
      }
    } while (hasMore)
  } catch (error) {
    console.error(`Error fetching matches: ${error}`);
    throw new Error(`Error fetching matches: ${error}`)
  }
}

function generatorToStream<T>(iterator: AsyncGenerator<T>): ReadableStream {
  return new ReadableStream({
    type: "bytes",
    async start(controller) {
      const textEncoder = new TextEncoder();
      for await (const element of iterator) {
        // append the null terminator
        const b = textEncoder.encode(JSON.stringify(element) + "\0");
        controller.enqueue(b);
      }
      controller.close();
    },
  })
}

export const GET = async ({ fetch, params, url }) => {
  const token = url.searchParams.get("token");
  if (!token) {
    return new Response(null, { status: 401 });
  }

  const fromDate = url.searchParams.get("fromDate");
  const offset = url.searchParams.get("offset");
  const continuationToken = url.searchParams.get("continuationToken");
  const lastMatch = url.searchParams.get("lastMatch");
  const p: Record<string, string> = {};
  console.log("fetching matches for account", params.id, lastMatch);

  if (fromDate) {
    p.from_date = fromDate;
  }
  if (offset) {
    p.offset = offset;
  }
  if (continuationToken) {
    p.continuation_token = continuationToken;
  }

  const searchParams = new URLSearchParams(p);

  const generator = fetchMatches(fetch, token, params.id, searchParams, lastMatch);
  const stream = generatorToStream(generator);

  return new Response(stream, {
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
      "Transfer-Encoding": "chunked",
    },
  })
}