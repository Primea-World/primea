<script lang="ts">
  import type {Provider} from "@supabase/supabase-js";
  import Modal from "./Modal.svelte";
  import {supabase} from "./supabase";

  interface Props {
    showModal: boolean;
  }

  let {showModal = $bindable(false)}: Props = $props();

  let passwordVisible = $state(false);
  let passwordType = $state("password");

  // Toggle password visibility
  function togglePassword() {
    passwordVisible = !passwordVisible;
    passwordType = passwordVisible ? "text" : "password";
  }

  function signInWithSocial(platform: Provider) {
    $supabase.auth.signInWithOAuth({
      provider: platform,
      options: {
        redirectTo: "/",
      },
    });
  }
</script>

<Modal bind:showModal>
  {#snippet header()}
    <div class="header">
      <h1>Sign in</h1>
    </div>
  {/snippet}
  <div class="content">
    <form>
      <!-- Email Input Field -->
      <div class="form-group">
        <label class="label" for="email">Email</label>
        <input
          class="input"
          id="email"
          type="text"
          placeholder="example@email.me"
          autocomplete="email"
        />
      </div>

      <!-- Password Input Field -->
      <div class="form-group">
        <label class="label" for="password">Password</label>
        <div class="input-wrapper">
          <input
            class="input"
            id="password"
            type={passwordType}
            autocomplete="current-password"
          />
          <button class="eye-icon" onclick={togglePassword}>
            {#if passwordVisible}
              <span class="material-symbols-rounded">visibility</span>
            {:else}
              <span class="material-symbols-rounded">visibility_off</span>
            {/if}
          </button>
        </div>
      </div>
    </form>
    <!-- Sign Up and Sign In Buttons -->
    <div class="button-group">
      <button class="button outlined">
        <span class="material-symbols-rounded">mail</span>
        <span id="outlined">Sign Up</span>
      </button>
      <button class="button">
        <span class="material-symbols-rounded">mail</span>
        <span>Sign In</span>
      </button>
    </div>
  </div>
  <span style="display: flex;">
    <hr style="width: 90%; color: #1c1c1c88" />
  </span>
  {#snippet footer()}
    <div class="footer">
      <!-- Social Login Buttons -->
      <div class="social-buttons">
        <button
          class="button outlined social"
          onclick={() => signInWithSocial("twitch")}
        >
          <!-- <span class="icon" data-img="/brands/twitch.png"></span> -->
          <img src="/brands/twitch.png" style="width: 24px;" alt="Twitch" />
          <span>Sign in with Twitch</span>
        </button>
        <button
          class="button outlined social"
          onclick={() => signInWithSocial("discord")}
        >
          <!-- <span class="icon" data-img="/brands/Discord.png"></span> -->
          <img src="/brands/Discord.png" style="width: 24px;" alt="Discord" />
          <span>Sign in with Discord</span>
        </button>
      </div>
    </div>
  {/snippet}
</Modal>

<style>
  .header {
    display: flex;
    justify-content: center;
    align-items: center;
    text-transform: uppercase;
  }

  .content {
    padding: 0 1rem;
  }

  .footer {
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 1em;
  }

  /* Form Group (Label + Input) */
  .form-group {
    margin-bottom: 15px;
  }

  /* Labels */
  .label {
    display: block;
    margin-bottom: 5px;
    text-align: left;
  }

  /* Input Fields */
  .input {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: transparent;
    color: #fff;
    box-sizing: border-box;
  }

  .input::placeholder {
    color: #ccc;
  }

  /* Password Input Wrapper */
  .input-wrapper {
    position: relative;
  }

  /* Eye Icon for Password Toggle */
  .eye-icon {
    position: absolute;
    right: 10px;
    bottom: 0;
    top: 0;
    cursor: pointer;
    color: var(--text-dim);
    background-color: transparent;
    border: none;
    display: flex;
    align-items: center;
  }

  /* Button Group */
  .button-group {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 20px;
  }

  /* Buttons */
  .button {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #d4e157; /* Light yellowish-green */
    color: #000; /* Dark text for contrast */
    padding: 5px 20px;
    border-radius: 9999px; /* Oval shape */
    border: none;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2); /* Subtle shadow */
    text-transform: uppercase;
  }

  .button span:nth-child(1) {
    margin-right: 0.25em;
  }

  .button.outlined {
    background-color: transparent;
    border: 1px solid #d4e157; /* Same color as the button */
    color: #d4e157; /* Same color as the button */
  }

  .button #outlined {
    color: var(--text-color);
  }

  /* Social Buttons */
  .social-buttons {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }

  .button.social {
    padding: 0.5em 1.5em;
  }
  .button.social > img {
    margin-right: 0.5em;
  }
</style>
