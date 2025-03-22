import type { Database } from "./database.types";
import { Paragon, Parallel } from "./parallels/parallel";

export interface ParallelMatchResponse {
  match_id: string;
  game_type: "ranked";
  game_start_time: string;
  game_end_time: string;
  player_one_name?: string;
  player_one_id?: string;
  player_two_name?: string;
  player_two_id?: string;
  completed: boolean;
  player_one_deck_parallel: string;
  player_two_deck_parallel: string;
  player_one_deck_paragon: string;
  player_two_deck_paragon: string;
  winner_name?: string;
  winner_id?: string;
}

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
  player_one_deck_parallel: typeof Parallel;
  player_two_deck_parallel: typeof Parallel;
  player_one_deck_paragon: typeof Paragon;
  player_two_deck_paragon: typeof Paragon;
  winner_name?: string;
  winner_id?: string;
}

export function fromJSON(str: string): ParallelMatchOverview {
  const data = JSON.parse(str);
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
    player_one_deck_parallel: Parallel.fromString(data.player_one_deck_parallel),
    player_two_deck_parallel: Parallel.fromString(data.player_two_deck_parallel),
    player_one_deck_paragon: Paragon.fromString(data.player_one_deck_paragon),
    player_two_deck_paragon: Paragon.fromString(data.player_two_deck_paragon),
    winner_name: data.winner_name ?? undefined,
    winner_id: data.winner_id ?? undefined,
  };
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
    player_one_deck_parallel: Parallel.fromString(data.player_one_deck_parallel),
    player_two_deck_parallel: Parallel.fromString(data.player_two_deck_parallel),
    player_one_deck_paragon: Paragon.fromString(data.player_one_deck_paragon),
    player_two_deck_paragon: Paragon.fromString(data.player_two_deck_paragon),
    winner_name: data.winner_name ?? undefined,
    winner_id: data.winner_id ?? undefined,
  };
}

export function toRow(data: ParallelMatchOverview): Database["public"]["Tables"]["matches"]["Row"] {
  return {
    match_id: data.match_id,
    game_type: data.game_type,
    game_start_time: data.game_start_time.toISOString(),
    game_end_time: data.game_end_time.toISOString(),
    player_one_name: data.player_one_name ?? null,
    player_one_id: data.player_one_id ?? null,
    player_two_name: data.player_two_name ?? null,
    player_two_id: data.player_two_id ?? null,
    completed: data.completed,
    player_one_deck_parallel: data.player_one_deck_parallel.lowercaseName,
    player_two_deck_parallel: data.player_two_deck_parallel.lowercaseName,
    player_one_deck_paragon: data.player_one_deck_paragon.CamelCaseName,
    player_two_deck_paragon: data.player_two_deck_paragon.CamelCaseName,
    winner_name: data.winner_name ?? null,
    winner_id: data.winner_id ?? null,
  };
}