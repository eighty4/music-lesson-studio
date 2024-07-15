import type {PageServerLoad} from './$types'
import {lessonQueries} from '$lib/data/instances'
import type {LessonPlan} from '$lib/data/LessonPlanTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/lesson-plans'

export const load: PageServerLoad = async ({cookies}): Promise<{ lessonPlans: Array<LessonPlan> }> => {
    return {lessonPlans: await lessonQueries.findUserLessonPlans(await redirectRejectedToken(cookies, REDIRECT_401))}
}
