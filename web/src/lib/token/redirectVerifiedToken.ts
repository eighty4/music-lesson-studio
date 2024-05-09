import {type Cookies, redirect} from '@sveltejs/kit'
import {verifyAuthToken} from '$lib'

export async function redirectVerifiedToken(cookies: Cookies, redirectUrl: string): Promise<void> {
    const userId = await verifyAuthToken(cookies)
    if (userId) {
        redirect(302, redirectUrl)
    }
}
