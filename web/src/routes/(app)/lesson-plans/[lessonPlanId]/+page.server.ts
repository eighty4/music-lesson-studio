import type {PageServerLoad} from './$types'
import {lessonQueries} from '$lib/data/instances'
import type {LessonUnit} from '$lib/data/LessonPlanTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = (lessonPlanId: string) => `/login?to=/lesson-plans/${lessonPlanId}`

export const load: PageServerLoad = async ({cookies, params}): Promise<{ lessonUnits: Array<LessonUnit> }> => {
    const userId = await redirectRejectedToken(cookies, REDIRECT_401(params.lessonPlanId))
    return {lessonUnits: await lessonQueries.findUserLessonUnits(userId, params.lessonPlanId)}
}
