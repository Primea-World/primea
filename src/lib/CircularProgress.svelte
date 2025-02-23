<script lang="ts">
  import {quadInOut} from "svelte/easing";
  import {Tween} from "svelte/motion";

  import {
    color,
    scaleLinear,
    interpolateRgb,
    type HSLColor,
    type RGBColor,
  } from "d3";

  const red = color("#f44336")!;
  const amber = color("#ffc317")!;
  const green = color("#4caf50")!;

  let {
    value = $bindable(0),
    radius = 50,
    pathWidth = 10,
    duration: animationDuration = 1000,
    trackColor = "var(--text-dim)",
    valueColorRange = [green, amber, red],
  } = $props();

  let paddedRadius = $derived(radius + 10);
  let paddedDiameter = $derived(paddedRadius * 2);
  let circumference = $derived(radius * Math.PI * 2);
  let offset = $derived(
    new Tween(circumference, {
      duration: animationDuration,
      easing: quadInOut,
    })
  );

  let colorScale = $derived(
    scaleLinear<HSLColor | RGBColor>()
      .domain([0, circumference * 0.8, circumference])
      .range(valueColorRange)
      .interpolate(interpolateRgb)
  );

  let valueColor = $derived(colorScale(offset.current));

  $effect(() => {
    offset.set(((100 - value) / 100) * circumference);
  });
</script>

<svg
  width={paddedDiameter}
  height={paddedDiameter}
  viewBox="0 0 {paddedDiameter} {paddedDiameter}"
>
  <circle
    cx={paddedRadius}
    cy={paddedRadius}
    r={radius}
    stroke-width={pathWidth}
    stroke={trackColor}
    fill="none"
  />
  <circle
    cx={paddedRadius}
    cy={paddedRadius}
    r={radius}
    stroke-width={pathWidth}
    stroke={valueColor}
    fill="none"
    stroke-linecap="round"
    transform="rotate(-90, {paddedRadius}, {paddedRadius})"
    stroke-dasharray="{circumference} {circumference}"
    stroke-dashoffset={offset.current}
  />
  <text
    x={paddedRadius}
    y={paddedRadius}
    text-anchor="middle"
    dy="8"
    fill="var(--text-color)"
    >{(((circumference - offset.current) / circumference) * 100).toFixed(
      0
    )}%</text
  >
</svg>

<style>
  text {
    font-size: larger;
  }
</style>
