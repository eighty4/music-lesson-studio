import {type Cookies, redirect} from '@sveltejs/kit'
import type {User} from '$lib/data/UserTypes'
import {verifyAuthTokenFromCookie} from '$lib/token/verifyAuthToken'

export async function redirectRejectedToken(cookies: Cookies, redirectUrl: string): Promise<User['id']> {
    try {
        const result = await verifyAuthTokenFromCookie(cookies)
        if (result) {
            return result
        }
    } catch (e: any) {
        console.warn('redirectRejectedToken', e)
    }
    redirect(302, redirectUrl)
}
