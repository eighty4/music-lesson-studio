import {verifyAuthToken} from '$lib'
import type {Cookies} from '@sveltejs/kit'

export async function getAuthenticatedUserId(cookies: Cookies): Promise<string | undefined> {
    try {
        const user = await verifyAuthToken(cookies)
        return user?.id
    } catch (ignore: any) {
    }
}
