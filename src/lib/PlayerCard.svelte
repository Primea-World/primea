<script lang="ts">
  import type {Snippet} from "svelte";
  import Icon from "./parallels/Icon.svelte";
  import {
    Augencore,
    Earthen,
    Kathari,
    Marcolian,
    Shroud,
    Universal,
  } from "./parallels/parallel";
  import Typewriter from "./Typewriter.svelte";
  import type {User} from "@supabase/supabase-js";
  import type {Database} from "./database.types";
  import {relativeTimeDifference, userName} from "./util";
  import type {ParallelPGSAccount} from "./parallelPGSAccount";
  import type {ParallelProfile} from "./parallelProfile";

  interface Props {
    cardDetails: Snippet<[]>;
    cardPanel: Snippet<[]>;
    user: User | null;
    season: PromiseLike<Database["public"]["Tables"]["seasons"]["Row"] | null>;
    account:
      | Promise<ParallelProfile>
      | Promise<ParallelPGSAccount>
      | undefined
      | null;
  }

  const {cardDetails, cardPanel, season, user, account}: Props = $props();

  let username = $derived(
    account?.then((account) => {
      if (!account) {
        return null;
      } else if ("django_profile" in account) {
        return account.django_profile.username;
      } else {
        return account.username;
      }
    })
  );

  const seasonParallel = season?.then((season) => {
    switch (season?.parallel) {
      case "augencore":
        return Augencore;
      case "earthen":
        return Earthen;
      case "kathari":
        return Kathari;
      case "marcolian":
        return Marcolian;
      case "shroud":
        return Shroud;
      case "universal":
      default:
        return Universal;
    }
  });
</script>

<div>
  <table>
    <colgroup>
      <col class="main-column" />
      <col class="stats-column" />
    </colgroup>
    <thead>
      <tr>
        <th></th>
        <th class="stats stats-header">
          <div>primea</div>
          <div>//</div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>
          <div class="summary">
            {#if !user}
              <div class="unauthorized">access denied</div>
            {/if}
            <div class="user text-ellipsis">
              USER:
              <b>
                <Typewriter text={userName(user, username)} />
              </b>
            </div>
            {#await season then seasonData}
              <div class="season text-ellipsis">
                <span class="text-ellipsis">
                  SEASON: <b
                    data-label="ends {!!seasonData
                      ? relativeTimeDifference(
                          Date.now(),
                          new Date(seasonData?.season_end).getTime()
                        )
                      : null}"
                  >
                    <Typewriter
                      text={season?.then((seasonData) => seasonData?.name)}
                    />
                  </b>
                </span>
              </div>
            {/await}
            {#await seasonParallel then parallel}
              {#if !!parallel}
                <span id="season-parallel">
                  <Icon {parallel} />
                </span>
              {/if}
            {/await}
            {@render cardDetails()}
          </div>
        </td>
        <td class="stats">
          {@render cardPanel()}
        </td>
      </tr>
      <tr> </tr>
    </tbody>
  </table>
</div>

<style>
  .main-column,
  .stats-column {
    width: 50%;
  }

  @media screen and (max-width: 1200px) {
    .main-column {
      width: 60%;
    }
    .stats-column {
      width: 40%;
    }
  }

  .season {
    position: relative;
    b::after {
      content: attr(data-label);
      position: absolute;
      left: 6.25rem;
      bottom: -1rem;
      font-size: medium;
      font-weight: 900;
      color: var(--text-dim);
    }
  }

  div {
    position: relative;
  }

  table {
    border-collapse: collapse; /* Ensures borders merge */
    width: 100%;
  }

  thead {
    color: var(--text-dim); /* Dimmer color */
    text-transform: uppercase;
    font-style: italic;
    font-size: 0.75rem;
    border-bottom: thin solid #c5c5c5;
  }

  th {
    font-weight: normal;
  }

  th > div {
    padding: 0 1em;
  }

  thead tr:nth-child(1) {
    padding: 1em 0.25em 0.5em;
  }

  tr:nth-child(1) {
    max-width: 250px;
  }

  .summary {
    position: relative;
    background-color: #000;
    padding: 20px;
    margin-left: auto;
    box-shadow: -2px 2px 10px 3px #c5c5c580;
    max-width: 550px;

    #season-parallel {
      position: absolute;
      top: 5%;
      right: 5%;
      width: 120px;
      opacity: 85%;
    }

    > div.user {
      font-size: xx-large;
      z-index: 1;
      position: relative;
    }

    > div.season {
      font-size: x-large;
      z-index: 1;
      position: relative;
    }

    .unauthorized {
      position: absolute;
      top: 1rem;
      left: 1rem;
      right: 1rem;
      bottom: 1rem;
      background-color: #5454548a;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: xx-large;
      font-weight: bold;
      z-index: 10;
      backdrop-filter: blur(5px);
      text-transform: uppercase;
      color: var(--red);
      text-shadow: 0 0 4px #000;
    }
  }

  .stats {
    max-width: 250px;
    border-left: thin solid #c5c5c5;
    border-right: thin solid #c5c5c5;
    display: flex;
    justify-content: center;
    padding: 0;
    position: relative;
  }

  thead tr .stats {
    padding: 2.65em 0 0;
  }

  tr td.stats {
    border-left: thin solid white;
    border-right: none;
    box-shadow: 2px 2px 10px 3px #c5c5c580;
  }

  .stats-header {
    justify-content: space-between;
    padding: 1em 0;
  }

  @media only screen and (max-width: 768px) {
    .stats-header {
      display: none;
    }

    /* TODO: create a mobile-friendly size here */
  }
</style>
