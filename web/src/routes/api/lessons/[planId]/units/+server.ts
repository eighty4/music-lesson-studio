import {type RequestHandler} from '@sveltejs/kit'
import {getApiAuthenticatedUserId, lessonQueries} from '$lib'
import {isValidFrameData, isValidInstrument, isValidLessonName, type LessonUnit} from '$lib/data/LessonPlanTypes'
import {hasJsonRequestBody} from '$lib/http/requestUtils'

// todo 400 for fail name and instrument validation
// todo 403 for fail lesson plan acl
export const POST: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    const creating: Omit<LessonUnit, 'id' | 'created' | 'updated'> = {userId, planId: params.planId!}
    if (hasJsonRequestBody(request)) {
        const {frames, instrument, name} = await request.json()
        if (!isValidFrameData(frames)) {
            return new Response(null, {status: 400})
        }
        if (!isValidInstrument(instrument)) {
            return new Response(null, {status: 400})
        }
        if (!isValidLessonName(name)) {
            return new Response(null, {status: 400})
        }
        creating.frames = frames
        creating.instrument = instrument
        creating.name = name
    }
    const created = await lessonQueries.createLessonUnit(creating)
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
