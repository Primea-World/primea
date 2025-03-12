<script lang="ts">
  import CircularProgress from "$lib/CircularProgress.svelte";
  import Icon from "$lib/parallels/Icon.svelte";

  const {data} = $props();

  const {paragons, parallelSummaries} = data;
</script>

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
            style="background-image: url(/paragons/{paragon.camelCaseName}.webp); background-position-y: {paragon.focalPoint}px;"
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
</style>
