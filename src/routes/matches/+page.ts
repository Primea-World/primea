import type { MatchesDetailParameters, UplinkPanelParameters } from '$lib/playerCardData'

export const load = async ({ parent }) => {
  const { supabase, account, pasProfile, season } = await parent();

  const seasonData = await season;
  const totalMatches = supabase
    .from("matches")
    .select("*", { count: "exact" })
    .lte('game_start_time', seasonData?.season_end)
    .gte('game_end_time', seasonData?.season_start)
    .order('game_start_time', { ascending: false }).then((value) => value.data);

  const lastMatch = supabase
    .from("matches")
    .select("*")
    .order("game_start_time", { ascending: false })
    .limit(1)
    .single();


  const matchData: MatchesDetailParameters = {
    account,
    pasProfile,
    totalMatches,
  }

  const matchPanel: UplinkPanelParameters = {
    totalMatches,
    pasProfile,
  };

  return {
    matchData,
    matchPanel,
    lastMatch,
  }
}