import {redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {loginRedirect} from '$lib/http/requestUtils'

export const load: PageServerLoad = async ({locals: {user}, params, url}) => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
}

export const actions: Actions = {
    default: async ({locals: {user}, params, url}) => {
        if (!user.authenticated) {
            loginRedirect(url)
        }
        if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
            // todo +error.svelte ?
            redirect(302, '/')
        }
        // todo save data to db
        redirect(302, '/school/' + params.schoolId)
    },
}
