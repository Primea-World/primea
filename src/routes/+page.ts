import { Augencore, Earthen, Kathari, Marcolian, Paragon, Shroud } from "$lib/parallels/parallel";
import type { UplinkDetailsParameters, UplinkPanelParameters } from "$lib/playerCardData";
import { cardDetails } from "./PageCardDetails.svelte";
import { cardPanel } from "./PageCardPanel.svelte";
import type { StreamResponse } from "./twitch/streams/+server";

// paragons
const paragons = [
  {
    paragon: "JuggernautWorkshop",
    total_count: "100",
    win_count: "61",
    loss_count: "39",
  },
  {
    paragon: "Arak",
    total_count: "100",
    win_count: "10",
    loss_count: "90",
  },
  {
    paragon: "Jahn",
    total_count: "100",
    win_count: "30",
    loss_count: "70",
  },
  {
    paragon: "Nehemiah",
    total_count: "134",
    win_count: "72",
    loss_count: "62",
  },
  {
    paragon: "Gaffar",
    total_count: "100",
    win_count: "80",
    loss_count: "20",
  },
  {
    paragon: "Shoshanna",
    total_count: "0",
    win_count: "0",
    loss_count: "0",
  },
  {
    paragon: "Aetio",
    total_count: "44",
    win_count: "15",
    loss_count: "29",
  },
  {
    paragon: "ScipiusMagnusAlpha",
    total_count: "357",
    win_count: "188",
    loss_count: "169",
  },
  {
    paragon: "GnaeusValerusAlpha",
    total_count: "0",
    win_count: "0",
    loss_count: "0",
  },
  {
    paragon: "Lemieux",
    total_count: "35",
    win_count: "22",
    loss_count: "13",
  },
  {
    paragon: "CatherineLapointe",
    total_count: "284",
    win_count: "173",
    loss_count: "111",
  },
  {
    paragon: "ArmouredDivisionHQ",
    total_count: "0",
    win_count: "0",
    loss_count: "0",
  },
  {
    paragon: "Brand",
    total_count: "54",
    win_count: "36",
    loss_count: "18",
  },
  {
    paragon: "NewDawn",
    total_count: "0",
    win_count: "0",
    loss_count: "0",
  },
  {
    paragon: "Niamh",
    total_count: "0",
    win_count: "0",
    loss_count: "0",
  },
].map((p) => {
  return {
    paragon: Paragon.fromString(p.paragon),
    total_count: parseInt(p.total_count),
    win_count: parseInt(p.win_count),
    loss_count: parseInt(p.loss_count),
  };
});

const parallelSummaries = paragons.reduce(
  (acc, paragon) => {
    const i = acc.findIndex(
      (p) => paragon.paragon.parallel.title === p.parallel.title
    );
    if (i !== -1) {
      acc[i].total_count += paragon.total_count;
      acc[i].win_count += paragon.win_count;
      acc[i].loss_count += paragon.loss_count;
    }
    return acc;
  },
  [
    {
      parallel: Augencore,
      total_count: 0,
      win_count: 0,
      loss_count: 0,
    },
    {
      parallel: Earthen,
      total_count: 0,
      win_count: 0,
      loss_count: 0,
    },
    {
      parallel: Kathari,
      total_count: 0,
      win_count: 0,
      loss_count: 0,
    },
    {
      parallel: Marcolian,
      total_count: 0,
      win_count: 0,
      loss_count: 0,
    },
    {
      parallel: Shroud,
      total_count: 0,
      win_count: 0,
      loss_count: 0,
    },
  ]
);

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
    cardDetails,
    cardPanel,
    uplinkData,
    uplinkPanel,
    paragons,
    parallelSummaries,
    twitchStreams,
  }
}