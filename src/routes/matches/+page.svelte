<script lang="ts">
  import {onMount} from "svelte";
  import {SvelteSet} from "svelte/reactivity";
  import {
    toParallelMatchOverview,
    type ParallelMatchOverview,
  } from "$lib/parallelMatchOverview.js";
  import {MONTHS, PARAGON_NAMES, relativeTimeDifference} from "$lib/util.js";
  import {Paragon} from "$lib/parallels/parallel.js";
  import {page} from "$app/state";

  const {data} = $props();
  const {supabase, parallelAuth, account, pgsAccount, lastMatch} =
    $derived(data);
  const {matchData} = $derived(page.data);
  const totalMatches = $derived(matchData?.totalMatches);

  $effect(() => {
    totalMatches?.then((matchResponse) => {
      const data = matchResponse.data;
      if (data) {
        for (let index = 0; index < (data?.length ?? 0); index++) {
          const element = data[index];
          matches.add(toParallelMatchOverview(element));
        }
      }
    });
  });

  let matches = new SvelteSet<ParallelMatchOverview>();

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
    ])?.then(async (account) => {
      if (!account) {
        return;
      }

      const resp = await fetch(
        `/matches/${account.account_id}?token=${parallelAuth?.access_token}&lastMatch=${lastMatchResponse?.match_id}`
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
            player_one_deck_paragon:
              PARAGON_NAMES.find((paragon) =>
                match.player_one_deck_paragon.startsWith(paragon)
              ) ?? "unknown",
            player_two_deck_paragon:
              PARAGON_NAMES.find((paragon) =>
                match.player_two_deck_paragon.startsWith(paragon)
              ) ?? "unknown",
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
</script>

<div class="matches">
  {#await pgsAccount then account}
    {#each matches as match (match.match_id)}
      {@const playerOneParagon = Paragon.fromString(
        match.player_one_deck_paragon
      )}
      {@const playerTwoParagon = Paragon.fromString(
        match.player_two_deck_paragon
      )}
      {@const onPlayText =
        match.player_one_id == account?.account_uuid
          ? "on the play"
          : "on the draw"}
      <div class="match">
        <div class="match-paragon">
          {#if account?.account_uuid == match.player_one_id}
            <img
              class="paragon"
              src="/paragons/{match.player_one_deck_paragon}.webp"
              alt={match.player_one_deck_paragon}
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
              src="/paragons/{match.player_two_deck_paragon}.webp"
              alt={match.player_two_deck_paragon}
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
              src="/paragons/{match.player_two_deck_paragon}.webp"
              alt={match.player_two_deck_paragon}
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
              src="/paragons/{match.player_one_deck_paragon}.webp"
              alt={match.player_one_deck_paragon}
            />
          {/if}
        </div>
      </div>
    {:else}
      <div>No Matches</div>
    {/each}
  {/await}
</div>

<style>
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
