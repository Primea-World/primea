export interface ParallelToken {
  access_token: string;
  expires_in: number;
  token_type: 'Bearer';
  scope: 'pgs_user';
  refresh_token: string;
}