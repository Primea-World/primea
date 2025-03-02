<script lang="ts">
  import {ParallelProfile} from "$lib/parallelProfile.js";
  import PlayerCard from "$lib/PlayerCard.svelte";
  import {supabase, user} from "$lib/supabase";
  import {type Provider} from "@supabase/supabase-js";

  let {data} = $props();

  const sampleSettings = [
    {
      game_type: "ranked",
      publish_game_overview: undefined,
      include_deck_content: undefined,
      include_game_stream: undefined,
      include_primary_wallet: undefined,
    },
    {
      game_type: "private",
      publish_game_overview: undefined,
      include_deck_content: undefined,
      include_game_stream: undefined,
      include_primary_wallet: undefined,
    },
    {
      game_type: "training_bot",
      publish_game_overview: undefined,
      include_deck_content: undefined,
      include_game_stream: undefined,
      include_primary_wallet: undefined,
    },
  ];
</script>

<PlayerCard
  parallelProfile={data.account?.then(
    (account) => new ParallelProfile(account)
  )}
>
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
            {#await data.account}
              <td data-label="rank">loading</td>
              <td data-label="bracket">loading</td>
            {:then parallelAccount}
              {@const parallelProfile = new ParallelProfile(parallelAccount)}
              <td data-label="rank">{parallelProfile?.rank ?? "unknown"}</td>
              <td data-label="bracket"
                >{parallelProfile?.rank_bracket ?? "unknown"}
              </td>
            {/await}
          </tr>
        </tbody>
      </table>
    </div>
  {/snippet}
  {#snippet cardPanel()}
    {#await data.account}
      <div
        class="panel title"
        style="background-image: url(/unknown_origins.avif);"
      >
        <h2>LOADING</h2>
      </div>
    {:then parallelAccount}
      {@const parallelProfile = new ParallelProfile(parallelAccount)}
      {#if parallelProfile?.avatar.image_url}
        <div
          class="panel title"
          style="background-image: url({parallelProfile?.avatar.image_url});"
        >
          <h2>{parallelProfile.avatar.name}</h2>
        </div>
      {:else if parallelProfile?.django_profile.picture_url}
        <div
          class="panel"
          style="background-image: url({parallelProfile?.django_profile
            .picture_url});"
        ></div>
      {:else if $user?.user_metadata.avatar_url}
        <div
          class="panel"
          style="background-image: url({$user?.user_metadata.avatar_url});"
        ></div>
      {:else}
        <div
          class="panel title"
          style="background-image: url(/unknown_origins.avif);"
        >
          <h2>UNKNOWN</h2>
        </div>
      {/if}
    {/await}
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
          {#await data.account}
            <p>parallel account: loading</p>
            <p>title: loading</p>
            <p>rank: loading</p>
            <p>prismatic key: loading</p>
            <p>skeleton key: loading</p>
          {:then parallelAccount}
            {@const parallelProfile = new ParallelProfile(parallelAccount)}
            <p>parallel account: {parallelProfile.django_profile.username}</p>
            <p>title: {parallelProfile.title?.title}</p>
            <p>rank: {parallelProfile.rank ?? "unknown"}</p>
            <p>prismatic key: {parallelProfile.prismatic_parallel}</p>
            <p>
              skeleton key: {parallelProfile.skeleton_transformed_key ?? "n/a"}
            </p>
          {/await}
        </div>
      </td>
      <td>
        <div class="permissions-panel">
          {#await data.permissions}
            {#each sampleSettings as permission}
              <div class="permissions" data-label={permission.game_type}>
                <table>
                  <tbody>
                    <tr>
                      <td data-label="game overview">
                        {#if permission.publish_game_overview}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else if permission.publish_game_overview === undefined}
                          <span class="material-symbols-rounded unknown"
                            >refresh</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                      <td data-label="game stream">
                        {#if permission.include_game_stream}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else if permission.include_game_stream === undefined}
                          <span class="material-symbols-rounded unknown"
                            >refresh</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                    </tr>
                    <tr>
                      <td data-label="deck content">
                        {#if permission.include_deck_content}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else if permission.include_deck_content === undefined}
                          <span class="material-symbols-rounded unknown"
                            >refresh</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                      <td data-label="wallet">
                        {#if permission.include_primary_wallet}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else if permission.include_primary_wallet === undefined}
                          <span class="material-symbols-rounded unknown"
                            >refresh</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            {/each}
          {:then permissionsData}
            {@const permissions = JSON.parse(
              permissionsData ?? JSON.stringify(sampleSettings)
            ).settings}
            {#each permissions as permission}
              <div class="permissions" data-label={permission.game_type}>
                <table>
                  <tbody>
                    <tr>
                      <td data-label="game overview">
                        {#if permission.publish_game_overview}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                      <td data-label="game stream">
                        {#if permission.include_game_stream}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                    </tr>
                    <tr>
                      <td data-label="deck content">
                        {#if permission.include_deck_content}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                      <td data-label="wallet">
                        {#if permission.include_primary_wallet}
                          <span class="material-symbols-rounded green"
                            >check</span
                          >
                        {:else}
                          <span class="material-symbols-rounded red">close</span
                          >
                        {/if}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            {/each}
          {/await}
          <a href="https://parallel.life/settings/security"
            >manage permissions<span class="material-symbols-rounded">
              open_in_new
            </span>
          </a>
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

  .panel.title {
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

  .permissions-panel {
    background-color: #000000cb;
    max-width: 250px;
  }

  .permissions-panel a:hover {
    background-color: var(--color-primary);
    color: black;
  }

  .permissions-panel a {
    text-decoration: none;
    text-transform: uppercase;
    color: var(--color-primary);
    text-align: center;
    padding: 0.5em;
    margin: 0.5em 0 0;
    border: thin solid var(--color-primary);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .permissions-panel a > span {
    text-transform: none;
  }

  .permissions::before {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    text-align: center;
    content: attr(data-label);
    text-transform: uppercase;
    font-size: large;
    font-weight: lighter;
    color: var(--text-color);
  }

  .permissions {
    padding: 1.45em 1em 0;
    background-color: #000000cb;
    max-width: calc(250px - 2em);
    position: relative;
  }

  .permissions table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
  }

  .permissions tbody {
    margin-top: 0.5em;
  }

  .permissions td::before {
    position: absolute;
    top: 0;
    left: 8px;
    content: attr(data-label);
    text-transform: uppercase;
    font-size: x-small;
    font-weight: lighter;
    color: var(--text-color);
  }
  .permissions td {
    position: relative;
    border-left: 4px solid #def141;
    padding-left: 8px;
    padding-top: 0.25em;
    font-weight: 500;
    font-size: xx-large;
    text-transform: uppercase;
  }

  .permissions .green {
    color: #00ab00;
  }

  .permissions .red {
    color: #ab0000;
  }

  .permissions .unknown {
    color: #808080;
    animation: infinite 2s linear;
    animation-name: spin;
  }

  @keyframes spin {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(360deg);
    }
  }
</style>
