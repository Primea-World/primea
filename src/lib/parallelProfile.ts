import { PUBLIC_PARALLEL_URL } from "$env/static/public";

export const PARALLEL_ACCOUNT_ID_COOKIE_NAME = "parallel_account_id";

export const PARALLEL_PROFILE_URL = `${PUBLIC_PARALLEL_URL}/api/pgs/api/v1/players/0/profiles/parallel/`;

export interface ParallelProfile {
  id: number;
  account_id: number;
  xp: number;
  mmr?: number;
  matchmaking_mmr?: number;
  renown: {
    base_card_id: number;
    base_card_name: string;
    design_id: string;
    renown: number;
    replication_renown_cost: number;
    replications_available: number;
  }[];
  rank?: string;
  rank_bracket?: string;
  active_keys: string[];
  equipped_apparition_keys: string[];
  equipped_skeleton_keys: {
    "transformation_id": string,
    "type": string,
    "key_uuid": string,
    "expiry_date": string,
  }[];
  key_slot: number;
  win_streak: number;
  prismatic_parallel: string;
  skeleton_transformed_key?: string;
  title?: {
    id: string;
    title: string;
  };
  django_profile: {
    username: string;
    django_id: number;
    picture_url: string;
    small_picture_url: string;
    account_id: string;
  };
  prime_balance: number;
  claimable_prime: number;
  game_reward_prime: number;
  prime_estimation_for_today: number;
  is_super_user: boolean;
  open_missions: {
    progression_id: number;
    mission_id: string;
    mission_name: string;
    mission_type: string;
    x_count: number;
    x_count_target: number;
    parallel: string;
    status: string;
    is_active: boolean;
    xp_reward: number;
    is_tracked: boolean;
  }[];
  free_reroll_left: number;
  weekly_mission: {
    progression_id: number;
    status: string;
    year: number;
    week: number;
    claimed_mission_count: number;
    xp_reward: number;
    next_weekly_mission_date: Date;
    crates?: object[];
  };
  bounty: {
    id: string;
    current: number;
    target: number;
    status: string;
    claimed_date: Date;
    is_on_cooldown: boolean;
    cooldown_end_date: Date;
    cooldown_in_seconds: number;
    xp_reward: number;
  };
  // has_playable_deck: boolean;
  glints: {
    balance: number;
  };
  ranked_total_wins: number;
  ranked_total_losses: number;
  ranked_games_played: number;
  unranked_total_wins: number;
  unranked_total_losses: number;
  unranked_games_played: number;
  one_queue_win_streak: number;
  one_queue_total_wins: number;
  one_queue_total_losses: number;
  one_queue_games_played: number;
  private_total_wins: number;
  private_total_losses: number;
  private_games_played: number;
  rookie_total_wins: number;
  rookie_total_losses: number;
  rookie_games_played: number;
  bot_total_wins: number;
  bot_total_losses: number;
  bot_games_played: number;
  // auto_claim_ready_battlepass_ids: string[];
  // next_mission_date: Date;
  avatar: {
    id: string;
    name: string;
    image_url: string;
    small_image_url: string;
  };
  has_early_concede_penalty: boolean;
  is_elite: boolean;
  // total_glints_purchased: number;

}
