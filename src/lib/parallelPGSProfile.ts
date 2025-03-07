export interface ParallelPGSProfile {
  id: string;
  username: string;
  rank?: number; // only for masters
  rank_bracket?: string;
  avatar_url?: string;
  primary_wallet?: string;
}