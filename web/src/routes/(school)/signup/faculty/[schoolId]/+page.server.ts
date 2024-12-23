import {fail, redirect} from '@sveltejs/kit'
import {ZodError} from 'zod'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries, userQueries} from '$lib/data/queries'
import type {FacultyMemberImport} from '$lib/data/queries/UserQueries'
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
    default: async ({locals: {user}, params, request, url}) => {
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
        const teacher: FacultyMemberImport = {
            name: formData.get('name') as string,
            email: formData.get('email') as string,
            admin: formData.get('admin') === 'true',
        }
        try {
            await userQueries.saveFacultyMember(params.schoolId, teacher)
            // todo send invite email
            redirect(302, `/signup/faculty/${params.schoolId}?added=${teacher.name}`)
        } catch (e) {
            if (e instanceof ZodError) {
                return fail(400, teacher)
            } else {
                throw e
            }
        }
    },
}
