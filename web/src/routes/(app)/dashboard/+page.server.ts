import type {PageServerLoad} from './$types'
import {redirectRejectedToken} from '$lib'

const REDIRECT_401 = '/login?to=/dashboard'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectRejectedToken(cookies, REDIRECT_401)
}
