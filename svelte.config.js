import adapter from '@sveltejs/adapter-cloudflare';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess({
		// See below for an explanation of these options
		routes: {
			include: ['/*'],
			exclude: ['<all>']
		},
		platformProxy: {
			configPath: 'wrangler.toml',
			environment: undefined,
			experimentalJsonConfig: false,
			persist: false
		}
	}),

	kit: {
		// adapter-auto only supports some environments, see https://svelte.dev/docs/kit/adapter-auto for a list.
		// If your environment is not supported, or you settled on a specific environment, switch out the adapter.
		// See https://svelte.dev/docs/kit/adapters for more information about adapters.
		adapter: adapter(),
		version: {
			name: process.env.PUBLIC_CF_PAGES_COMMIT_SHA,
		},
	},
};

export default config;
