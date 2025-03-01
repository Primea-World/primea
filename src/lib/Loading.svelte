<script lang="ts">
  interface Props {
    dotCount?: number;
  }

  let {dotCount = 5}: Props = $props();

  let dots = new Array(dotCount).fill(0);
</script>

<div class="roller" data-total={dotCount}>
  {#each dots as { }}
    <div data-total={dotCount}></div>
  {/each}
</div>

<style>
  .roller {
    --total: property(data-total);
    --offset: calc(var(total) / 2);
    color: #1153ef;
    /* TODO: offset this * -var(--total) */
    rotate: calc(222deg - (11deg * var(--index) * var(--offset)));
  }
  .roller,
  .roller div,
  .roller div:after {
    box-sizing: border-box;
  }
  .roller {
    width: 100%;
    height: 100%;
    position: relative;
  }
  .roller div {
    animation: roller 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
    transform-origin: center;
    position: absolute;
    width: 100%;
    height: 100%;
    rotate: calc(10deg * var(--index));
  }
  .roller div:after {
    content: " ";
    display: block;
    position: absolute;
    width: 7.2px;
    height: 7.2px;
    border-radius: 50%;
    background: currentColor;
    margin: -3.6px 0 0 -3.6px;
  }
  .roller div:nth-child(n) {
    animation-delay: calc(var(--index) * -0.036s);
  }
  .roller div:nth-child(n):after {
    --offset: 0.15; /* Adjust this value to control the offset */

    /* Position using trigonometric functions */
    top: 25%;
    left: 25%;
  }
  @keyframes roller {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(360deg);
    }
  }
</style>
