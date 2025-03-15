import type { UplinkDetailsParameters, UplinkPanelParameters } from "$lib/playerCardData";
import type { StreamResponse } from "./twitch/streams/+server";

export const load = async ({ parent, fetch }) => {
  const { supabase, pasProfile, season } = await parent();

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [seasonData, profile] = await Promise.all([season, pasProfile]);

  const totalMatches = supabase
    .from("matches")
    .select("*", { count: "exact" })
    // .lte('game_start_time', seasonData?.season_end)
    // .gte('game_end_time', seasonData?.season_start)
    .order('game_start_time', { ascending: false }).then((value) => value.data);

  const uplinkData: UplinkDetailsParameters = {
    rows: [
      [
        ["matches", totalMatches.then((res) => res?.length)],
        ["7d matches", totalMatches.then((res) => res?.filter((m) => new Date(m.game_start_time) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)).length ?? 0)],
      ],
      [
        ["won", totalMatches.then((res) => res?.filter((m) => m.winner_id === profile?.account_id).length)],
        ["lost", totalMatches.then((res) => res?.filter((m) => m.winner_id !== profile?.account_id).length)],
      ],
    ]
  }

  const twitchStreams = fetch("/twitch/streams").then((res) => res.json<{ data: StreamResponse[] }>());

  const uplinkPanel: UplinkPanelParameters = {
    totalMatches,
    pasProfile,
  }

  return {
    uplinkData,
    uplinkPanel,
    twitchStreams,
  }
}