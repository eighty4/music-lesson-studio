import {type Cookies, redirect} from '@sveltejs/kit'
import {AUTH_TOKEN_NAME, verifyAuthToken} from '$lib'

export async function redirectVerifiedToken(cookies: Cookies, redirectUrl: string): Promise<void> {
    const result = await verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))
    if (result) {
        redirect(301, redirectUrl)
    }
}
