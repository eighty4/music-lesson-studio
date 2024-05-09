import {verifyAuthToken} from '$lib'
import type {Cookies} from '@sveltejs/kit'

export async function getAuthenticatedUserId(cookies: Cookies): Promise<string | undefined> {
    try {
        return await verifyAuthToken(cookies)
    } catch (ignore: any) {
    }
}
