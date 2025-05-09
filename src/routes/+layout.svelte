<script lang="ts">
  import {page} from "$app/state";
  import {PUBLIC_SUPABASE_URL} from "$env/static/public";
  import {goto, invalidate} from "$app/navigation";
  import {onMount} from "svelte";
  import PlayerCard from "$lib/PlayerCard.svelte";
  import {selectedStream} from "$lib/streamStore.js";
  import {fly} from "svelte/transition";
  import Icon from "$lib/parallels/Icon.svelte";
  import {Universal} from "$lib/parallels/parallel";
  import {uplinkCardDetails} from "./PageCardDetails.svelte";
  import {matchCardDetails} from "./matches/PageCardDetails.svelte";
  import {profileCardDetails} from "./profile/PageCardDetails.svelte";
  import {uplinkCardPanel} from "./PageCardPanel.svelte";
  import {profileCardPanel} from "./profile/PageCardPanel.svelte";

  const {children, data} = $props();

  const {supabase, user, session, account, season} = $derived(data);

  let mouseMove = $state({x: -1000, y: -1000});

  const links = [{href: "/", text: "uplink"}];

  const authorizedLinks = [
    {href: "/matches", text: "matches"},
    // {href: "/console", text: "console"},
    {href: "/profile", text: "profile"},
  ];

  function handleMouseMove(mouseMoved: MouseEvent) {
    if (
      mouseMoved.clientX + mouseMoved.movementX <= 8 ||
      mouseMoved.clientY + mouseMoved.movementY <= 8 ||
      mouseMoved.clientX + mouseMoved.movementX >= window.innerWidth - 8 ||
      mouseMoved.clientY + mouseMoved.movementY >= window.innerHeight - 8
    ) {
      mouseMove.x = -1000;
      mouseMove.y = -1000;
    } else {
      mouseMove.x = mouseMoved.clientX;
      mouseMove.y = mouseMoved.clientY;
    }
  }

  onMount(() => {
    const {
      data: {subscription},
    } = supabase.auth.onAuthStateChange((_, newSession) => {
      if (newSession?.expires_at !== session?.data.session?.expires_at) {
        invalidate("supabase:auth");
      }
    });

    return () => subscription.unsubscribe();
  });
</script>

<svelte:window onmousemove={handleMouseMove} />

<svelte:head>
  <link rel="preconnect" href={PUBLIC_SUPABASE_URL} />
</svelte:head>

{#if $selectedStream}
  <div transition:fly={{x: 500}} class="stream-overlay">
    <div class="stream">
      <div class="placeholder">
        <Icon parallel={Universal} />
      </div>
      <iframe
        src="https://player.twitch.tv/?channel={$selectedStream.user_name}&parent={window
          .location.hostname}"
        allowfullscreen
        allow="fullscreen; picture-in-picture"
        frameborder="0"
        scrolling="no"
        height="225"
        width="400"
        title="Twitch stream: {$selectedStream.user_name}"
      ></iframe>
    </div>
    <button
      class="close-stream"
      onclick={() => {
        $selectedStream = null;
      }}
    >
      close stream
    </button>
  </div>
{/if}

