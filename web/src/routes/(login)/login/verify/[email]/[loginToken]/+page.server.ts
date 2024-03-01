import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME, createAuthToken, loginQueries} from '$lib'

export const load: PageServerLoad = async ({cookies, params}) => {
    if (params.loginToken.length !== 6) {
        console.warn('/login/verify/' + params.loginToken + ' bad token')
        redirect(301, '/login')
    }
    const {verified, path} = await loginQueries.verifyLoginToken(params.email, params.loginToken)
    if (verified) {
        cookies.set(AUTH_TOKEN_NAME, createAuthToken(), {path: '/'})
        redirect(301, path ?? '/dashboard')
    } else {
        console.warn(`/login/verify/${params.loginToken} rejected token`)
        redirect(301, '/login')
    }
}
