import {type Cookies, redirect} from '@sveltejs/kit'
import {verifyAuthToken} from '$lib'

export async function redirectVerifiedToken(cookies: Cookies, redirectUrl: string): Promise<void> {
    const result = await verifyAuthToken(cookies)
    if (result) {
        redirect(301, redirectUrl)
    }
}
