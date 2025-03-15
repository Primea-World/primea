<script lang="ts">
  import CircularProgress from "$lib/CircularProgress.svelte";
  import Image from "$lib/Image.svelte";
  import Icon from "$lib/parallels/Icon.svelte";
  import {selectedStream} from "$lib/streamStore.js";
  import Typewriter from "$lib/Typewriter.svelte";
  import {relativeTimeDifference} from "$lib/util";
  import {fade} from "svelte/transition";
  import {linear} from "svelte/easing";
  import type {PrimingParagonData} from "./priming/+server.js";
  import {onMount} from "svelte";
  import {SvelteMap} from "svelte/reactivity";
  import {Paragon, Parallel} from "$lib/parallels/parallel.js";
  import type {Database} from "$lib/database.types.js";

  const {data} = $props();

  const {paragons, parallelSummaries, twitchStreams, supabase} = data;

  const paragonMap: SvelteMap<
    Database["public"]["Enums"]["parallel"],
    SvelteMap<String, PrimingParagonData>
  > = $state(new SvelteMap());

  const paragonsPromise = supabase
    .from("card_functions")
    .select("*")
    .eq("card_type", "paragon");

  const primingPromise = fetch("/priming").then((res) =>
    res.json<PrimingParagonData[]>()
  );

  onMount(async () => {
    const [priming, paragonFunctions] = await Promise.all([
      primingPromise,
      paragonsPromise,
    ]);
    for (let index = 0; index < priming.length; index++) {
      const element = priming[index];
      const paragon = paragonFunctions.data?.find(
        (p) => p.id == parseInt(element.paragonId?.split("-")[1] ?? "0")
      );
      priming[index].title = paragon?.title;
      priming[index].name = paragon?.basename;

      if (!paragon) {
        console.error(`Paragon not found for priming ${element.paragonId}`);
        continue;
      }

      if (!element.title) {
        console.error(`Priming ${element.paragonId} has no title`);
        continue;
      }

      if (!paragonMap.has(paragon.parallel)) {
        const map = new SvelteMap<String, PrimingParagonData>();
        map.set(element.title, element);
        paragonMap.set(paragon.parallel, map);
      } else if (!paragonMap.get(paragon.parallel)?.has(element.title)) {
        paragonMap.get(paragon.parallel)?.set(element.title, element);
      } else {
        console.error(
          `Priming ${element.paragonId} already exists in map for ${paragon.parallel}`
        );
      }
    }
  });
</script>

