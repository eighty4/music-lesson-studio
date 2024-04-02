import type {PageServerLoad} from './$types'
import {lessonQueries, redirectRejectedToken} from '$lib'
import type {LessonPlan} from '$lib/data/LessonPlanTypes'

const REDIRECT_401 = '/login?to=/lesson-plans'

export const load: PageServerLoad = async ({cookies}): Promise<{ lessonPlans: Array<LessonPlan> }> => {
    const user = await redirectRejectedToken(cookies, REDIRECT_401)
    return {lessonPlans: await lessonQueries.findUserLessonPlans(user.id)}
}
