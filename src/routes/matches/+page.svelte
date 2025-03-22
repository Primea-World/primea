<script lang="ts">
  import {onMount} from "svelte";
  import {SvelteSet} from "svelte/reactivity";
  import {
    fromJSON,
    toParallelMatchOverview,
    toRow,
    type ParallelMatchOverview,
  } from "$lib/parallelMatchOverview.js";
  import {MONTHS, relativeTimeDifference} from "$lib/util.js";
  import {fade} from "svelte/transition";
  import Typewriter from "$lib/Typewriter.svelte";

  const {data} = $props();
  const {supabase, parallelAuth, account, pgsAccount, lastMatch, matchData} =
    $derived(data);
  const totalMatches = $derived(matchData?.totalMatches);

  $effect(() => {
    totalMatches?.then((matchResponse) => {
      const data = matchResponse;
      if (data) {
        for (let index = 0; index < (data?.length ?? 0); index++) {
          const element = data[index];
          matches.add(toParallelMatchOverview(element));
        }
      }
    });
  });

  let matches = $state(new SvelteSet<ParallelMatchOverview>());

  function matchTime(match: ParallelMatchOverview) {
    return `${MONTHS.get(match.game_start_time.getMonth())} ${match.game_start_time.getDate().toString().padStart(2, "0")} ${(
      match.game_start_time.getHours() % 12
    )
      .toString()
      .padStart(2, "0")}:${match.game_start_time
      .getMinutes()
      .toString()
      .padStart(
        2,
        "0"
      )} ${match.game_start_time.getHours() >= 12 ? "PM" : "AM"}`;
  }

  onMount(async () => {
    const lastMatchResponse = (await lastMatch).data;

    Promise.race([
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
    ])
      ?.catch((error) => console.log("error fetching account id", error))
      .then(async (account) => {
        if (!account) {
          return;
        }

        const resp = await fetch(
          `/matches/${account.account_id}?token=${parallelAuth?.access_token}&lastMatch=${lastMatchResponse?.match_id}`
        );
        const reader = resp.body?.getReader();
        const textDecoder = new TextDecoder();
        let overflow = "";
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
          text.forEach(async (element) => {
            const game = fromJSON(element);
            if (game.player_one_name === account.username) {
              game.player_one_id = account.account_id;
            } else if (game.player_two_name === account.username) {
              game.player_two_id = account.account_id;
            }
            if (game.winner_name === account.username) {
              game.winner_id = account.account_id;
            }
            matches.add(game);
            await supabase.from("matches").upsert([toRow(game)]);
          });
        }
      });
  });
</script>

