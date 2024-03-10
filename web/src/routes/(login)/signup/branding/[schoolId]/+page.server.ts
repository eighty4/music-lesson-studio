import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {redirectRejectedToken} from '$lib'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies}) => {
    const userId = await redirectRejectedToken(cookies, REDIRECT_401)
    // todo verify user is admin for school id
}

export const actions: Actions = {
    default: async ({request, params}) => {
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            fail(400)
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            fail(400)
        }
        const formData = await request.formData()

        // todo branding form data
        redirect(302, '/signup/faculty/' + params.schoolId)
    },
}
