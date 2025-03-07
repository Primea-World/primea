<script lang="ts">
  import CircularProgress from "$lib/CircularProgress.svelte";

  import PlayerCard from "$lib/PlayerCard.svelte";
  import {onMount} from "svelte";
  import {SvelteSet} from "svelte/reactivity";
  import {
    toParallelMatchOverview,
    type ParallelMatchOverview,
  } from "$lib/parallelMatchOverview.js";

  const {data} = $props();

  const {supabase, parallelAuth, user, account, season, pgsAccount} = data;

  let matches = new SvelteSet<ParallelMatchOverview>();

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

  onMount(async () => {
    const lastMatch = await supabase
      .from("matches")
      .select("*")
      .order("game_start_time", {ascending: false})
      .limit(1);

    Promise.race([
      account?.then((account) => {
        // if account is undefined, reject the promise
        if (!account) {
          console.log("account rejected", account);
          return Promise.reject();
        }
        return {
          account_id: account?.django_profile.account_id,
          username: account?.django_profile.username,
        };
      }),
      new Promise(
        async (
          resolve: (value: {account_id: string; username: string}) => void,
          reject
        ) => {
          const a = await account;
          // if account is undefined, reject the promise
          if (!a) {
            reject();
          } else {
            resolve({
              account_id: a.django_profile.account_id,
              username: a.django_profile.username,
            });
          }
        }
      ),
      new Promise(
        async (
          resolve: (value: {account_id: string; username: string}) => void,
          reject
        ) => {
          const a = await pgsAccount;
          // if account is undefined, reject the promise
          if (!a) {
            reject();
          } else {
            resolve({
              account_id: a.account_uuid,
              username: a.username,
            });
          }
        }
      ),
    ])?.then(async (account) => {
      console.log("account", account);
      if (!account) {
        return;
      }

      const resp = await fetch(
        `/matches/${account.account_id}?token=${parallelAuth?.access_token}&lastMatch=${lastMatch.data?.at(0)?.match_id}`
      );
      const reader = resp.body?.getReader();
      const textDecoder = new TextDecoder();
      let overflow = "";
      let fetched: ParallelMatchOverview[] = [];
      while (true) {
        const {done, value} = await reader!.read();
        if (done) {
          break;
        }
        const text = (overflow + textDecoder.decode(value)).split("\0");
        if (!text.at(-1)?.endsWith("}")) {
          // if the current chunk doesn't end with a valid json object
          // save the last part to the overflow
          overflow = text.pop()!;
        }
        // for each part of the chunk (+overflow)
        // parse the part of the chunk and add it to matches
        text.forEach((element) => {
          const game: ParallelMatchOverview = JSON.parse(element);
          if (game.player_one_name === account.username) {
            game.player_one_id = account.account_id;
          } else if (game.player_two_name === account.username) {
            game.player_two_id = account.account_id;
          }
          if (game.winner_name === account.username) {
            game.winner_id = account.account_id;
          }
          fetched.push(game);
        });
      }
      if (fetched.length > 0) {
        await supabase.from("matches").upsert(
          fetched.map((match) => ({
            ...match,
            game_end_time: new Date(match.game_end_time).toISOString(),
            game_start_time: new Date(match.game_start_time).toISOString(),
          })),
          {
            count: "exact",
          }
        );
        fetched.forEach((match) => {
          matches.add(match);
        });
      }
    });
  });

  season.then(async (season) => {
    if (!season) {
      return;
    }
    const data =
      // .gte("game_start_time", season.season_start)
      // .lte("game_start_time", season.season_end)
      (await supabase.from("matches").select("*")).data;
    if (data) {
      for (let index = 0; index < (data?.length ?? 0); index++) {
        const element = data[index];
        matches.add(toParallelMatchOverview(element));
      }
    }
  });
</script>

<PlayerCard {user} account={pgsAccount ?? account} {season}>
  {#snippet cardDetails()}
    <div class="summary">
      <table>
        <colgroup>
          <col style="width: 50%" />
          <col style="width: 50%" />
        </colgroup>
        <tbody>
          <tr>
            <td data-label="win streak">3</td>
            <td data-label="MMR">30</td>
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

<div class="matches">
  {#await pgsAccount then account}
    {#each matches as match (match.match_id)}
      <div class="match">
        <div class="self">
          {#if account?.account_uuid}
            {match.player_one_deck_parallel} - {match.player_one_deck_paragon}
          {/if}
        </div>
        <div class="summary">
          <h2>Match {match.match_id}</h2>
          <p>{match.game_start_time}</p>

          <p>Winner: {match.winner_name}</p>
          <p>Duration: {match.game_end_time} minutes</p>
        </div>
        <div class="opponent">
          {#if account?.account_uuid}
            {match.player_two_deck_parallel} - {match.player_two_deck_paragon}
          {/if}
        </div>
        <!-- <div class="match-header">
          <h2>Match {match.match_id}</h2>
          <p>{match.game_start_time}</p>
        </div>
        <div class="match-body">
          <p>Winner: {match.winner_name}</p>
          <p>Duration: {match.game_end_time} minutes</p>
        </div> -->
      </div>
    {:else}
      <div>No Matches</div>
    {/each}
  {/await}
</div>

<style>
  table {
    width: 100%;
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
    background-color: #00000096;
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

  .matches {
    max-width: 1184px;
    margin: auto;

    > .match {
      display: grid;
      grid-auto-flow: column;
      align-items: center;
      justify-content: space-around;
    }
  }
</style>
