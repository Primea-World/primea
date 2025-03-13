import { type UserResponse } from "@supabase/supabase-js";
import { Aetio, Arak, ArmouredDivisionHQ, Brand, CatherineLapointe, Gaffar, GnaeusValerusAlpha, Jahn, JuggernautWorkshop, Lemieux, Nehemiah, NewDawn, Niamh, ScipiusMagnusAlpha, Shoshanna } from "./parallels/parallel";

export const second = 1000;
export const minute = 60 * second;
export const hour = 60 * minute;

type ParagonName = "Arak" | "Jahn" | "JuggernautWorkshop" | "Gaffar" | "Nehemiah" | "Shoshanna" | "Aetio" | "GnaeusValerusAlpha" | "ScipiusMagnusAlpha" | "ArmouredDivisionHQ" | "CatherineLapointe" | "Lemieux" | "Brand" | "NewDawn" | "Niamh" | "unknown";

export const PARAGON_NAMES: ParagonName[] = [
  Arak,
  Jahn,
  JuggernautWorkshop,
  Gaffar,
  Nehemiah,
  Shoshanna,
  Aetio,
  GnaeusValerusAlpha,
  ScipiusMagnusAlpha,
  ArmouredDivisionHQ,
  CatherineLapointe,
  Lemieux,
  Brand,
  NewDawn,
  Niamh,
].map((paragon) => paragon.name.replaceAll(" ", "") as ParagonName);

export const MONTHS: Map<number, string> = new Map([
  [0, "Jan"],
  [1, "Feb"],
  [2, "Mar"],
  [3, "Apr"],
  [4, "May"],
  [5, "Jun"],
  [6, "Jul"],
  [7, "Aug"],
  [8, "Sep"],
  [9, "Oct"],
  [10, "Nov"],
  [11, "Dec"],
])

function padNumber(value: number, padCharacters: number = 2, padCharacter: string = "0"): string {
  return value.toString().padStart(padCharacters, padCharacter);
}

export function relativeTimeDifference(
  now: number,
  timestamp?: number,
  simpleFormat: boolean = true,
  relativeKeyword: boolean = true,
): string | null {
  if (!timestamp) {
    return null;
  }
  const higher = Math.max(timestamp, now);
  const lower = Math.min(timestamp, now);
  const future = timestamp > now ? true : false;
  const diff = higher - lower;
  const days = Math.floor(diff / (24 * hour));
  const hours = Math.floor(diff / hour);
  const minutes = Math.floor((diff % hour) / minute);
  const seconds = Math.floor((diff % minute) / second);
  let timeSpan = "";
  if (simpleFormat) {
    if (days > 0) {
      timeSpan = `${padNumber(days)} day${days > 1 ? "s" : ""}`;
    } else if (hours > 0) {
      timeSpan = `${padNumber(hours)} hour${hours > 1 ? "s" : ""}`;
    } else if (minutes > 0) {
      timeSpan = `${padNumber(minutes)} minute${minutes > 1 ? "s" : ""}`;
    } else {
      timeSpan = `${padNumber(seconds)} second${seconds > 1 ? "s" : ""}`;
    }
  } else {
    timeSpan = `${hours}:${minutes}:${seconds}`
  }
  if (relativeKeyword) {
    return `${future ? "in" : ""} ${timeSpan} ${future ? "" : "ago"}`;
  }
  return timeSpan;
}


export async function userName(
  user?: Promise<UserResponse>,
  username?: Promise<string | null> | null,
): Promise<string> {
  const userResponse = (await user)?.data.user;

  return (
    userResponse?.app_metadata.parallel_account.username ??
    await username ??
    userResponse?.identities?.at(0)?.identity_data?.["full_name"] ??
    userResponse?.identities?.at(0)?.identity_data?.["name"] ??
    userResponse?.identities?.at(0)?.identity_data?.["nickname"] ??
    userResponse?.email ??
    "unknown"
  );
}
