import {redirect} from '@sveltejs/kit'
import type {PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/queries'
import type {SchoolFaculty, User} from '$lib/data/UserTypes'
import {loginRedirect} from '$lib/http/requestUtils'

interface PeopleLookup {
    faculty?: Array<SchoolFaculty>
    students?: Array<User>
}

export const load: PageServerLoad = async ({locals: {user}, params, url}): Promise<PeopleLookup> => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
    let response: PeopleLookup = {}
    switch (params.userType) {
        case 'teachers':
            response.faculty = await schoolQueries.lookupFaculty(params.schoolId)
            break
        case 'students':
            response.students = await schoolQueries.lookupStudents(params.schoolId)
            break
    }
    return response
}