<div class="matches">
  {#await pgsAccount}
    <div class="empty-matches">
      <Typewriter
        text={totalMatches?.then(() => "LOADED MATCHES")}
        placeholder="LOADING MATCHES"
      />
    </div>
  {:then account}
    {#if !account}
      <div class="empty-matches">
        <a href="/profile"
          >LINK // ACCOUNT <span class="material-symbols-rounded">
            open_in_new
          </span></a
        >
      </div>
    {:else}
      {#each matches as match (match.match_id)}
        {@const playerOneParagon = match.player_one_deck_paragon}
        {@const playerTwoParagon = match.player_two_deck_paragon}
        {@const onPlayText =
          match.player_one_id == account?.account_uuid
            ? "on the play"
            : "on the draw"}
        <div class="match">
          <div transition:fade class="match-paragon">
            {#if account?.account_uuid == match.player_one_id}
              <img
                class="paragon"
                src="/paragons/{match.player_one_deck_paragon
                  .CamelCaseName}.webp"
                alt={match.player_one_deck_paragon.name}
              />
              <div>
                <div class="username">{match.player_one_name}</div>
                <div class="paragon-name">
                  {playerOneParagon.name}
                </div>
                <div
                  class="paragon-description"
                  style="color: {playerOneParagon.parallel.color};"
                >
                  {playerOneParagon.description}
                </div>
              </div>
            {:else}
              <img
                class="paragon"
                src="/paragons/{match.player_two_deck_paragon
                  .CamelCaseName}.webp"
                alt={match.player_two_deck_paragon.name}
              />
              <div>
                <div class="username">{match.player_two_name}</div>
                <div class="paragon-name">
                  {playerTwoParagon.name}
                </div>
                <div
                  class="paragon-description"
                  style="color: {playerTwoParagon.parallel.color};"
                >
                  {playerTwoParagon.description}
                </div>
              </div>
            {/if}
          </div>
          <div
            class="match-summary"
            data-time={matchTime(match)}
            data-duration={relativeTimeDifference(
              match.game_end_time.getTime(),
              match.game_start_time.getTime(),
              true,
              false
            )}
          >
            <div
              data-label={onPlayText}
              class:win={account?.account_uuid == match.winner_id}
              class:loss={account?.account_uuid != match.winner_id}
            >
              {#if account?.account_uuid == match.winner_id}
                win
              {:else}
                loss
              {/if}
            </div>
          </div>
          <div class="match-paragon opponent">
            {#if account?.account_uuid == match.player_one_id}
              <div>
                <div class="username">{match.player_two_name}</div>
                <div
                  class="paragon-name"
                  data-title={playerTwoParagon.description}
                  data-color={playerTwoParagon.parallel.color.slice(1)}
                >
                  {playerTwoParagon.name}
                </div>
                <div
                  class="paragon-description"
                  style="color: {playerTwoParagon.parallel.color};"
                >
                  {playerTwoParagon.description}
                </div>
              </div>
              <img
                class="paragon"
                src="/paragons/{match.player_two_deck_paragon
                  .CamelCaseName}.webp"
                alt={match.player_two_deck_paragon.name}
              />
            {:else}
              <div>
                <div class="username">{match.player_one_name}</div>
                <div
                  class="paragon-name"
                  data-title={playerOneParagon.description}
                  data-color={playerOneParagon.parallel.color}
                >
                  {playerOneParagon.name}
                </div>
                <div
                  class="paragon-description"
                  style="color: {playerOneParagon.parallel.color};"
                >
                  {playerOneParagon.description}
                </div>
              </div>
              <img
                class="paragon"
                src="/paragons/{match.player_one_deck_paragon
                  .CamelCaseName}.webp"
                alt={match.player_one_deck_paragon.name}
              />
            {/if}
          </div>
        </div>
      {:else}
        <div class="empty-matches">NO MATCHES</div>
      {/each}
    {/if}
  {/await}
</div>

<style>
  .empty-matches {
    max-width: 1184px;
    margin: 1em auto;
    font-size: xx-large;
    text-align: center;
    padding: 2em 0;
    color: var(--text-color);
    background-color: #000000b6;
    text-transform: uppercase;

    > a {
      vertical-align: middle;
      text-decoration: none;
      color: var(--color-primary);
    }
  }

  .matches {
    max-width: 1184px;
    margin: auto;

    > .match {
      display: grid;
      grid-auto-flow: column;
      grid-template-columns: 1fr 1fr 1fr;
      align-items: center;
      justify-content: space-around;
      padding: 1em;
      margin: 1em 0;
      background-color: #000000b6;

      .match-paragon {
        display: flex;
        justify-content: flex-start;

        .username {
          font-size: x-large;
          padding: 0 0.5rem;
        }

        > div {
          flex-grow: 1;

          .paragon-name {
            font-size: smaller;
            text-transform: uppercase;
            font-weight: lighter;
            padding: 0 0.5rem;
            position: relative;
          }

          .paragon-description {
            padding: 0 0.5rem;
            font-size: x-small;
            font-weight: 700;
            text-transform: uppercase;
          }
        }

        &.opponent {
          text-align: end;
          justify-content: flex-end;
        }

        &.opponent .paragon-name::after {
          left: inherit;
          right: 0;
        }
      }

      .paragon {
        aspect-ratio: 25 / 30;
        max-width: 125px;
        object-fit: cover;
        object-position: top;
        position: relative;
      }

      .paragon::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: white; /* Adjust to match the background */
        clip-path: polygon(
          0 0,
          calc(100% - 20px) 0,
          calc(100% - 20px) calc(100% - 20px),
          0 calc(100% - 20px)
        );
      }

      .match-summary {
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: center;
        height: 100%;

        &::before {
          content: attr(data-time);
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          text-align: center;
          text-transform: uppercase;
          font-size: medium;
          font-weight: lighter;
        }
        &::after {
          content: attr(data-duration);
          position: absolute;
          top: 1.5em;
          left: 0;
          right: 0;
          text-align: center;
          text-transform: uppercase;
          font-size: small;
          font-weight: lighter;
        }
      }

      .match-summary > div {
        text-align: center;
        font-size: xx-large;
        text-transform: uppercase;
        mask-image: linear-gradient(to top, black, #0000005c);
        -webkit-mask-image: linear-gradient(to top, black, #0000005c);
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        height: 100%;
        color: var(--color);
        text-shadow: 0 0 6px var(--color);

        &.win {
          --color: var(--green);
        }

        &.loss {
          --color: var(--red);
        }

        &::after {
          position: absolute;
          content: attr(data-label);
          text-transform: uppercase;
          font-size: small;
          font-weight: bolder;
          bottom: 2em;
          color: var(--text-color);
          padding: 0.15em 0.25em;
        }
      }
    }
  }
</style>
