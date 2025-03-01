<script lang="ts">
  import PlayerCard from "$lib/PlayerCard.svelte";
  import {supabase, user} from "$lib/supabase";
  import {type Provider} from "@supabase/supabase-js";
</script>

<PlayerCard>
  {#snippet cardDetails()}
    <div class="summary">
      <table>
        <colgroup>
          <col style="width: 50%" />
          <col style="width: 50%" />
        </colgroup>
        <tbody>
          <tr>
            {#each ["twitch", "discord"] as provider}
              {@const identity = $user?.identities?.find(
                (i) => i.provider == provider
              )}
              <td
                class="social"
                class:identity={!!identity}
                data-label={provider}
                onclick={async (e) => {
                  e.preventDefault();
                  console.log(`Unlinking ${provider}`);
                  if (!!identity) {
                    await $supabase.auth.unlinkIdentity(identity);
                  } else {
                    await $supabase.auth.linkIdentity({
                      provider: provider as Provider,
                    });
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
            {/each}
          </tr>
          <tr>
            <td data-label="decks">18</td>
            <td data-label="rank">unknown</td>
          </tr>
        </tbody>
      </table>
    </div>
  {/snippet}
  {#snippet cardPanel()}
    {#if $user?.user_metadata.avatar_url}
      <div
        class="panel"
        style="background-image: url({$user?.user_metadata.avatar_url});"
      ></div>
    {:else}
      <div
        class="panel no-avatar"
        style="background-image: url(/unknown_origins.avif);"
      >
        <h2>UNKNOWN</h2>
      </div>
    {/if}
  {/snippet}
</PlayerCard>

<table class="parallel-account">
  <colgroup>
    <col class="main" />
    <col class="secondary" />
  </colgroup>
  <tbody>
    <tr>
      <td>
        <div class="parallel-account-link">
          <img src="/parallels/parallel.svg" alt="parallel" />

          <button
            onclick={(e) => {
              e.preventDefault();
              console.log("Linking parallel account");
              window.location.href =
                "/profile/parallel?redirect=" + window.location.pathname;
            }}>link parallel account</button
          >
          <h2>link parallel account</h2>
        </div>
      </td>
      <td>
        <div>
          <p>ranked</p>
          <p>overview</p>
          <p>deck</p>
          <p>stream</p>
          <p>wallet</p>
        </div>
        <div>
          <p>unranked</p>
          <p>overview</p>
          <p>deck</p>
          <p>stream</p>
          <p>wallet</p>
        </div>
        <div>
          <p>private</p>
          <p>overview</p>
          <p>deck</p>
          <p>stream</p>
          <p>wallet</p>
        </div>
      </td>
    </tr>
  </tbody>
</table>

<style>
  .summary table {
    margin-top: 0.25em;
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

  .panel {
    position: relative;
    width: 100%;
    height: 253px;
    background-position: center;
    background-size: cover;
  }

  .panel.no-avatar {
    background-color: #0000009c;
    background-blend-mode: overlay;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .panel h2 {
    text-align: center;
    font-size: xx-large;
    font-weight: 500;
    text-transform: uppercase;
  }

  table.parallel-account {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    margin-top: 2em;
  }

  table.parallel-account .main,
  table.parallel-account .secondary {
    width: 50%;
    max-width: 550px;
    margin-left: auto;
  }

  @media screen and (max-width: 1200px) {
    table.parallel-account .main {
      width: 60%;
    }
    table.parallel-account .secondary {
      width: 40%;
    }
  }

  table.parallel-account tr td:nth-child(1) > div {
    padding: 20px;
    max-width: 550px;
    margin-left: auto;
  }

  table.parallel-account tr td:nth-child(2) {
    max-width: 250px;
  }

  table.parallel-account .parallel-account-link {
    background-color: #000000cb;
  }
</style>
