import {type RequestHandler} from '@sveltejs/kit'
import {getApiAuthenticatedUserId, lessonQueries} from '$lib'

// todo 400 for fail name and instrument validation
// todo 403 for fail lesson plan acl
export const GET: RequestHandler = async ({cookies, params, request}) => {
    const userId = await getApiAuthenticatedUserId(cookies, request)
    if (!userId) {
        return new Response(null, {status: 401})
    }
    return Response.json(await lessonQueries.findUserLessonPlan(params.planId!, userId))
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
