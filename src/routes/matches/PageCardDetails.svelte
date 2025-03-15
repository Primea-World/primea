<script module lang="ts">
  import type {MatchesDetailParameters} from "$lib/playerCardData";
  import Typewriter from "$lib/Typewriter.svelte";

  export {matchCardDetails};
</script>

{#snippet matchCardDetails(parameters: MatchesDetailParameters)}
  {@const {totalMatches, pasProfile, account} = parameters}
  <div class="summary">
    <table>
      <colgroup>
        <col style="width: 50%" />
        <col style="width: 50%" />
      </colgroup>
      <tbody>
        {#await pasProfile}
          <tr>
            <td data-label="win streak">0</td>
            <td data-label="MMR">0</td>
          </tr>
          <tr>
            <td data-label="matches won">0</td>
            <td data-label="matches lost">0</td>
          </tr>
        {:then profile}
          <tr>
            <td data-label="win streak">
              <Typewriter
                text={totalMatches.then((matches) => {
                  if (!matches) {
                    return 0;
                  }
                  let winStreak = 0;
                  for (let i = 0; i < matches.length; i++) {
                    if (matches[i].winner_id == profile?.account_id) {
                      winStreak++;
                    } else {
                      break;
                    }
                  }
                  return winStreak;
                })}
                defaultText="0"
              />
            </td>
            <td data-label="MMR">
              <Typewriter
                text={account?.then((account) => account.mmr)}
                defaultText="UNRANKED"
              />
            </td>
          </tr>
          <tr>
            <td data-label="matches won">
              <Typewriter
                text={totalMatches.then(
                  (matches) =>
                    matches?.filter(
                      (match) => match.winner_id == profile?.account_id
                    ).length
                )}
                defaultText="0"
              />
            </td>
            <td data-label="matches lost">
              <Typewriter
                text={totalMatches.then(
                  (matches) =>
                    matches?.filter(
                      (match) => match.winner_id != profile?.account_id
                    ).length
                )}
                defaultText="0"
              />
            </td>
          </tr>
        {/await}
      </tbody>
    </table>
  </div>
{/snippet}

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
</style>
