import type {PageServerLoad} from './$types'
import {lessonQueries} from '$lib/data/queries'
import type {LessonUnit} from '$lib/data/LessonPlanTypes'
import {loginRedirect} from '$lib/http/requestUtils'

export const load: PageServerLoad = async ({locals: {user}, params, url}): Promise<{
    lessonUnits: Array<LessonUnit>
}> => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    return {lessonUnits: await lessonQueries.findUserLessonUnits(user.userId!, params.lessonPlanId)}
}
