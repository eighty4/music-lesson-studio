import {type Cookies, redirect} from '@sveltejs/kit'
import {AUTH_TOKEN_NAME, verifyAuthToken} from '$lib'
import type {User} from '$lib/data/types'

export async function redirectRejectedToken(cookies: Cookies, redirectUrl: string): Promise<Pick<User, 'id'>> {
    try {
        const result = await verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))
        if (result) {
            return result
        }
    } catch (e: any) {
        console.warn('redirectRejectedToken', e)
    }
    redirect(301, redirectUrl)
}
