import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME, verifyAuthToken} from '$lib'

export const load: PageServerLoad = async ({cookies}) => {
    if (!verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))) {
        redirect(301, '/login?to=/lessons')
    }
    return {
        lessonPlans: [],
    }
}
