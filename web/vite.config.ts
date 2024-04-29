import {sveltekit} from '@sveltejs/kit/vite'
import {defineConfig} from 'vite'

export default defineConfig({
    server: {
        proxy: {
            '/dev/ui': {
                target: 'http://localhost:5710',
                rewrite: (path) => path.replace(/^\/dev\/ui/, ''),
            },
        },
    },
    plugins: [sveltekit()],
})
