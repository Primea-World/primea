import { writable } from "svelte/store";
import type { StreamResponse } from "../routes/twitch/streams/+server";

const selectedStream = writable<StreamResponse | null>(null);

export { selectedStream };