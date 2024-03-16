import adapter from '@sveltejs/adapter-auto'
import {vitePreprocess} from '@sveltejs/vite-plugin-svelte'

/** @type {import('@sveltejs/kit').Config} */
const config = {
    compilerOptions: {
        runes: true,
    },
    kit: {
        // https://kit.svelte.dev/docs/adapters
        adapter: adapter(),
    },
    // https://kit.svelte.dev/docs/integrations#preprocessors
    preprocess: vitePreprocess(),
}

export default config
