import {type Actions, redirect} from '@sveltejs/kit'
import {AUTH_TOKEN_NAME} from '$lib/token/authToken'

export const actions: Actions = {
    default: async ({cookies}) => {
        cookies.set(AUTH_TOKEN_NAME, '', {path: '/', expires: new Date(0)})
        redirect(302, '/')
    },
}
