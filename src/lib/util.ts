import { type User } from "@supabase/supabase-js";

export const second = 1000;
export const minute = 60 * second;
export const hour = 60 * minute;

export function relativeTimeDifference(
  now: number,
  timestamp?: number
): string | null {
  if (!timestamp) {
    return null;
  }
  const higher = Math.max(timestamp, now);
  const lower = Math.min(timestamp, now);
  const future = timestamp > now ? true : false;
  const diff = higher - lower;
  const hours = Math.floor(diff / hour)
    .toString()
    .padStart(2, "0");
  const minutes = Math.floor((diff % hour) / minute)
    .toString()
    .padStart(2, "0");
  const seconds = Math.floor((diff % minute) / second)
    .toString()
    .padStart(2, "0");
  return `${future ? "in" : ""} ${hours}:${minutes}:${seconds} ${future ? "" : "ago"}`;
}


export async function userName(
  user?: User | null,
  username?: Promise<string | null> | null,
): Promise<string> {
  return (
    user?.app_metadata.parallel_account.username ??
    await username ??
    user?.identities?.at(0)?.identity_data?.["full_name"] ??
    user?.identities?.at(0)?.identity_data?.["name"] ??
    user?.identities?.at(0)?.identity_data?.["nickname"] ??
    user?.email ??
    "unknown"
  );
}
