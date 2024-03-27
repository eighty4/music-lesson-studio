import {redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {redirectRejectedToken, schoolQueries} from '$lib'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies, params}) => {
    const {id: userId} = await redirectRejectedToken(cookies, REDIRECT_401)
    if (!await schoolQueries.isAdminForSchool(userId, params.schoolId)) {
        // todo +error.svelte ?
        redirect(301, '/')
    }
}

export const actions: Actions = {
    default: async () => {
        redirect(302, '/dashboard')
    },
}
