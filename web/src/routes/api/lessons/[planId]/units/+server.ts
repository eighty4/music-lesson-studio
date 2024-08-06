import {type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/instances'
import {type LessonUnit} from '$lib/data/LessonPlanTypes'
import {hasJsonContent} from '$lib/http/requestUtils'
import {BadData, NotFound} from '$lib/data/ErrorTypes'

export const POST: RequestHandler = async ({locals: {user}, params, request}) => {
    if (!user.authenticated) {
        return new Response(null, {status: 401})
    }
    const creating: Omit<LessonUnit, 'id' | 'created' | 'updated'> = {
        user: {id: user.userId!},
        plan: {id: params.planId!},
    }
    if (hasJsonContent(request)) {
        const {frames, instrument, name} = await request.json()
        creating.frames = frames
        creating.instrument = instrument
        creating.name = name
    }
    try {
        const created = await lessonQueries.createLessonUnit(creating)
        return new Response(created.id, {status: 201})
    } catch (e: unknown) {
        if (e instanceof NotFound) {
            console.warn(`POST /api/lessons/$planId/units 404 - ${e.message}`)
            return new Response(null, {status: 404})
        } else if (e instanceof BadData) {
            console.warn(`POST /api/lessons/$planId/units 400 - ${e.message}`)
            return new Response(null, {status: 400})
        } else {
            console.warn(`POST /api/lessons/$planId/units 500 - ${(e as Error)?.message || e}`)
            return new Response(null, {status: 500})
        }
    }
}

export const OPTIONS: RequestHandler = () => {
    return new Response(null, {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            // 'Access-Control-Allow-Headers': 'Content-Type',
        },
    })
}
