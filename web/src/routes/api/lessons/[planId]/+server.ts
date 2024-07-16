import {type RequestHandler} from '@sveltejs/kit'
import {NotFound} from '$lib/data/ErrorTypes'
import {lessonQueries} from '$lib/data/instances'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'

export const GET: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    try {
        return Response.json(await lessonQueries.findUserLessonPlan(params.planId!, userId))
    } catch (e: unknown) {
        if (e instanceof NotFound) {
            console.warn(`GET /api/lessons/$planId 404 - ${e.message}`)
            return new Response(null, {status: 404})
        } else {
            console.warn(`GET /api/lessons/$planId 500 - ${(e as Error)?.message || e}`)
            return new Response(null, {status: 500})
        }
    }
}

export const OPTIONS: RequestHandler = () => {
    return new Response(null, {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, OPTIONS',
            // 'Access-Control-Allow-Headers': 'Content-Type',
        },
    })
}
