import {sveltekit} from '@sveltejs/kit/vite'
import {defineConfig} from 'vite'

export default defineConfig({
    server: {
        proxy: {
            '/dev/ui': {
                rewrite: (path) => path.replace(/^\/dev\/ui\//, '/'),
                target: 'http://localhost:5710',
                ws: true,
            },
            '/$dwdsSseHandler': {
                target: 'http://localhost:5710',
                ws: true,
            },
        },
    },
    plugins: [sveltekit()],
})
