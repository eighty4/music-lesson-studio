import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies, params}) => {
    const userId = await redirectRejectedToken(cookies, REDIRECT_401)
    if (!await schoolQueries.isAdminForSchool(userId, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
}

export const actions: Actions = {
    default: async ({request, params}) => {
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            return fail(411)
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            return fail(415)
        }
        const formData = await request.formData()

        // todo branding form data
        redirect(302, '/signup/faculty/' + params.schoolId)
    },
}
