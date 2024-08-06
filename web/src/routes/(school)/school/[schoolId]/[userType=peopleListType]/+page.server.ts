import type {PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import type {SchoolFaculty, User} from '$lib/data/UserTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/dashboard'

interface PeopleLookup {
    faculty?: Array<SchoolFaculty>
    students?: Array<User>
}

export const load: PageServerLoad = async ({cookies, params}): Promise<PeopleLookup> => {
    await redirectRejectedToken(cookies, REDIRECT_401)
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
