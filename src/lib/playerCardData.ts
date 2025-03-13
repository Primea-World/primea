import type { PostgrestFilterBuilder } from "@supabase/postgrest-js";
import type { ParallelPasProfile } from "./parallelPASProfile";
import type { Database } from "./database.types";
import type { AuthError, OAuthResponse, SignInWithOAuthCredentials, UserIdentity, UserResponse } from "@supabase/supabase-js";
import type { ParallelProfile } from "./parallelProfile";

interface UplinkDetailsParameters {
  rows: [string, PromiseLike<number | null | undefined>][][];
}

interface UplinkPanelParameters {
  totalMatches: PostgrestFilterBuilder<
    Database["public"],
    Database["public"]["Tables"]["matches"]["Row"],
    Database["public"]["Tables"]["matches"]["Row"][]
  >;
  pasProfile: Promise<ParallelPasProfile> | null;

}

interface MatchesDetailParameters {
  totalMatches: PostgrestFilterBuilder<
    Database["public"],
    Database["public"]["Tables"]["matches"]["Row"],
    Database["public"]["Tables"]["matches"]["Row"][]
  >;
  pasProfile: Promise<ParallelPasProfile> | null;
  account: Promise<ParallelProfile> | null;
}


interface ProfileDetailsParameters {
  unlinkIdentity: (identity: UserIdentity) => Promise<
    | {
      data: unknown;
      error: null;
    }
    | {
      data: null;
      error: AuthError;
    }
  >;
  linkIdentity: (
    credentials: SignInWithOAuthCredentials
  ) => Promise<OAuthResponse>;
  user: Promise<UserResponse>;
  account: Promise<ParallelProfile> | null;
}


interface ProfilePanelParameters {
  user: Promise<UserResponse>;
  account: Promise<ParallelProfile | null> | null;
}



export type {
  UplinkDetailsParameters,
  UplinkPanelParameters,
  MatchesDetailParameters,
  ProfileDetailsParameters,
  ProfilePanelParameters
};