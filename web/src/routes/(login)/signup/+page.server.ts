import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {redirectRejectedToken, schoolQueries} from '$lib'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectRejectedToken(cookies, REDIRECT_401)
}

export const actions: Actions = {
    default: async ({cookies, request}) => {
        const {id: userId} = await redirectRejectedToken(cookies, REDIRECT_401)
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            fail(400)
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            fail(400)
        }
        const formData = await request.formData()
        const name = formData.get('name') as string
        if (!name || !name.length) {
            fail(400)
        }
        const {id: schoolId} = await schoolQueries.saveNewSchool(userId, name)
        redirect(301, `/signup/branding/${schoolId}`)
    },
}
