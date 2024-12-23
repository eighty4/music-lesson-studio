import {type RequestHandler} from '@sveltejs/kit'
import {NotFound} from '$lib/data/ErrorTypes'
import {lessonQueries} from '$lib/data/queries'

export const GET: RequestHandler = async ({locals: {user}, params}) => {
    if (!user.authenticated) {
        return new Response(null, {status: 401})
    }
    try {
        return Response.json(await lessonQueries.findUserLessonUnit(user.userId!, params.planId!, params.unitId!))
    } catch (e: unknown) {
        if (e instanceof NotFound) {
            console.warn(`GET /api/lessons/$planId/units/$unitId 404 - ${e.message}`)
            return new Response(null, {status: 404})
        } else {
            console.warn(`GET /api/lessons/$planId/units/$unitId 500 - ${(e as Error)?.message || e}`)
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
