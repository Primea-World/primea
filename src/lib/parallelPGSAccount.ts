import { PUBLIC_PARALLEL_URL } from "$env/static/public";

export const PARALLEL_PGS_URL = (accountId: string) => `${PUBLIC_PARALLEL_URL}/api/pgs-proxy/player/public/player_id/${accountId}/account/`;

export interface ParallelPGSAccount {
  username: string;
  profile_id: number;
  account_uuid: string;
  temporary_code: string;
  picture_url?: string;
}