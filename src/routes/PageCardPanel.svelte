<script module lang="ts">
  import CircularProgress from "$lib/CircularProgress.svelte";
  import type {Action} from "svelte/action";
  import type {UplinkPanelParameters} from "$lib/playerCardData";

  let winRate = $state(0);
  let winRateLabel: string | undefined = $state();

  const setWinRate: Action<Element, UplinkPanelParameters> = (
    _: Node,
    data: UplinkPanelParameters
  ) => {
    updateWinRate(data);
  };

  async function updateWinRate(
    parameters: UplinkPanelParameters,
    playerOne?: boolean
  ) {
    let total: number = 0,
      wins: number = 0;

    const {totalMatches, pasProfile} = parameters;
    const [matches, profile] = await Promise.all([totalMatches, pasProfile]);

    if (!profile || !matches) {
      winRate = 0;
      return;
    }

    switch (playerOne) {
      case undefined:
        total = matches.length;
        wins = matches.reduce((acc, match) => {
          if (match.winner_id == profile.account_id) {
            acc++;
          }
          return acc;
        }, 0);
        winRateLabel = "WIN RATE";
        break;
      case false:
        matches.forEach((match) => {
          if (match.player_two_id == profile.account_id) {
            total++;
            if (match.winner_id == profile.account_id) {
              wins++;
            }
          }
        });
        winRateLabel = "ON THE DRAW";
        break;
      default:
        matches.forEach((match) => {
          if (match.player_one_id == profile.account_id) {
            total++;
            if (match.winner_id == profile.account_id) {
              wins++;
            }
          }
        });
        winRateLabel = "ON THE PLAY";
        break;
    }

    winRate = Math.round((wins / total) * 100);
    if (isNaN(winRate)) {
      winRate = 0;
    }
  }

  export {cardPanel, type UplinkPanelParameters};
</script>

{#snippet cardPanel(parameters: UplinkPanelParameters)}
  {@const {totalMatches, pasProfile} = parameters}
  <div use:setWinRate={{totalMatches, pasProfile}} class="stats">
    <CircularProgress
      radius={85}
      pathWidth={5}
      bind:value={winRate}
      label={winRateLabel}
    />
    <span
      id="first"
      role="contentinfo"
      onmouseenter={(e) => {
        e.preventDefault();
        updateWinRate(parameters, true);
      }}
      onmouseleave={(e) => {
        e.preventDefault();
        updateWinRate(parameters);
      }}
      onfocus={(e) => {
        e.preventDefault();
        updateWinRate(parameters, true);
      }}
      data-label="ON THE PLAY"
    >
      {#await pasProfile}
        0
      {:then profile}
        {#if profile}
          {#await totalMatches}
            0
          {:then matches}
            {matches?.filter(
              (match) => match.player_one_id == profile.account_id
            ).length ?? 0}
          {/await}
        {:else}
          0
        {/if}
      {/await}
    </span>
    <span
      id="second"
      role="contentinfo"
      onmouseenter={(e) => {
        e.preventDefault();
        updateWinRate(parameters, false);
      }}
      onmouseleave={(e) => {
        updateWinRate(parameters);
      }}
      onfocus={(e) => {
        e.preventDefault();
        updateWinRate(parameters, false);
      }}
      data-label="ON THE DRAW"
    >
      {#await pasProfile}
        0
      {:then profile}
        {#if profile}
          {#await totalMatches}
            0
          {:then matches}
            {matches?.filter(
              (match) => match.player_two_id == profile.account_id
            ).length ?? 0}
          {/await}
        {:else}
          0
        {/if}
      {/await}
    </span>
  </div>
{/snippet}

<style>
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
    width: 6rem;
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
    width: 6rem;
    text-align: end;
  }
</style>
