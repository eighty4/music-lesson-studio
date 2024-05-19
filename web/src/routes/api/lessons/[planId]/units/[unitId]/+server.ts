import {type RequestHandler} from '@sveltejs/kit'
import {getAuthenticatedUserId, lessonQueries} from '$lib'

// todo 404 for not found
export const GET: RequestHandler = async ({cookies, params}) => {
    const userId = await getAuthenticatedUserId(cookies)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    const lessonUnit = await lessonQueries.findUserLessonUnit(userId, params.planId!, params.unitId!)
    return Response.json(lessonUnit)
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