<div class="parallel-summaries">
  {#each paragonMap as [key, value]}
    {@const parallel = Parallel.fromString(key)}
    {@const total_count = value.values().reduce((acc, val) => {
      acc += val.totalGames365 ?? 0;
      return acc;
    }, 0)}
    {@const win_count = value.values().reduce((acc, val) => {
      acc += val.totalWins365 ?? 0;
      return acc;
    }, 0)}
    {@const loss_count = total_count - win_count}

    <!-- {#each parallelSummaries as { parallel, total_count, win_count, loss_count }} -->
    <!-- {@const paragonStats = paragons.filter(
      (p) => p.paragon.parallel == parallel
    )} -->
    <div class="parallel">
      <Icon {parallel} />
      <div>
        <p class="parallel-title">{parallel.title}</p>
        <table>
          <tbody>
            <tr>
              <td data-label="games" class="total">
                {total_count}
              </td>
              <td data-label="won" class="wins">{win_count}</td>
              <td data-label="lost" class="losses">{loss_count}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <CircularProgress
        radius={60}
        pathWidth={5}
        value={(win_count / total_count) * 100}
      />
      <div class="parallel-stats">
        {#each value as [title, paragonData]}
          {@const paragon = Paragon.fromCardID(
            parseInt(paragonData.paragonId!.split("-")[1])
          )}
          <div
            style="background-image: url(./paragons/{paragon.camelCaseName}.webp); background-position-y: {paragon.focalPoint}px;"
          >
            <p class="paragon-title" data-description={paragon.description}>
              {paragon.name}
            </p>
            <table>
              <colgroup>
                <col style="width: 1fr;" />
                <col style="width: 1fr;" />
                <col style="width: 1fr;" />
              </colgroup>
              <tbody>
                <tr>
                  <td data-label="games" class="total">
                    {paragonData.totalGames365}
                  </td>
                  <td data-label="won" class="wins"
                    >{paragonData.totalWins365}</td
                  >
                  <td data-label="lost" class="losses"
                    >{(paragonData.totalGames365 ?? 0) -
                      (paragonData.totalWins365 ?? 0)}</td
                  >
                </tr>
              </tbody>
            </table>
            <div class="paragon-winrate">
              <CircularProgress
                radius={40}
                pathWidth={3}
                value={paragonData.totalWinRate365 ?? 0}
              />
            </div>
          </div>
        {/each}
      </div>
    </div>
  {/each}
</div>

<a class="backlink" href="https://priming.xyz/gameplay-insights/overview">
  PARAGON STATS POWERED BY <img src="/brands/priming_logo.svg" alt="Priming" />
</a>

<div class="streams">
  <div class="content">
    <div transition:fade={{easing: linear}} class="loading-streams">
      <div>
        <Typewriter
          text={twitchStreams
            .then((streams) =>
              streams.data.length > 0 ? "loaded streams" : null
            )
            .catch((error) => {
              console.error(error);
              return "failed to load streams";
            })}
          placeholder="loading streams"
          defaultText="no live streams"
          typingSpeed={0.075}
        />
      </div>
    </div>
    {#await twitchStreams then streamResponse}
      {@const streams = streamResponse.data}
      <div class="stream-list">
        {#each streams as stream}
          <button
            class="stream"
            class:selected={$selectedStream?.id == stream.id}
            data-viewer-count={stream.viewer_count.toString().padStart(2, "0")}
            onclick={() => {
              if ($selectedStream?.id === stream.id) {
                $selectedStream = null;
              } else {
                $selectedStream = stream;
              }
            }}
            transition:fade={{easing: linear}}
          >
            <Image
              src={stream.thumbnail_url
                .toString()
                .replace("{width}", "400")
                .replace("{height}", "225")}
              alt={stream.user_name}
              width={400}
              height={225}
            />
            <div>
              <div>
                {stream.user_name} // {relativeTimeDifference(
                  Date.now(),
                  new Date(stream.started_at).getTime(),
                  true,
                  false
                )}
              </div>
              <p class="title">{stream.title}</p>
            </div>
          </button>
        {/each}
      </div>
    {/await}
  </div>
</div>

<style>
  table {
    width: 100%;
  }

  .parallel-summaries {
    max-width: 1184px;
    margin: auto;
  }

  .parallel {
    display: grid;
    grid-template-columns: 6em 0.5fr 140px;
    justify-content: space-around;
    align-items: center;
    padding: 1em;
    border: thin solid #c5c5c5;
    position: relative;
    margin: 1em auto;
    background-color: #13131396;
  }

  .parallel .parallel-title {
    font-size: xx-large;
    margin-top: 0.5em;
  }

  .parallel tr > td {
    width: 33%;
    position: relative;
    padding: 0.75em 0.2em 0;
    font-size: x-large;
    font-weight: 500;
    text-align: start;
    text-shadow: 0 0 4px #000;
  }

  .parallel tr > td::after {
    position: absolute;
    top: 0;
    left: 0.2em;
    content: attr(data-label);
    text-transform: uppercase;
    font-size: small;
    font-weight: lighter;
  }

  .parallel tr > td:nth-child(1) {
    border-left: 3px solid #def141;
  }

  .parallel tr > td:nth-child(2) {
    border-left: 3px solid #49bc31;
  }

  .parallel tr > td:nth-child(3) {
    border-left: 3px solid #ff7332;
  }

  .parallel-summaries .parallel-stats {
    position: absolute;
    width: 100%;
    height: 100%;
    display: flex;
    opacity: 0;
    transition: opacity 0.25s ease-in-out;
  }

  .parallel-summaries:hover .parallel-stats {
    opacity: 1;
  }

  .parallel-stats > div {
    position: relative;
    flex: 1;
    background-size: cover;
    background-position-x: center;
    background-blend-mode: overlay;
    background-color: #0d0d0d85;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
  }

  .parallel-stats .paragon-title {
    font-size: x-large;
    margin: 0.75em 0.1em;
    text-align: start;
    text-shadow: 0 0 2px #000;
    position: relative;
  }

  .parallel-stats .paragon-title::after {
    position: absolute;
    bottom: -12px;
    left: 0.1em;
    content: attr(data-description);
    text-transform: uppercase;
    text-shadow: 0 0 2px #000;
    font-size: small;
    font-weight: bold;
  }

  .parallel-stats .paragon-winrate {
    position: absolute;
    top: 0.5em;
    right: 1em;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #00000096;
    border-radius: 50%;
  }

  .backlink {
    font-size: medium;
    max-width: 1184px;
    margin: auto;
    width: 100%;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    color: var(--text-color);
    text-decoration: none;
    background-color: #000000d1;
    padding: 1em 0;

    > img {
      height: 2em;
      margin: 0 0.5em 0 0.5em;
    }
  }

  .streams {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    height: 334px;
    position: relative;
    width: 100%;
    margin: 0 auto;
    overflow: auto;
    border-image: linear-gradient(
        to right,
        transparent 0%,
        var(--color-primary) 50%,
        transparent 100%
      )
      1;
    border-width: 2px;
    border-style: solid;
    scrollbar-width: none;

    .content {
      width: fit-content;
      max-width: 100%;
      margin: auto;
    }

    .stream-list {
      white-space: nowrap;
    }

    .loading-streams {
      height: 100%;
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      top: 0;
      left: 0;
      position: absolute;
      text-align: center;

      & > div {
        position: absolute;
        text-transform: uppercase;
        color: var(--color-primary);
        font-size: xx-large;
        font-weight: 600;
        padding: 0.5em 1em;
        background-color: #000000ca;
      }
    }

    .stream {
      padding: 0.5em;
      margin: 1em;
      background-color: #000;
      color: var(--text-color);
      position: relative;
      border: 2px solid transparent;
      cursor: pointer;
      font-family: inherit;
      max-width: calc(400px + 1em);
      transition: border 0.25s ease-in-out;

      > div {
        text-align: start;
        font-size: medium;
        font-weight: bolder;
      }

      .title {
        max-width: 100%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: small;
        font-weight: normal;
        max-height: 1rem;
      }

      &.selected {
        border: 2px solid var(--color-primary);
      }

      &::after {
        position: absolute;
        content: attr(data-viewer-count);
        top: -0.5rem;
        right: -0.5rem;
        background-color: var(--color-primary);
        padding-left: 0.25em;
        padding-right: 0.25em;
        font-weight: 600;
        color: #000;
      }
    }
  }
</style>
