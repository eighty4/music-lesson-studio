import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME, createAuthToken, loginQueries, userQueries} from '$lib'

export const load: PageServerLoad = async ({cookies, params}) => {
    if (params.loginToken.length !== 6) {
        console.warn('/login/verify/' + params.loginToken + ' bad token')
        redirect(302, '/login')
    }
    const {verified, path} = await loginQueries.verifyLoginToken(params.email, params.loginToken)
    if (verified) {
        const user = await userQueries.lookupOrCreateNewUser(params.email)
        const token = await createAuthToken(user)
        cookies.set(AUTH_TOKEN_NAME, token, {path: '/'})
        redirect(302, path ?? '/dashboard')
    } else {
        console.warn(`/login/verify/${params.loginToken} rejected token`)
        redirect(302, '/login')
    }
}
