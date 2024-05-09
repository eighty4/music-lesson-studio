import {type Cookies, redirect} from '@sveltejs/kit'
import {verifyAuthToken} from '$lib'
import type {User} from '$lib/data/UserTypes'

export async function redirectRejectedToken(cookies: Cookies, redirectUrl: string): Promise<User['id']> {
    try {
        const result = await verifyAuthToken(cookies)
        if (result) {
            return result
        }
    } catch (e: any) {
        console.warn('redirectRejectedToken', e)
    }
    redirect(302, redirectUrl)
}
