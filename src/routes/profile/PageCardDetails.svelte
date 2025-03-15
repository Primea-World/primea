<script module lang="ts">
  import type {ProfileDetailsParameters} from "$lib/playerCardData";
  import Typewriter from "$lib/Typewriter.svelte";
  import type {Provider, UserIdentity} from "@supabase/supabase-js";

  export {profileCardDetails};

  const supportedProviders: Provider[] = ["twitch", "discord"];
</script>

{#snippet identityRow(
  provider: Provider,
  linkIdentity: ProfileDetailsParameters["linkIdentity"],
  unlinkIdentity: ProfileDetailsParameters["unlinkIdentity"],
  identity?: UserIdentity
)}
  <td
    class="social"
    class:identity={!!identity}
    data-label={provider}
    onclick={async (e) => {
      e.preventDefault();
      console.log(`Unlinking ${provider}`);
      if (!!identity) {
        await unlinkIdentity(identity);
      } else {
        await linkIdentity({provider});
      }
    }}
  >
    {#if identity}
      {identity.identity_data?.name ||
        identity.identity_data?.nickname ||
        identity.identity_data?.email ||
        "linked"}
    {:else}
      link
    {/if}
  </td>
{/snippet}

{#snippet profileCardDetails(parameters: ProfileDetailsParameters)}
  {@const {unlinkIdentity, linkIdentity, user, account} = parameters}
  <div class="summary">
    <table>
      <colgroup>
        <col style="width: 50%" />
        <col style="width: 50%" />
      </colgroup>
      <tbody>
        <tr>
          {#each supportedProviders as provider}
            {@const identity = user?.identities?.find(
              (i) => i.provider == provider
            )}
            {@render identityRow(
              provider,
              linkIdentity,
              unlinkIdentity,
              identity
            )}
          {/each}
        </tr>
        <tr>
          <td data-label="rank">
            <Typewriter
              text={account?.then((parallelAccount) => parallelAccount.rank)}
              defaultText="unranked"
            />
          </td>
          <td data-label="bracket">
            <Typewriter
              text={account?.then(
                (parallelAccount) => parallelAccount.rank_bracket
              )}
              defaultText="unranked"
            />
          </td>
        </tr>
      </tbody>
    </table>
  </div>
{/snippet}

<style>
  .summary table {
    margin-top: 1em;
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
  }

  .summary td {
    position: relative;
    border-left: 4px solid #def141;
    padding-left: 8px;
    padding-top: 0.75em;
    font-weight: 500;
    font-size: xx-large;
    text-transform: uppercase;
  }

  .summary td::before {
    position: absolute;
    top: 0;
    left: 8px;
    content: attr(data-label);
    text-transform: uppercase;
    font-size: large;
    font-weight: lighter;
    color: var(--text-color);
    transition: color 0.2s;
  }

  .summary td.social {
    overflow: hidden;
    color: #008000;
    transition: color 0.2s;
    cursor: pointer;
  }

  .summary td.social.identity:hover {
    content: "unlink";
    overflow: hidden;
    color: #800000;
  }

  .summary td.social.identity:hover::before {
    content: "unlink";
    color: #800000;
  }
</style>
