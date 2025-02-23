<script>
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

  let {children} = $props();

  let links = [
    {href: "/", text: "uplink"},
    {href: "/matches", text: "matches"},
    {href: "/console", text: "console"},
    {href: "/profile", text: "profile"},
  ];
</script>

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
    <a class="nav-link" data-label="AUTH_PANEL[01]" href="/sign-out">sign in</a>
    <a class="nav-link" data-label="AUTH_PANEL[02]" href="/sign-out">sign out</a
    >
  </nav>
</div>

{@render children()}

<h4>Footer</h4>

<style>
  :global(:root) {
    --color-primary: #def141;
    --color-secondary: #131313;
    --text-color: #dcdcdc;
    --text-dim: #ffffff40;
    --surface-color: #131313;
  }

  :global(body) {
    font-family: "Chakra Petch", sans-serif;
    color: var(--text-color);
    background-color: var(--surface-color);
  }

  :global(.text-shroud-purple) {
    color: #6438c6;
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
    background-color: var(--surface-color);
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
