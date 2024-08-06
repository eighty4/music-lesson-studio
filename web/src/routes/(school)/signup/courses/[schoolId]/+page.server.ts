import {redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies, params}) => {
    const userId = await redirectRejectedToken(cookies, REDIRECT_401)
    if (!await schoolQueries.isAdminForSchool(userId, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
}

export const actions: Actions = {
    default: async ({params}) => {
        redirect(302, '/school/' + params.schoolId)
    },
}
