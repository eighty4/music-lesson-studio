import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {lessonQueries} from '$lib/data/instances'
import {type Instrument, isValidLessonName, isValidOptionalInstrument} from '$lib/data/LessonPlanTypes'
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
        const instrument = formData.get('instrument') as Instrument
        const name = formData.get('name') as string
        if (!isValidLessonName(name)) {
            return fail(400, {name, instrument})
        }
        if (!isValidOptionalInstrument(instrument)) {
            return fail(400, {name, instrument})
        }
        const lessonPlanId = await lessonQueries.createLessonPlan({
            user: {id: user.userId!},
            name,
            instrument,
        })
        redirect(302, `/lesson-plans/${lessonPlanId}`)
    },
}
