import type {PageServerLoad} from './$types'
import {redirect} from '@sveltejs/kit'

export const load: PageServerLoad = async ({cookies, params, request}) => {
    if (params.loginToken.length === 6) {
        // todo save login to database
        // todo create auth token
        cookies.set('mls-token', 'foobar', {path: '/'})
        redirect(301, '/dashboard')
    } else {
        console.warn('/login/verify/' + params.loginToken + ' login failed')
        redirect(301, '/login?result=failed')
    }
}
