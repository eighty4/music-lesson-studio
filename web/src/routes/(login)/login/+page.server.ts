import {fail, redirect} from '@sveltejs/kit'
import {ZodError} from 'zod'
import type {Actions, PageServerLoad} from './$types'
import {loginQueries} from '$lib/data/queries'

export const load: PageServerLoad = async ({locals: {user}}) => {
    if (user.authenticated) {
        redirect(302, '/dashboard')
    }
}

export const actions: Actions = {
    default: async ({request}) => {
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            return fail(411)
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            return fail(415)
        }
        const formData = await request.formData()
        const email = formData.get('email') as string
        try {
            const loginToken = await loginQueries.createLoginToken(email, getLoginRedirectToPathSearchParam(request.url))
            // todo send email with login token
            if (process.env.NODE_ENV !== 'production') {
                console.log(`http://localhost:5173/login/verify/${email}/${loginToken}`)
            }
            redirect(302, `/login/email-sent/${email}`)
        } catch (e) {
            if (e instanceof ZodError) {
                console.log(e)
                return fail(400, {email, invalidEmail: true})
            } else {
                throw e
            }
        }
    },
}

function getLoginRedirectToPathSearchParam(url: string): string | undefined {
    const searchIndex = url.indexOf('?')
    if (searchIndex !== -1) {
        const searchString = url.substring(searchIndex + 1)
        const searchParams = new URLSearchParams(searchString)
        return searchParams.get('to') ?? undefined
    }
}
