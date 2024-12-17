import {sveltekit} from '@sveltejs/kit/vite'
import {defineConfig} from 'vite'

export default defineConfig({
    plugins: [sveltekit()],
    server: {
        // explicit 127.0.0.1 is required for proxying to host network from Android emulator
        host: '127.0.0.1',
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
})
