import type {Handle} from '@sveltejs/kit'

export const handle: Handle = async function ({event, resolve}) {
    const response = await resolve(event)
    console.debug(event.request.method, event.url.pathname, response.status)
    return response
}
