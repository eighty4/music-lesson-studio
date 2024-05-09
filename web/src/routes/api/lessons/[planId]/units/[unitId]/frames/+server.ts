import {type RequestHandler} from '@sveltejs/kit'
import {getAuthenticatedUserId, lessonQueries} from '$lib'
import type {LessonFrame} from '$lib/data/LessonPlanTypes'

export const PUT: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getAuthenticatedUserId(cookies)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    // todo 403 for fail lesson plan acl
    const payload: Array<LessonFrame> = await request.json()
    await lessonQueries.updateLessonUnitFrames(userId, params.planId!, params.unitId!, payload)
    return new Response(null, {status: 200})
}