<div class="nav">
  <a href="/">
    <h2 id="title">
      <!-- <img src="/brands/primea.svg" alt="Primea" /> -->
      PRIMEA
    </h2>
  </a>
  <nav>
    {#each links as { href, text }, i}
      <a
        class="nav-link"
        {href}
        data-label={`DATA_PANEL[${i + 1}]`}
        class:selected={href === page.url.pathname}
      >
        {text}
      </a>
    {/each}
    {#if user}
      {#each authorizedLinks as { href, text }, i}
        <a
          class="nav-link"
          {href}
          data-label={`DATA_PANEL[${i + links.length + 1}]`}
          class:selected={href === page.url.pathname}
        >
          {text}
        </a>
      {/each}
      <a
        class="nav-link"
        data-label="AUTH_PANEL[02]"
        href="/"
        onclick={async (e) => {
          e.preventDefault();
          await supabase.auth.signOut();
          const response = await fetch("/auth/logout");
          await invalidate("supabase:auth");
          goto(response.headers.get("Location") ?? "/");
        }}
      >
        sign out
      </a>
    {:else}
      <a class="nav-link" data-label="AUTH_PANEL[01]" href="auth/"> sign in </a>
    {/if}
  </nav>
</div>

<div class="body">
  <div
    class="background"
    style="--mouse-x: {mouseMove.x}px; --mouse-y: {mouseMove.y}px;"
  ></div>
  <div class="content">
    {#if page.url.pathname !== "/auth"}
      <PlayerCard {user} {account} {season}>
        {#snippet cardDetails()}
          {#if page.route.id === "/" && !!page.data.uplinkData}
            {@render uplinkCardDetails(page.data.uplinkData)}
          {:else if page.route.id === "/matches" && !!page.data.matchData}
            {@render matchCardDetails(page.data.matchData)}
          {:else if page.route.id === "/profile" && !!page.data.profileData}
            {@render profileCardDetails(page.data.profileData)}
          {:else}
            <div class="summary">
              <table>
                <colgroup>
                  <col style="width: 50%" />
                  <col style="width: 50%" />
                </colgroup>
                <tbody>
                  <tr>
                    <td data-label="n/a"> unknown </td>
                    <td data-label="n/a"> unknown </td>
                  </tr>
                  <tr>
                    <td data-label="n/a"> unknown </td>
                    <td data-label="n/a"> unknown </td>
                  </tr>
                </tbody>
              </table>
            </div>
          {/if}
        {/snippet}
        {#snippet cardPanel()}
          {#if page.route.id === "/" && !!page.data.uplinkPanel}
            {@render uplinkCardPanel(page.data.uplinkPanel)}
          {:else if page.route.id === "/matches" && !!page.data.matchPanel}
            {@render uplinkCardPanel(page.data.matchPanel)}
          {:else if page.route.id === "/profile" && !!page.data.profilePanel}
            {@render profileCardPanel(page.data.profilePanel)}
          {:else}
            <div></div>
          {/if}
        {/snippet}
      </PlayerCard>
    {/if}
    {@render children()}
  </div>
</div>

<div class="footer">
  <div>
    <span>
      <img src="/brands/echelon.svg" alt="echelon" />
      <span>
        <p>echelon</p>
        <p>foundation</p>
      </span>
    </span>
    <p>official partner</p>
  </div>
  <p>primea world © 2025</p>
</div>

<style>
  :global(html) {
    scrollbar-gutter: stable;
  }

  :global(:root) {
    --color-primary: #def141;
    --color-secondary: #131313;
    --text-color: #dcdcdc;
    --text-dim: #ffffff40;
    --surface-color: #131313;

    /* material colors */
    --green: #4caf50;
    --red: #f44336;
  }

  :global(dialog) {
    font-family: "Chakra Petch", sans-serif;
    color: var(--text-color);
    background-color: #1c1f15;
  }

  :global(body) {
    margin-top: 0;
    font-family: "Chakra Petch", sans-serif;
    color: var(--text-color);
    background-color: var(--surface-color);
  }

  :global(.material-symbols-outlined) {
    font-variation-settings:
      "FILL" 0,
      "wght" 400,
      "GRAD" 0,
      "opsz" 24;
  }

  :global(.material-symbols-rounded) {
    font-variation-settings:
      "FILL" 1,
      "wght" 400,
      "GRAD" 0,
      "opsz" 24;
  }

  :global(.text-ellipsis) {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .body {
    min-height: calc(100svh - 21px - 1.33em * 2 - 53px - 1em);
  }

  .background {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: radial-gradient(
      circle,
      var(--color-primary) 2px,
      transparent 3px
    );
    background-size: 2em 2em;
    mask-image: radial-gradient(
        circle 45svw at 32% 87%,
        #ffffff88 20%,
        transparent 60%
      ),
      radial-gradient(circle 45svw at 68% 40%, #ffffff88 20%, transparent 60%),
      radial-gradient(
        circle 10svw at var(--mouse-x) var(--mouse-y),
        #ffffff88 20%,
        transparent 60%
      );
    -webkit-mask-image: radial-gradient(
        circle 45svw at 32% 87%,
        #ffffff88 20%,
        transparent 60%
      ),
      radial-gradient(circle 45svw at 68% 40%, #ffffff88 20%, transparent 60%),
      radial-gradient(
        circle 10svw at var(--mouse-x) var(--mouse-y),
        #ffffffff 20%,
        transparent 60%
      );
  }

  .stream-overlay {
    position: fixed;
    right: 1em;
    bottom: 2em;
    z-index: 10;

    .stream {
      position: relative;

      iframe {
        position: relative;
      }

      .placeholder {
        position: absolute;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #000;
      }
    }

    .close-stream {
      width: 100%;
      background-color: #000;
      color: var(--color-primary);
      border: var(--color-primary) 2px solid;
      text-transform: uppercase;
      font-family: inherit;
      font-size: large;
    }
  }

  .content {
    position: relative;
  }

  a:link,
  a:visited,
  a:hover,
  a:active {
    text-decoration: none;
    color: inherit;
  }

  #title {
    margin: 0.4rem;
    display: flex;
    align-items: center;

    /* > img {
      aspect-ratio: 1;
      width: 1.33em;
      margin-right: 0.5em;
    } */
  }

  .nav {
    position: sticky;
    top: 0;
    z-index: 100; /* Ensure it's above other elements */
    display: flex;
    justify-content: space-between;
    text-transform: uppercase;
    background-color: #131313d1;
  }

  .nav-link {
    display: inline-flex;
    padding: 0 1em 0 0;
    position: relative;
    text-decoration: none;
    color: inherit;
  }

  .nav-link:hover {
    color: var(--color-primary); /* Brighten the text on hover */
  }

  .nav-link::before {
    content: attr(data-label); /* Show the data panel text */
    position: absolute;
    bottom: -18px; /* Adjust for spacing below the link */
    left: 0;
    font-size: 0.6rem; /* Smaller size for data panel text */
    color: var(--text-dim); /* Dimmer color */
    text-transform: none; /* Keep as lowercase */
    transition: color 0.3s; /* Smooth hover effect */
  }

  .nav-link::after {
    content: "";
    position: absolute;
    bottom: -5px; /* Space between text and underline */
    left: 0;
    width: 100%;
    height: 2px; /* Default thin underline */
    background: var(--text-dim); /* Dimmed underline for non-selected */
    transition:
      background 0.3s,
      height 0.3s; /* Smooth hover effect */
  }

  .nav-link.selected::after {
    height: 3px; /* Thicker underline for selected link */
    background: var(--text-color); /* Brighter underline */
  }

  .nav-link.selected::before {
    color: var(--text-color); /* Highlight the data panel text */
  }

  .footer {
    margin-top: 1em;
    display: flex;
    justify-content: space-between;
    align-items: end;
    background-color: var(--color-secondary);
    color: var(--text-color);

    img {
      margin-top: 0.5rem;
    }

    > div {
      display: flex;
      flex-direction: column;
      > span {
        display: grid;
        grid-auto-flow: column;
        > span > p {
          margin: 0;
          text-transform: uppercase;
          font-weight: 600;
          line-height: 1;
        }
      }
      > p {
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
    }
    > p {
      margin: 0;
      text-transform: uppercase;
      font-size: small;
      color: var(--text-dim);
    }
  }
</style>
