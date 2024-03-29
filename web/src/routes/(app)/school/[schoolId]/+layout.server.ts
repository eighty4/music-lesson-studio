import type {LayoutServerLoad} from './$types'
import {schoolQueries} from '$lib'

export const load: LayoutServerLoad = async ({params}) => {
    const schoolName = await schoolQueries.lookupSchoolName(params.schoolId)
    return {
        schoolName,
    }
}
