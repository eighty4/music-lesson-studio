import {type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/instances'
import {isValidFrameData} from '$lib/data/LessonPlanTypes'
import {hasJsonRequestBody} from '$lib/http/requestUtils'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'

// todo 400 for fail frame and entity validation
// todo 403 for fail lesson plan acl
export const PUT: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    if (!hasJsonRequestBody(request)) {
        return new Response(null, {status: 400})
    }
    const frameData = await request.json()
    if (!isValidFrameData(frameData)) {
        return new Response(null, {status: 400})
    }
    await lessonQueries.updateLessonUnitFrames(userId, params.planId!, params.unitId!, frameData)
    return new Response(null, {status: 200})
}

export const OPTIONS: RequestHandler = () => {
    return new Response(null, {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'PUT, OPTIONS',
            // 'Access-Control-Allow-Headers': 'Content-Type',
        },
    })
}
