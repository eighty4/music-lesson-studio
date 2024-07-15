import type {PageServerLoad} from './$types'
import {userQueries} from '$lib/data/instances'
import type {UserSchools} from '$lib/data/UserTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/dashboard'

export const load: PageServerLoad = async ({cookies}): Promise<UserSchools> => {
    return await userQueries.lookupUserSchools(await redirectRejectedToken(cookies, REDIRECT_401))
}
