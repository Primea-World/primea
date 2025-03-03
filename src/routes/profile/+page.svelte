<script lang="ts">
  import {page} from "$app/state";
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
              {#if !!parallelAccount?.parallel_profile}
                {@const parallelProfile = new ParallelProfile(parallelAccount)}
                <td data-label="rank">{parallelProfile?.rank ?? "unknown"}</td>
                <td data-label="bracket"
                  >{parallelProfile?.rank_bracket ?? "unknown"}
                </td>
              {:else}
                <td data-label="rank">unknown</td>
                <td data-label="bracket">unknown </td>
              {/if}
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
      {#if !!parallelAccount?.parallel_profile}
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
        {/if}
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

{#snippet samplePermissions()}
  {#each sampleSettings as permission}
    <div class="permissions" data-label={permission.game_type}>
      <table>
        <tbody>
          <tr>
            <td data-label="game overview">
              {#if permission.publish_game_overview}
                <span class="material-symbols-rounded green">check</span>
              {:else if permission.publish_game_overview === undefined}
                <span class="material-symbols-rounded unknown">refresh</span>
              {:else}
                <span class="material-symbols-rounded red">close</span>
              {/if}
            </td>
            <td data-label="game stream">
              {#if permission.include_game_stream}
                <span class="material-symbols-rounded green">check</span>
              {:else if permission.include_game_stream === undefined}
                <span class="material-symbols-rounded unknown">refresh</span>
              {:else}
                <span class="material-symbols-rounded red">close</span>
              {/if}
            </td>
          </tr>
          <tr>
            <td data-label="deck content">
              {#if permission.include_deck_content}
                <span class="material-symbols-rounded green">check</span>
              {:else if permission.include_deck_content === undefined}
                <span class="material-symbols-rounded unknown">refresh</span>
              {:else}
                <span class="material-symbols-rounded red">close</span>
              {/if}
            </td>
            <td data-label="wallet">
              {#if permission.include_primary_wallet}
                <span class="material-symbols-rounded green">check</span>
              {:else if permission.include_primary_wallet === undefined}
                <span class="material-symbols-rounded unknown">refresh</span>
              {:else}
                <span class="material-symbols-rounded red">close</span>
              {/if}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  {/each}
{/snippet}

<table class="parallel-account">
  <colgroup>
    <col class="main" />
    <col class="secondary" />
  </colgroup>
  <tbody>
    <tr>
      <td>
        {#await data.account}
          <div class="parallel-account-link">
            <div class="link-overlay">
              <h2 style="color: black;">LOADING</h2>
            </div>
            <img src="/parallels/parallel.svg" alt="parallel" />
            <h2 data-label="unknown">unknown</h2>
            <button
              class="link"
              onclick={async (e) => {
                e.preventDefault();
                console.log("Unlinking parallel account");
              }}
            >
              UNLINK ACCOUNT
            </button>
            <div class="keys">
              <div>
                <video autoplay loop muted>
                  <source
                    src="https://nftmedia.parallelnft.com/parallel-alpha/QmPBM3hvi8dZ2CFwDSeJHTSWPkr3au7unMDSEckBaLwMHR/animation.mp4"
                    type="video/mp4"
                  />
                </video>
                <div data-label="prismatic key">UNKNOWN</div>
              </div>
              <div>
                <img
                  src="https://nftmedia.parallelnft.com/parallel-planetfall/QmWWNiwppSggPYCsUxWj3GswARnZ3tbpYPBMCUyjWyCqSo/image.png"
                  alt="skeleton key"
                />
                <div data-label="skeleton key">UNKNOWN</div>
              </div>
            </div>
          </div>
        {:then parallelAccount}
          <div class="parallel-account-link">
            {#if !parallelAccount}
              <div class="link-overlay">
                <a
                  href={"/profile/parallel?redirect=" + page.url.pathname}
                  class="link"
                >
                  <h2>LINK PARALLEL ACCOUNT</h2>
                </a>
              </div>
            {/if}
            <img src="/parallels/parallel.svg" alt="parallel" />
            {#if parallelAccount?.parallel_profile}
              {@const parallelProfile = new ParallelProfile(parallelAccount)}
              <h2 data-label={parallelProfile?.title?.title}>
                {parallelProfile?.django_profile.username}
              </h2>
              <button
                class="link"
                onclick={async (e) => {
                  e.preventDefault();
                  console.log("Unlinking parallel account");
                  document.cookie = `parallel-auth=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
                  await $supabase.auth.updateUser({
                    data: {
                      parallel: null,
                    },
                  });
                  window.location.reload();
                }}
              >
                UNLINK ACCOUNT
              </button>
              <div class="keys">
                <div>
                  <video autoplay loop muted>
                    <source
                      src="https://nftmedia.parallelnft.com/parallel-alpha/QmPBM3hvi8dZ2CFwDSeJHTSWPkr3au7unMDSEckBaLwMHR/animation.mp4"
                      type="video/mp4"
                    />
                  </video>
                  <div data-label="prismatic key">
                    {parallelProfile.prismatic_parallel ?? "n/a"}
                  </div>
                </div>
                <div>
                  <img
                    src="https://nftmedia.parallelnft.com/parallel-planetfall/QmWWNiwppSggPYCsUxWj3GswARnZ3tbpYPBMCUyjWyCqSo/image.png"
                    alt="skeleton key"
                  />
                  <div data-label="skeleton key">
                    {parallelProfile.skeleton_transformed_key ?? "n/a"}
                  </div>
                </div>
              </div>
            {:else}
              <h2 data-label="unknown">unknown</h2>
              <button
                class="link"
                onclick={async (e) => {
                  e.preventDefault();
                  console.log("Linking parallel account");
                }}
              >
                LINK ACCOUNT
              </button>
              <div class="keys">
                <div>
                  <video autoplay loop muted>
                    <source
                      src="https://nftmedia.parallelnft.com/parallel-alpha/QmPBM3hvi8dZ2CFwDSeJHTSWPkr3au7unMDSEckBaLwMHR/animation.mp4"
                      type="video/mp4"
                    />
                  </video>
                  <div data-label="prismatic key">UNKNOWN</div>
                </div>
                <div>
                  <img
                    src="https://nftmedia.parallelnft.com/parallel-planetfall/QmWWNiwppSggPYCsUxWj3GswARnZ3tbpYPBMCUyjWyCqSo/image.png"
                    alt="skeleton key"
                  />
                  <div data-label="skeleton key">UNKNOWN</div>
                </div>
              </div>
            {/if}
          </div>
        {/await}
      </td>
      <td>
        <div class="permissions-panel">
          {#await data.permissions}
            {@render samplePermissions()}
          {:then permissionsData}
            {#if permissionsData}
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
                            <span class="material-symbols-rounded red"
                              >close</span
                            >
                          {/if}
                        </td>
                        <td data-label="game stream">
                          {#if permission.include_game_stream}
                            <span class="material-symbols-rounded green"
                              >check</span
                            >
                          {:else}
                            <span class="material-symbols-rounded red"
                              >close</span
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
                            <span class="material-symbols-rounded red"
                              >close</span
                            >
                          {/if}
                        </td>
                        <td data-label="wallet">
                          {#if permission.include_primary_wallet}
                            <span class="material-symbols-rounded green"
                              >check</span
                            >
                          {:else}
                            <span class="material-symbols-rounded red"
                              >close</span
                            >
                          {/if}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              {/each}
            {:else}
              {@render samplePermissions()}
            {/if}
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

  .panel {
    position: relative;
    width: 100%;
    height: 263px;
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
    display: flex;
    flex-direction: column;
  }

  table.parallel-account tr td:nth-child(2) {
    max-width: 250px;
  }

  table.parallel-account .parallel-account-link {
    background-color: #000000cb;
    position: relative;
  }

  table.parallel-account .parallel-account-link > h2 {
    margin: 0.19em;
    position: relative;
    text-transform: uppercase;
  }

  table.parallel-account .parallel-account-link > h2::after {
    content: attr(data-label);
    position: absolute;
    bottom: -1em;
    left: 0;
    font-size: small;
    color: #ffffff9c;
    text-transform: none;
  }

  table.parallel-account .parallel-account-link > img {
    width: 100%;
    aspect-ratio: 550/110;
  }

  table.parallel-account .parallel-account-link .keys {
    display: flex;
    margin: 1em 0;
  }

  table.parallel-account .parallel-account-link .keys > div {
    flex: 1;
    display: flex;
    position: relative;
  }

  table.parallel-account .parallel-account-link .keys video,
  table.parallel-account .parallel-account-link .keys img {
    object-fit: cover;
    object-position: top;
    aspect-ratio: 200 / 240;
    width: 6em;
  }

  table.parallel-account .parallel-account-link .keys > div > div {
    position: relative;
    text-transform: uppercase;
    vertical-align: middle;
    font-size: x-large;
    font-weight: 600;
    margin-top: 1em;
    padding-left: 0.5em;
  }

  table.parallel-account .parallel-account-link .keys > div > div::after {
    content: attr(data-label);
    text-transform: uppercase;
    position: absolute;
    top: -1.6em;
    left: 1em;
    font-size: small;
    white-space: nowrap;
  }

  .link-overlay {
    position: absolute;
    width: 90%;
    height: 90%;
    margin: auto;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #c9c9c9ed;
    z-index: 1;
  }

  .link-overlay > a:hover {
    background-color: black;
    color: var(--color-primary);
  }

  .link-overlay > a {
    text-decoration: none;
    text-transform: uppercase;
    background-color: var(--color-primary);
    color: black;
    text-align: center;
    padding: 0.5em;
    margin: 0.5em 0 0;
    border: thin solid black;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .parallel-account-link .link:hover {
    background-color: var(--color-primary);
    color: black;
  }

  .parallel-account-link .link {
    width: 85%;
    margin: 1em auto;
    color: var(--color-primary);
    background-color: var(--surface-color);
    border: thin solid var(--color-primary);
    padding: 0.5em;
    cursor: pointer;
    font-family: "Chakra Petch";
    font-size: larger;
    font-weight: 600;
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
    padding: 1.45em 0 0;
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
