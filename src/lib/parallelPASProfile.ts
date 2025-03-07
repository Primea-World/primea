import { PUBLIC_PARALLEL_URL } from "$env/static/public";

export const PARALLEL_PAS_URL = `${PUBLIC_PARALLEL_URL}/api/v1/pas/profile/`;

export interface ParallelPasProfile {
  account_id: string;
  bio?: string;
  nft_profile_picture?: {
    token_id: string;
    contract_address: string;
    image_url: string;
    name: string;
    description: string;
    parallel: string;
  };
  pfp_default_image?: {
    id: string;
    client_id: string;
    image_url: string;
  };
}