import type { Database } from "./database.types";

export interface ParallelMatchOverview {
  match_id: string;
  game_type: "ranked";
  game_start_time: Date;
  game_end_time: Date;
  player_one_name?: string;
  player_one_id?: string;
  player_two_name?: string;
  player_two_id?: string;
  completed: boolean;
  player_one_deck_parallel?: "augencore" | "earthen" | "kathari" | "marcolian" | "shroud" | "universal" | null | undefined;
  player_two_deck_parallel?: "augencore" | "earthen" | "kathari" | "marcolian" | "shroud" | "universal" | null | undefined;
  player_one_deck_paragon?: string;
  player_two_deck_paragon?: string;
  winner_name?: string;
  winner_id?: string;
}

export function toParallelMatchOverview(data: Database["public"]["Tables"]["matches"]["Row"]): ParallelMatchOverview {
  return {
    match_id: data.match_id,
    game_type: data.game_type,
    game_start_time: new Date(data.game_start_time),
    game_end_time: new Date(data.game_end_time),
    player_one_name: data.player_one_name ?? undefined,
    player_one_id: data.player_one_id ?? undefined,
    player_two_name: data.player_two_name ?? undefined,
    player_two_id: data.player_two_id ?? undefined,
    completed: data.completed,
    player_one_deck_parallel: data.player_one_deck_parallel,
    player_two_deck_parallel: data.player_two_deck_parallel,
    player_one_deck_paragon: data.player_one_deck_paragon ?? undefined,
    player_two_deck_paragon: data.player_two_deck_paragon ?? undefined,
    winner_name: data.winner_name ?? undefined,
    winner_id: data.winner_id ?? undefined,
  };
}