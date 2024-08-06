import type {PageServerLoad} from './$types'
import {lessonQueries} from '$lib/data/instances'
import type {LessonPlan} from '$lib/data/LessonPlanTypes'
import {loginRedirect} from '$lib/http/requestUtils'

export const load: PageServerLoad = async ({locals: {user}, url}): Promise<{ lessonPlans: Array<LessonPlan> }> => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    return {lessonPlans: await lessonQueries.findUserLessonPlans(user.userId!)}
}
