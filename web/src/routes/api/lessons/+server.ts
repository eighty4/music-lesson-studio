import {type RequestHandler} from '@sveltejs/kit'
import {BadData} from '$lib/data/ErrorTypes'
import {lessonQueries} from '$lib/data/instances'
import {type LessonPlan} from '$lib/data/LessonPlanTypes'
import {hasJsonContent} from '$lib/http/requestUtils'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'

export const POST: RequestHandler = async ({cookies, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    const creating: Omit<LessonPlan, 'id' | 'created' | 'updated'> = {user: {id: userId}}
    if (hasJsonContent(request)) {
        const {instrument, name} = await request.json()
        creating.instrument = instrument
        creating.name = name
    }
    try {
        const created = await lessonQueries.createLessonPlan(creating)
        return new Response(created.id, {status: 201})
    } catch (e: unknown) {
        if (e instanceof BadData) {
            console.warn(`POST /api/lessons 400 - ${e.message}`)
            return new Response(null, {status: 400})
        } else {
            console.warn(`POST /api/lessons 500 - ${(e as Error)?.message || e}`)
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
