<script lang="ts">
  import "@fontsource/chakra-petch/300.css";
  import "@fontsource/chakra-petch/400.css";
  import "@fontsource/chakra-petch/500.css";
  import "@fontsource/chakra-petch/600.css";
  import "@fontsource/chakra-petch/700.css";
  import "@fontsource/chakra-petch/300-italic.css";
  import "@fontsource/chakra-petch/400-italic.css";
  import "@fontsource/chakra-petch/500-italic.css";
  import "@fontsource/chakra-petch/600-italic.css";
  import "@fontsource/chakra-petch/700-italic.css";
  import {page} from "$app/state";
  import SignIn from "$lib/SignIn.svelte";
  import {supabase, user} from "$lib/supabase";
  import type {Snippet} from "svelte";

  // interface Props {
  //   children: Snippet<[]>;
  //   parallel?: {
  //     accessToken: string | null;
  //     refreshToken: string | null;
  //     expiresIn: string | null;
  //     tokenType: string | null;
  //     scope: string | null;
  //   };
  // }

  let {children, data} = $props();

  let showModal = $state(false);

  let mouseMove = $state({x: 0, y: 0});

  let links = [
    {href: "/", text: "uplink"},
    {href: "/matches", text: "matches"},
    {href: "/console", text: "console"},
    {href: "/profile", text: "profile"},
  ];

  function handleMouseMove(mouseMoved: MouseEvent) {
    mouseMove.x = mouseMoved.clientX;
    mouseMove.y = mouseMoved.clientY;
  }

  $supabase.auth.updateUser({
    data: {
      parallelProfile: null,
    },
  });

  $supabase.auth
    .getUser()
    .then(async (userData) => {
      if (userData.data.user) {
        console.log("User is logged in:", userData.data.user);
        $user = userData.data.user;
        if (
          !!data.parallelAuth?.access_token &&
          !!data.parallelAuth?.refresh_token
        ) {
          await $supabase.auth.updateUser({
            data: {
              parallel: data.parallelAuth,
            },
          });
        }
      }
    })
    .catch((error) => {
      $user = undefined;
      console.error("Error fetching user:", error);
    });
</script>

<svelte:window onmousemove={handleMouseMove} />

<div class="nav">
  <h2 id="title">PRIMEA</h2>
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
    {#if $user}
      <a
        class="nav-link"
        data-label="AUTH_PANEL[02]"
        href="/"
        onclick={(e) => {
          e.preventDefault();
          $supabase.auth.signOut();
          user.set(undefined);
        }}
      >
        sign out
      </a>
    {:else}
      <a
        class="nav-link"
        data-label="AUTH_PANEL[01]"
        href="./#"
        onclick={(e) => {
          e.preventDefault();
          showModal = true;
        }}
      >
        sign in
      </a>
    {/if}
  </nav>
</div>

<div class="body">
  <div
    class="background"
    style="mask-image: radial-gradient(
        circle 45svw at 32% 87%,
        #ffffff88 20%,
        transparent 60%
      ),
      radial-gradient(circle 45svw at 68% 40%, #ffffff88 20%, transparent 60%),
      radial-gradient(
        circle 15svw at {mouseMove.x}px {mouseMove.y}px,
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
        circle 15svw at {mouseMove.x}px {mouseMove.y}px,
        #ffffff88 20%,
        transparent 60%
      );"
  ></div>
  <div class="content">
    {@render children()}
  </div>
</div>

<h4>Footer</h4>

<SignIn bind:showModal />

<style>
  :global(:root) {
    --color-primary: #def141;
    --color-secondary: #131313;
    --text-color: #dcdcdc;
    --text-dim: #ffffff40;
    --surface-color: #131313;
  }

  :global(dialog) {
    font-family: "Chakra Petch", sans-serif;
    color: var(--text-color);
    background-color: #1c1f15;
  }

  :global(body) {
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
    min-height: calc(100svh - 21px - 1.33em * 2 - 57.3px - 8px);
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
    background-size: 1.2em 1.2em;
  }

  .content {
    position: relative;
  }

  #title {
    margin-top: 0.4rem;
  }

  .nav {
    position: sticky;
    top: 0;
    z-index: 100; /* Ensure it's above other elements */
    display: flex;
    justify-content: space-between;
    text-transform: uppercase;
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
</style>
