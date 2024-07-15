import {type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/instances'
import {isValidInstrument, isValidLessonName, type LessonPlan} from '$lib/data/LessonPlanTypes'
import {hasJsonRequestBody} from '$lib/http/requestUtils'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'

// todo 400 for fail name and instrument validation
// todo 403 for fail lesson plan acl
export const POST: RequestHandler = async ({cookies, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    const creating: Omit<LessonPlan, 'id' | 'created' | 'updated'> = {user: {id: userId}}
    if (hasJsonRequestBody(request)) {
        const {instrument, name} = await request.json()
        if (!isValidInstrument(instrument)) {
            return new Response(null, {status: 400})
        }
        if (!isValidLessonName(name)) {
            return new Response(null, {status: 400})
        }
        creating.instrument = instrument
        creating.name = name
    }
    const created = await lessonQueries.createLessonPlan(creating)
    return new Response(created.id, {status: 201})
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
