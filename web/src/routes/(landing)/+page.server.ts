import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME, verifyAuthToken} from '$lib'

export const load: PageServerLoad = ({cookies}) => {
    if (verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))) {
        redirect(301, '/classes')
    }
}
