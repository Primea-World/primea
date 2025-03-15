<script lang="ts">
  import {onMount} from "svelte";
  import Icon from "./parallels/Icon.svelte";
  import {Universal} from "./parallels/parallel";

  interface Props {
    src: string;
    alt?: string;
    width: number;
    height: number;
    loading?: "lazy" | "eager";
  }

  const {src, width, height, alt = "image", loading = "lazy"}: Props = $props();

  let loaded = $state(false);
</script>

<svelte:head>
  <link
    rel="preload"
    href={src}
    sizes="{width}x{height}"
    as="image"
    crossorigin="anonymous"
    referrerpolicy="no-referrer"
  />
</svelte:head>

<div class="container" style="width: {width}px; height: {height}px">
  <img
    class="preview"
    class:loaded
    onload={() => (loaded = true)}
    {src}
    {alt}
    {loading}
    crossorigin="anonymous"
    referrerpolicy="no-referrer"
  />
  <span class="placeholder" class:loaded>
    <Icon parallel={Universal} />
  </span>
</div>

<style>
  .container {
    position: relative;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .preview {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    opacity: 0;
    transition: opacity 0.3s ease-in-out;

    &.loaded {
      opacity: 1;
    }
  }

  .placeholder {
    opacity: 1;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: opacity 0.3s ease-in-out;

    &.loaded {
      opacity: 0;
    }
  }
</style>
