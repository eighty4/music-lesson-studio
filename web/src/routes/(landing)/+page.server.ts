import type {PageServerLoad} from './$types'
import {redirectVerifiedToken} from '$lib/token/redirectVerifiedToken'

const REDIRECT_401 = '/dashboard'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectVerifiedToken(cookies, REDIRECT_401)
}
