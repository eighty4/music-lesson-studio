import type {Cookies} from '@sveltejs/kit'
import {verifyAuthTokenFromCookie} from '$lib/token/verifyAuthToken'

export async function getAuthenticatedUserId(cookies: Cookies): Promise<string | undefined> {
    try {
        return await verifyAuthTokenFromCookie(cookies)
    } catch (ignore: any) {
    }
}
