import {type RequestHandler} from '@sveltejs/kit'
import {getAuthenticatedUserId, lessonQueries} from '$lib'

export const POST: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getAuthenticatedUserId(cookies)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    const planId = await lessonQueries.createLessonPlan(userId, null, null)
    return new Response(planId, {status: 201})
}
