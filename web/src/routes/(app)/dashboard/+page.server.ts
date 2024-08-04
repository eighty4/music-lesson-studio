import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {userQueries} from '$lib/data/instances'
import type {UserSchools} from '$lib/data/UserTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/dashboard'

export const load: PageServerLoad = async ({cookies, url}): Promise<UserSchools> => {
    const userSchools = await userQueries.lookupUserSchools(await redirectRejectedToken(cookies, REDIRECT_401))
    if (userSchools.student.length === 0 && userSchools.teacher.length === 0) {
        redirect(302, '/new-user')
    }
    return userSchools
}
