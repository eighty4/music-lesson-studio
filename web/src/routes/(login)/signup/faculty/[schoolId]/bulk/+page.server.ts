import {fail, redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {redirectRejectedToken, schoolQueries, userQueries} from '$lib'
import {isValidEmail, isValidName} from '$lib/data/UserTypes'
import type {FacultyMemberImport} from '$lib/data/UserQueries'

const REDIRECT_401 = '/login?to=/signup'

export const load: PageServerLoad = async ({cookies, params}) => {
    const {id: userId} = await redirectRejectedToken(cookies, REDIRECT_401)
    if (!await schoolQueries.isAdminForSchool(userId, params.schoolId)) {
        // todo +error.svelte ?
        redirect(302, '/')
    }
}

export const actions: Actions = {
    default: async ({params, request, url}) => {
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            return fail(411)
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            return fail(415)
        }
        const postedValues: Array<FacultyMemberImport> = []
        const formData = await request.formData()
        for (const key of formData.keys()) {
            console.debug(`${key}=${formData.get(key)}`)
            const match = /^faculty\[(?<i>\d{1,2})]\[(?<field>name|email|admin)]$/.exec(key)
            if (!match) {
                console.error('regex result null')
                return fail(400)
            } else {
                const i = parseInt(match.groups!.i, 10)
                const field = match.groups!.field
                while (i >= postedValues.length) {
                    postedValues.push({} as FacultyMemberImport)
                }
                (postedValues as any)[i][field] = key.endsWith('[admin]') ? formData.get(key) === 'on' : formData.get(key)
            }
        }
        if (!postedValues.length) {
            return fail(400)
        }
        const faculty = postedValues.filter(teacher => {
            return teacher.name.length && teacher.email.length
        })
        for (const teacher of faculty) {
            if (!isValidName(teacher.name) || !isValidEmail(teacher.email)) {
                return fail(400)
            }
        }
        await userQueries.saveFacultyMembers(params.schoolId, faculty)
        redirect(302, '/signup/courses/' + params.schoolId)
    },
}
