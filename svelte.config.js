import adapter from "@sveltejs/adapter-static";
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: [
		vitePreprocess({ script: true }),
		{
			markup({ content }) {
				return {
					code: content.replace(/<script(\s+[^>]*)?\s+lang=(['"])ts\2/g, '<script$1')
				};
			}
		}
	],

	kit: {
		// adapter-auto only supports some environments, see https://svelte.dev/docs/kit/adapter-auto for a list.
		// If your environment is not supported, or you settled on a specific environment, switch out the adapter.
		// See https://svelte.dev/docs/kit/adapters for more information about adapters.
		adapter: adapter({
         pages: "build",
         assets: "build",
         fallback: null,
         precompress: false,
         trailingSlash: 'always',
      }),

      // Handouts live under static/ so the same file is both inlined into a
      // deck (via ?raw) and downloadable at /handout/<lecture>/<name>.lean.
      alias: {
         $handouts: 'static/handout',
      },
	}
};

export default config;
