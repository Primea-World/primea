<script lang="ts">
  import {onMount} from "svelte";

  interface Props {
    text:
      | Promise<string | undefined>
      | PromiseLike<string | undefined>
      | undefined;
    placeholder?: string;
    defaultText?: string;
    cursorSymbol?: string;
    includeCursor?: boolean;
    animationDelay?: number; // in seconds
    typingSpeed?: number; // in seconds
  }

  const {
    text,
    placeholder = "loading",
    defaultText = "unknown",
    cursorSymbol = "_",
    includeCursor = true,
    animationDelay = 0,
    typingSpeed = 0.1,
  }: Props = $props();

  let currentText = $state("_");
  let cursor = $state(includeCursor);

  async function type(value: String) {
    await new Promise((resolve) => setTimeout(resolve, animationDelay * 1000));
    // erase the current text
    // leave the first character, otherwise the text block will collapse
    for (let i = currentText.length; i > 0; i--) {
      currentText = currentText.slice(0, i);
      await new Promise((resolve) => setTimeout(resolve, typingSpeed * 1000));
    }
    // type the new text
    for (let i = 0; i < value.length; i++) {
      // add the current character to the text block
      if (i == 0) {
        // since the first character was left, replace it
        currentText = value[i];
      } else {
        currentText += value[i];
      }
      await new Promise((resolve) => setTimeout(resolve, typingSpeed * 1000));
    }
  }

  onMount(async () => {
    const textResolved = await Promise.race([
      text,
      new Promise((resolve) => setTimeout(resolve, typingSpeed * 1000)),
    ]);
    if (!textResolved) {
      await type(placeholder);
    }
    const value = await text;
    if (value && value.length > 0) {
      await type(value);
    } else {
      await type(defaultText);
    }
    cursor = false;
  });
</script>

{currentText}{#if cursor}<span class="cursor">{cursorSymbol}</span>{/if}

<style>
  .cursor {
    animation: blink 0.7s infinite;
  }

  @keyframes blink {
    0% {
      opacity: 0;
    }
    49% {
      opacity: 0;
    }
    50% {
      opacity: 1;
    }
    100% {
      opacity: 1;
    }
  }
</style>
