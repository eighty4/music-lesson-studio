import type {Cookies} from '@sveltejs/kit'
import {AUTH_TOKEN_NAME} from '$lib/token/authToken'
import {verifyAuthToken} from '$lib/token/verifyAuthToken'

export async function getApiAuthenticatedUserId(cookies: Cookies, request: Request): Promise<string | undefined> {
    const authTokenCookie = cookies.get(AUTH_TOKEN_NAME)
    if (!!authTokenCookie) {
        try {
            return await verifyAuthToken(authTokenCookie)
        } catch (ignore: any) {
        }
    } else {
        const authHeader = request.headers.get('authorization')
        if (authHeader && authHeader.startsWith('Bearer ') && authHeader.length > 7) {
            try {
                return await verifyAuthToken(authHeader.substring(7))
            } catch (ignore: any) {
            }
        }
    }
}
