import {type RequestHandler} from '@sveltejs/kit'
import {lessonQueries} from '$lib/data/instances'
import {getApiAuthenticatedUserId} from '$lib/token/getApiAuthenticatedUserId'

// todo 404 for not found
export const GET: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    return Response.json(await lessonQueries.findUserLessonUnit(userId, params.planId!, params.unitId!))
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
