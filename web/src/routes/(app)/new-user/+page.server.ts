import type {PageServerLoad} from './$types'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/new-user'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectRejectedToken(cookies, REDIRECT_401)
}
