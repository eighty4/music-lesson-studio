import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {schoolQueries} from '$lib/data/instances'
import {isValidName} from '$lib/data/UserTypes'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectRejectedToken(cookies, REDIRECT_401)
}

export const actions: Actions = {
    default: async ({cookies, request}) => {
        const userId = await redirectRejectedToken(cookies, REDIRECT_401)
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
        const {id: schoolId} = await schoolQueries.saveNewSchool(userId, name)
        redirect(302, `/signup/branding/${schoolId}`)
    },
}
