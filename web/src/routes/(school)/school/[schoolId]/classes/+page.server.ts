import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {loginRedirect} from '$lib/http/requestUtils'
import {schoolQueries} from '$lib/data/instances'

export const load: PageServerLoad = async ({locals: {user}, params, url}) => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
    return {
        classes: [],
    }
}
