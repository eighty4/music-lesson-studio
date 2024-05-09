import {type RequestHandler} from '@sveltejs/kit'
import {getAuthenticatedUserId, lessonQueries} from '$lib'
import type {LessonUnit} from '$lib/data/LessonPlanTypes'

export const POST: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getAuthenticatedUserId(cookies)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    // todo 403 for fail lesson plan acl
    const payload = await request.json()
    // todo validate frames
    const unitId = await lessonQueries.saveLessonUnit(userId, params.planId!, payload as LessonUnit)
    return new Response(unitId, {status: 201})
}
