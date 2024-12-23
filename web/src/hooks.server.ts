import type {Handle, HandleServerError, RequestEvent} from '@sveltejs/kit'
import {BadData} from '$lib/data/ErrorTypes'
import type {User} from '$lib/data/UserTypes'
import {AUTH_TOKEN_NAME} from '$lib/token/authToken'
import {verifyAuthToken} from '$lib/token/verifyAuthToken'

export const handle: Handle = async function ({event, resolve}) {
    const userId = await getAuthedUserId(event)
    event.locals.user = {authenticated: !!userId, userId}
    const response = await resolve(event)
    console.debug(event.request.method, event.url.pathname, response.status)
    return response
}

export const handleError: HandleServerError = ({error, message, status, event}) => {
    console.error(
        error instanceof BadData ? 'bad data' : 'unknown server error',
        status,
        event.url.pathname,
        'userId=' + event.locals.user.userId,
        message,
        error,
    )
    return {
        message: 'unexpected error',
    }
}

async function getAuthedUserId(event: RequestEvent): Promise<User['id'] | undefined> {
    try {
        return verifyAuthToken(getAuthToken(event))
    } catch (ignore: any) {
    }
}

function getAuthToken(event: RequestEvent): string | undefined | null {
    if (event.url.pathname.startsWith('/api')) {
        const authorizationHeader = event.request.headers.get('authorization')
        if (authorizationHeader && authorizationHeader.startsWith('Bearer ')) {
            return authorizationHeader.substring(7)
        }
    }
    return event.cookies.get(AUTH_TOKEN_NAME)
}
