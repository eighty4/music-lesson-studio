import type {Handle, RequestEvent} from '@sveltejs/kit'
import type {User} from '$lib/data/UserTypes'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'
import {getAuthenticatedUserId} from '$lib/token/getAuthenticatedUserId'

export const handle: Handle = async function ({event, resolve}) {
    const userId = await getAuthedUserId(event)
    event.locals.user = {authenticated: !!userId, userId}
    const response = await resolve(event)
    console.debug(event.request.method, event.url.pathname, response.status)
    return response
}

// todo api requests should check bearer token before cookie
async function getAuthedUserId(event: RequestEvent): Promise<User['id'] | undefined> {
    if (event.url.pathname.startsWith('/api')) {
        return getApiAuthenticatedUserId(event.cookies, event.request)
    } else {
        return getAuthenticatedUserId(event.cookies)
    }
}
