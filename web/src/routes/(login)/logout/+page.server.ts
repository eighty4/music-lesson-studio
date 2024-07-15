import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME} from '$lib/token/authToken'

export const load: PageServerLoad = ({cookies}) => {
    cookies.set(AUTH_TOKEN_NAME, '', {path: '/', expires: new Date(0)})
    redirect(302, '/')
}
