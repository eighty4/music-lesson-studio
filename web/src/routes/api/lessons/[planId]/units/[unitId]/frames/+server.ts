import {json, type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/queries'
import {NotFound, ZodError} from '$lib/data/ErrorTypes'
import {hasJsonContent} from '$lib/http/requestUtils'

export const PUT: RequestHandler = async ({locals: {user}, params, request}) => {
    if (!user.authenticated) {
        return new Response(null, {status: 401})
    }
    if (!hasJsonContent(request)) {
        return new Response(null, {status: 400})
    }
    const frameData = await request.json()
    try {
        await lessonQueries.updateLessonUnitFrames(user.userId!, params.planId!, params.unitId!, frameData)
        return new Response(null, {status: 200})
    } catch (e: unknown) {
        if (e instanceof NotFound) {
            console.warn(`PUT /api/lessons/$planId/units/$unitId/frames 404 - ${e.message}`)
            return new Response(null, {status: 404})
        } else if (e instanceof ZodError) {
            console.warn(`PUT /api/lessons/$planId/units/$unitId/frames 400 - ${e.message}`)
            return json(e.issues, {status: 400})
        } else {
            throw e
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
