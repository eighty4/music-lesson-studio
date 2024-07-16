import {type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/instances'
import {isValidFrameData} from '$lib/data/LessonPlanTypes'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'
import {BadData, NotFound} from '$lib/data/ErrorTypes'
import {hasJsonContent} from '$lib/http/requestUtils'

export const PUT: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    if (!hasJsonContent(request)) {
        return new Response(null, {status: 400})
    }
    const frameData = await request.json()
    if (!isValidFrameData(frameData)) {
        return new Response(null, {status: 400})
    }
    try {
        await lessonQueries.updateLessonUnitFrames(userId, params.planId!, params.unitId!, frameData)
        return new Response(null, {status: 200})
    } catch (e: unknown) {
        if (e instanceof NotFound) {
            console.warn(`PUT /api/lessons/$planId/units/$unitId/frames 404 - ${e.message}`)
            return new Response(null, {status: 404})
        } else if (e instanceof BadData) {
            console.warn(`PUT /api/lessons/$planId/units/$unitId/frames 400 - ${e.message}`)
            return new Response(null, {status: 400})
        } else {
            console.warn(`PUT /api/lessons/$planId/units/$unitId/frames 500 - ${(e as Error)?.message || e}`)
            return new Response(null, {status: 500})
        }
    }
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
