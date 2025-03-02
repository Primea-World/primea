<script lang="ts">
  import CircularProgress from "$lib/CircularProgress.svelte";
  import {
    AUGENCORE,
    EARTHEN,
    KATHARI,
    MARCOLIAN,
    Paragon,
    SHROUD,
  } from "$lib/parallels/parallel";
  import Icon from "$lib/parallels/Icon.svelte";
  import PlayerCard from "$lib/PlayerCard.svelte";
  import {ParallelProfile} from "$lib/parallelProfile.js";

  let {data} = $props();

  let winRate = $state(60);

  function showWinRate() {
    winRate = 60;
  }

  function showFirstWinRate() {
    winRate = 85;
  }

  function showSecondWinRate() {
    winRate = 22;
  }

  // player
  // TODO: create map of wins for first/second
  const player = {
    id: "lofty_puma",
    name: "Lofty Puma",
    season: "Echoes of the Void",
    parallel: SHROUD,
    matches: 100,
    wins: 60,
    losses: 40,
    first: 40,
    second: 60,
  };

  // paragons
  const paragons = [
    {
      paragon: "juggernautWorkshop",
      total_count: "100",
      win_count: "61",
      loss_count: "39",
    },
    {
      paragon: "arak",
      total_count: "100",
      win_count: "10",
      loss_count: "90",
    },
    {
      paragon: "jahn",
      total_count: "100",
      win_count: "30",
      loss_count: "70",
    },
    {
      paragon: "nehemiah",
      total_count: "134",
      win_count: "72",
      loss_count: "62",
    },
    {
      paragon: "gaffar",
      total_count: "100",
      win_count: "80",
      loss_count: "20",
    },
    {
      paragon: "shoshanna",
      total_count: "0",
      win_count: "0",
      loss_count: "0",
    },
    {
      paragon: "aetio",
      total_count: "44",
      win_count: "15",
      loss_count: "29",
    },
    {
      paragon: "scipiusMagnusAlpha",
      total_count: "357",
      win_count: "188",
      loss_count: "169",
    },
    {
      paragon: "gnaeusValerusAlpha",
      total_count: "0",
      win_count: "0",
      loss_count: "0",
    },
    {
      paragon: "lemieux",
      total_count: "35",
      win_count: "22",
      loss_count: "13",
    },
    {
      paragon: "catherineLapointe",
      total_count: "284",
      win_count: "173",
      loss_count: "111",
    },
    {
      paragon: "armouredDivisionHQ",
      total_count: "0",
      win_count: "0",
      loss_count: "0",
    },
    {
      paragon: "brand",
      total_count: "54",
      win_count: "36",
      loss_count: "18",
    },
    {
      paragon: "newDawn",
      total_count: "0",
      win_count: "0",
      loss_count: "0",
    },
    {
      paragon: "niamh",
      total_count: "0",
      win_count: "0",
      loss_count: "0",
    },
  ].map((p) => {
    return {
      paragon: Paragon.fromString(p.paragon),
      total_count: parseInt(p.total_count),
      win_count: parseInt(p.win_count),
      loss_count: parseInt(p.loss_count),
    };
  });

  const parallelSummaries = paragons.reduce(
    (acc, paragon) => {
      const i = acc.findIndex(
        (p) => paragon.paragon.parallel.title === p.parallel.title
      );
      if (i !== -1) {
        acc[i].total_count += paragon.total_count;
        acc[i].win_count += paragon.win_count;
        acc[i].loss_count += paragon.loss_count;
      }
      return acc;
    },
    [
      {
        parallel: AUGENCORE,
        total_count: 0,
        win_count: 0,
        loss_count: 0,
      },
      {
        parallel: EARTHEN,
        total_count: 0,
        win_count: 0,
        loss_count: 0,
      },
      {
        parallel: KATHARI,
        total_count: 0,
        win_count: 0,
        loss_count: 0,
      },
      {
        parallel: MARCOLIAN,
        total_count: 0,
        win_count: 0,
        loss_count: 0,
      },
      {
        parallel: SHROUD,
        total_count: 0,
        win_count: 0,
        loss_count: 0,
      },
    ]
  );
</script>

<PlayerCard
  parallelProfile={data.account?.then(
    (account) => new ParallelProfile(account)
  )}
>
  {#snippet cardDetails()}
    <div class="summary">
      <table>
        <colgroup>
          <col style="width: 50%" />
          <col style="width: 50%" />
        </colgroup>
        <tbody>
          <tr>
            <td data-label="matches">100</td>
            <td data-label="matches (7D)">30</td>
          </tr>
          <tr>
            <td data-label="matches won">60</td>
            <td data-label="matches lost">40</td>
          </tr>
        </tbody>
      </table>
    </div>
  {/snippet}
  {#snippet cardPanel()}
    <div class="stats">
      <CircularProgress radius={100} pathWidth={5} bind:value={winRate} />
      <span
        id="first"
        role="contentinfo"
        onmouseenter={showFirstWinRate}
        onmouseleave={showWinRate}
        onfocus={showFirstWinRate}
        data-label="1st"
      >
        40
      </span>
      <span
        id="second"
        role="contentinfo"
        onmouseenter={showSecondWinRate}
        onmouseleave={showWinRate}
        onfocus={showSecondWinRate}
        data-label="2nd"
      >
        60
      </span>
    </div>
  {/snippet}
</PlayerCard>

<div class="parallel-summaries">
  {#each parallelSummaries as { parallel, total_count, win_count, loss_count }}
    {@const paragonStats = paragons.filter(
      (p) => p.paragon.parallel == parallel
    )}
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
        {#each paragonStats as { paragon, total_count, win_count, loss_count }}
          <div
            style="background-image: url(./paragons/{paragon.name?.replaceAll(
              ' ',
              ''
            )}.webp); background-position-y: {paragon.focalPoint}px;"
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
                    {total_count}
                  </td>
                  <td data-label="won" class="wins">{win_count}</td>
                  <td data-label="lost" class="losses">{loss_count}</td>
                </tr>
              </tbody>
            </table>
            <div class="paragon-winrate">
              <CircularProgress
                radius={40}
                pathWidth={3}
                value={(win_count / total_count) * 100 || 0}
              />
            </div>
          </div>
        {/each}
      </div>
    </div>
  {/each}
</div>

<h1>Live Streams (if there are any)</h1>
<p>
  Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the
  documentation
</p>

<style>
  table {
    width: 100%;
  }

  div {
    background-color: var(--surface-color);
  }

  .summary {
    background-color: #000;
  }

  .summary table {
    margin-top: 1em;
    border-collapse: collapse;
  }

  .summary td {
    position: relative;
    border-left: 4px solid #def141;
    padding-left: 8px;
    padding-top: 0.75em;
    font-weight: 500;
    font-size: xx-large;
  }

  .summary td::before {
    position: absolute;
    top: 0;
    left: 8px;
    content: attr(data-label);
    text-transform: uppercase;
    font-size: large;
    font-weight: lighter;
  }

  .stats {
    height: 263px;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  #first {
    position: absolute;
    font-size: x-large;
    top: 1em;
    left: 1em;
  }

  #first::before {
    content: attr(data-label);
    font-size: small;
    font-weight: lighter;
    position: absolute;
    top: -1.1em;
    left: 0;
  }

  #second {
    position: absolute;
    font-size: x-large;
    top: 1em;
    right: 1em;
  }

  #second::before {
    content: attr(data-label);
    font-size: small;
    font-weight: lighter;
    position: absolute;
    top: -1.1em;
    right: 0;
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
</style>
