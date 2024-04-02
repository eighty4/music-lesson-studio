import type {PageServerLoad} from './$types'
import {lessonQueries, redirectRejectedToken} from '$lib'
import type {LessonPlan} from '$lib/data/LessonPlanTypes'
import {error} from '@sveltejs/kit'

const REDIRECT_401 = (lessonPlanId: string) => `/login?to=/lesson-plans/${lessonPlanId}`

export const load: PageServerLoad = async ({cookies, params}): Promise<LessonPlan> => {
    const user = await redirectRejectedToken(cookies, REDIRECT_401(params.lessonPlanId))
    try {
        return await lessonQueries.findUserLessonPlan(params.lessonPlanId, user.id)
    } catch (e: any) {
        if (e.message.startsWith('not found')) {
            error(404)
        } else {
            throw e
        }
    }
}
