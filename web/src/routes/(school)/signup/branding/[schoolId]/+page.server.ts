import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {loginRedirect} from '$lib/http/requestUtils'

export const load: PageServerLoad = async ({locals: {user}, params, url}) => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
    if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
}

export const actions: Actions = {
    default: async ({locals: {user}, request, params, url}) => {
        if (!user.authenticated) {
            loginRedirect(url)
        }
        if (!await schoolQueries.isAdminForSchool(user.userId!, params.schoolId)) {
            // todo +error.svelte ?
            redirect(302, '/')
        }
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
