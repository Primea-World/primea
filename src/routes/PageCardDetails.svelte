<script module lang="ts">
  import type {UplinkDetailsParameters} from "$lib/playerCardData";
  import Typewriter from "$lib/Typewriter.svelte";

  export {uplinkCardDetails};
</script>

{#snippet uplinkCardDetails(parameters: UplinkDetailsParameters)}
  {@const {rows} = parameters}
  <div class="summary">
    <table>
      <colgroup>
        <col style="width: 50%" />
        <col style="width: 50%" />
      </colgroup>
      <tbody>
        {#each rows as row}
          <tr>
            {#each row as [label, value]}
              <td data-label={label}>
                <Typewriter text={value} />
              </td>
            {/each}
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/snippet}

<style>
  .summary {
    background-color: #000;
  }

  .summary table {
    margin-top: 1em;
    border-collapse: collapse;
    width: 100%;
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
</style>
