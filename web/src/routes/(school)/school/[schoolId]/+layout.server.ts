import type {LayoutServerLoad} from './$types'
import {schoolQueries} from '$lib/data/queries'
import {loginRedirect} from '$lib/http/requestUtils'
import {redirect} from '@sveltejs/kit'

export const load: LayoutServerLoad = async ({locals: {user}, params, url}) => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
    const schoolName = await schoolQueries.lookupSchoolName(params.schoolId)
    return {
        schoolName,
    }
}
