import type { ParallelPasProfile } from "./parallelPASProfile";
import type { Database } from "./database.types";
import type { AuthError, OAuthResponse, SignInWithOAuthCredentials, User, UserIdentity } from "@supabase/supabase-js";
import type { ParallelProfile } from "./parallelProfile";

interface UplinkDetailsParameters {
  rows: [string, PromiseLike<number | null | undefined>][][];
}

interface UplinkPanelParameters {
  totalMatches: PromiseLike<Database["public"]["Tables"]["matches"]["Row"][] | null>;
  pasProfile: Promise<ParallelPasProfile> | undefined | null;

}

interface MatchesDetailParameters {
  totalMatches: PromiseLike<Database["public"]["Tables"]["matches"]["Row"][] | null>;
  pasProfile: Promise<ParallelPasProfile> | undefined | null;
  account: Promise<ParallelProfile> | undefined | null;
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
  user: User | null;
  account: Promise<ParallelProfile> | null;
}


interface ProfilePanelParameters {
  user: User | null;
  account: Promise<ParallelProfile | null> | null;
}



export type {
  UplinkDetailsParameters,
  UplinkPanelParameters,
  MatchesDetailParameters,
  ProfileDetailsParameters,
  ProfilePanelParameters
};