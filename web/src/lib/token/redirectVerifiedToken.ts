import {type Cookies, redirect} from '@sveltejs/kit'
import {verifyAuthTokenFromCookie} from '$lib/token/verifyAuthToken'

export async function redirectVerifiedToken(cookies: Cookies, redirectUrl: string): Promise<void> {
    const userId = await verifyAuthTokenFromCookie(cookies)
    if (userId) {
        redirect(302, redirectUrl)
    }
}
