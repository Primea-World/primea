<script lang="ts">
  import type {Snippet} from "svelte";
  import Icon from "./parallels/Icon.svelte";
  import {
    AUGENCORE,
    EARTHEN,
    KATHARI,
    MARCOLIAN,
    SHROUD,
    UNIVERSAL,
  } from "./parallels/parallel";
  import {user, userName} from "./supabase";
  import type {PageData} from "../routes/$types";
  import {page} from "$app/state";

  interface Props {
    cardDetails: Snippet<[]>;
    cardPanel: Snippet<[]>;
  }

  const {cardDetails, cardPanel}: Props = $props();

  const pageData = page.data as PageData;

  const season = pageData.season;

  const seasonParallel = season.then((data) => {
    switch (data.data?.parallel) {
      case "augencore":
        return AUGENCORE;
      case "earthen":
        return EARTHEN;
      case "kathari":
        return KATHARI;
      case "marcolian":
        return MARCOLIAN;
      case "shroud":
        return SHROUD;
      case "universal":
      default:
        return UNIVERSAL;
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
          <div class="text-ellipsis">USER: <b>{userName($user)}</b></div>
          {#await season}
            <div class="text-ellipsis">SEASON: <b>unknown</b></div>
          {:then seasonData}
            <div class="text-ellipsis">
              SEASON: <b>{seasonData.data?.name}</b>
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
    opacity: 70%;
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
</style>
