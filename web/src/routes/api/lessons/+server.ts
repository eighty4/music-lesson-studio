import {json, type RequestHandler} from '@sveltejs/kit'
import {ZodError} from '$lib/data/ErrorTypes'
import {type LessonPlan} from '$lib/data/LessonPlanTypes'
import {lessonQueries} from '$lib/data/queries'
import {hasJsonContent} from '$lib/http/requestUtils'

export const POST: RequestHandler = async ({locals: {user}, request}) => {
    if (!user.authenticated) {
        return new Response(null, {status: 401})
    }
    const creating: Omit<LessonPlan, 'id' | 'created' | 'updated'> = {user: {id: user.userId!}}
    if (hasJsonContent(request)) {
        const {instrument, name} = await request.json()
        creating.instrument = instrument
        creating.name = name
    }
    try {
        const created = await lessonQueries.createLessonPlan(creating)
        return new Response(created.id, {status: 201})
    } catch (e: unknown) {
        if (e instanceof ZodError) {
            console.warn(`POST /api/lessons 400 - ${e.message}`)
            return json(e.issues, {status: 400})
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
