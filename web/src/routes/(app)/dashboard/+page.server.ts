import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {userQueries} from '$lib/data/instances'
import type {UserSchools} from '$lib/data/UserTypes'
import {loginRedirect} from '$lib/http/requestUtils'

export const load: PageServerLoad = async ({locals: {user}, url}): Promise<UserSchools> => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    const userSchools = await userQueries.lookupUserSchools(user.userId!)
    if (userSchools.student.length === 0 && userSchools.teacher.length === 0) {
        redirect(302, '/new-user')
    }
    return userSchools
}
