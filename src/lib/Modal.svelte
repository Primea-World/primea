<script lang="ts">
  import {page} from "$app/state";
  import type {Snippet} from "svelte";

  interface Props {
    // showModal: boolean;
    header: Snippet;
    children: Snippet;
    footer: Snippet;
  }
  let {header, children, footer}: Props = $props();

  let dialog: HTMLDialogElement | undefined = $state();

  $effect(() => {
    if (page.state.showModal) {
      dialog?.showModal();
    } else {
      dialog?.close();
    }
  });
</script>

<!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_noninteractive_element_interactions -->
<dialog
  bind:this={dialog}
  onclose={() => history.back()}
  onclick={(e) => {
    if (e.target === dialog) dialog.close();
  }}
>
  <div>
    {@render header()}
    {@render children()}
    {@render footer()}
  </div>
</dialog>

<style>
  dialog {
    max-width: 48em;
    border-radius: 0.2em;
    border: none;
    padding: 0;
    /* For Firefox */
    scrollbar-width: none;
    /* For IE and Edge */
    -ms-overflow-style: none;
  }
  dialog::-webkit-scrollbar {
    display: none;
  }
  dialog::backdrop {
    background: rgba(0, 0, 0, 0.75);
  }
  dialog[open] {
    animation: zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  @keyframes zoom {
    from {
      transform: scale(0.95);
    }
    to {
      transform: scale(1);
    }
  }
  dialog[open]::backdrop {
    animation: fade 0.2s ease-out;
  }
  @keyframes fade {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
</style>
