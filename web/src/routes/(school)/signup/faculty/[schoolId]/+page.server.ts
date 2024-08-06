import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries, userQueries} from '$lib/data/instances'
import {isValidEmail, isValidName} from '$lib/data/UserTypes'
import type {FacultyMemberImport} from '$lib/data/UserQueries'
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
        if (!isValidName(teacher.name) || !isValidEmail(teacher.email)) {
            return fail(400, teacher)
        }
        // todo further validation
        await userQueries.saveFacultyMember(params.schoolId, teacher)
        // todo send invite email
        redirect(302, `/signup/faculty/${params.schoolId}?added=${teacher.name}`)
    },
}
