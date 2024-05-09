import type {PageServerLoad} from './$types'
import {redirectRejectedToken, userQueries} from '$lib'
import type {UserSchools} from '$lib/data/UserTypes'

const REDIRECT_401 = '/login?to=/dashboard'

export const load: PageServerLoad = async ({cookies}): Promise<UserSchools> => {
    return await userQueries.lookupUserSchools(await redirectRejectedToken(cookies, REDIRECT_401))
}
