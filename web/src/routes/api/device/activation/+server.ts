import type {RequestHandler} from '@sveltejs/kit'
import {activationPool} from '$lib/devices/activation'

export const GET: RequestHandler = async () => {
    return new Response(await activationPool.addConnection(), {
        headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
        },
    })
}
