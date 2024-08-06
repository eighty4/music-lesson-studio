import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {isValidName} from '$lib/data/UserTypes'
import {loginRedirect, redirectUnauthenticatedUser} from '$lib/http/requestUtils'

export const load: PageServerLoad = redirectUnauthenticatedUser

export const actions: Actions = {
    default: async ({locals: {user}, request, url}) => {
        if (!user.authenticated) {
            loginRedirect(url)
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
        const name = formData.get('name') as string
        if (!isValidName(name)) {
            return fail(400, {name})
        }
        const {id: schoolId} = await schoolQueries.saveNewSchool(user.userId!, name)
        redirect(302, `/signup/branding/${schoolId}`)
    },
}
