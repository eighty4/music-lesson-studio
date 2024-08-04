import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {loginQueries, userQueries} from '$lib/data/instances'
import {AUTH_TOKEN_NAME} from '$lib/token/authToken'
import {createAuthToken} from '$lib/token/createAuthToken'

export const load: PageServerLoad = async ({cookies, params}) => {
    if (params.loginToken.length !== 6) {
        console.warn('/login/verify/' + params.loginToken + ' bad token')
        redirect(302, 'https://www.dummies.com/book/technology/cybersecurity/hacking-for-dummies-281732/')
    }
    const {verified, path} = await loginQueries.verifyLoginToken(params.email, params.loginToken)
    if (verified) {
        const user = await userQueries.lookupOrCreateNewUser(params.email)
        const token = await createAuthToken(user)
        cookies.set(AUTH_TOKEN_NAME, token, {path: '/'})
        redirect(302, path ?? '/dashboard')
    } else {
        console.warn(`/login/verify/${params.loginToken} rejected token`)
        redirect(302, '/login?error')
    }
}
