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
  import type {UserResponse} from "@supabase/supabase-js";
  import type {Database} from "./database.types";
  import {userName} from "./util";
  import type {ParallelPGSAccount} from "./parallelPGSAccount";
  import type {ParallelProfile} from "./parallelProfile";
  import CircularProgress from "./CircularProgress.svelte";

  interface Props {
    cardDetails: Snippet<[]>;
    cardPanel: Snippet<[]>;
    user: Promise<UserResponse>;
    season: PromiseLike<Database["public"]["Tables"]["seasons"]["Row"] | null>;
    account: Promise<ParallelProfile> | Promise<ParallelPGSAccount> | null;
  }

  const {cardDetails, cardPanel, season, user, account}: Props = $props();

  let username = account?.then((account) => {
    if (!account) {
      return null;
    } else if ("django_profile" in account) {
      return account.django_profile.username;
    } else {
      return account.username;
    }
  });

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
          <div class="text-ellipsis">
            USER:
            <b>
              <Typewriter text={userName(user, username)} />
            </b>
          </div>
          <div class="text-ellipsis">
            SEASON: <b>
              <Typewriter
                text={season?.then((seasonData) => seasonData?.name)}
              />
            </b>
          </div>
          {#await seasonParallel then parallel}
            {#if !!parallel}
              <span id="season-parallel">
                <Icon {parallel} />
              </span>
            {/if}
          {/await}
          {#if cardDetails}
            {@render cardDetails?.()}
          {:else}
            <div class="details">
              <table>
                <colgroup>
                  <col style="width: 50%" />
                  <col style="width: 50%" />
                </colgroup>
                <tbody>
                  <tr>
                    <td data-label="access">denied</td>
                    <td data-label="matches (7D)">30</td>
                  </tr>
                  <tr>
                    <td data-label="matches won">60</td>
                    <td data-label="matches lost">40</td>
                  </tr>
                </tbody>
              </table>
            </div>
          {/if}
        </div>
      </td>
      <td class="stats">
        {#if cardPanel}
          {@render cardPanel?.()}
        {:else}
          <div class="panel">
            <CircularProgress radius={100} pathWidth={5} value={60} />
            <span id="first" role="contentinfo" data-label="1st"> 40 </span>
            <span id="second" role="contentinfo" data-label="2nd"> 60 </span>
          </div>
        {/if}
      </td>
    </tr>
    <tr> </tr>
  </tbody>
</table>

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
  }

  .summary #season-parallel {
    position: absolute;
    top: 5%;
    right: 5%;
    width: 120px;
    /* opacity: 70%; */
  }

  .summary > div:nth-child(1) {
    font-size: xx-large;
    z-index: 1;
    position: relative;
  }

  .summary > div:nth-child(2) {
    font-size: x-large;
    z-index: 1;
    position: relative;
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

  .details table {
    margin-top: 1em;
    border-collapse: collapse;

    td {
      position: relative;
      border-left: 4px solid #def141;
      padding-left: 8px;
      padding-top: 0.75em;
      font-weight: 500;
      font-size: xx-large;
    }

    td::before {
      position: absolute;
      top: 0;
      left: 8px;
      content: attr(data-label);
      text-transform: uppercase;
      font-size: large;
      font-weight: lighter;
    }
  }

  .stats .panel {
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
</style>
