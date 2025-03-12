<script module lang="ts">
  import type {ParallelProfile} from "$lib/parallelProfile";
  import type {User} from "@supabase/supabase-js";

  interface ProfilePanelParameters {
    user: User | null;
    account: Promise<ParallelProfile | null> | null;
  }

  export {cardPanel, type ProfilePanelParameters};
</script>

{#snippet cardPanel(parameters: ProfilePanelParameters)}
  {@const {user, account} = parameters}
  {#await account}
    <div
      class="panel title"
      style="background-image: url(/unknown_origins.avif);"
    >
      <h2>LOADING</h2>
    </div>
  {:then parallelProfile}
    {#if !!parallelProfile}
      {#if parallelProfile?.avatar.image_url}
        <div
          class="panel"
          style="background-image: url({parallelProfile?.avatar.image_url});"
        ></div>
      {:else if parallelProfile?.django_profile.picture_url}
        <div
          class="panel"
          style="background-image: url({parallelProfile?.django_profile
            .picture_url});"
        ></div>
      {/if}
    {:else if user?.user_metadata.avatar_url}
      <div
        class="panel"
        style="background-image: url({user?.user_metadata.avatar_url});"
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

<style>
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
</style>
