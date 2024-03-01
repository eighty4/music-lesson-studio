import {redirect} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {AUTH_TOKEN_NAME, loginQueries, randomString, verifyAuthToken} from '$lib'

export const load: PageServerLoad = ({cookies}) => {
    if (verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))) {
        redirect(301, '/dashboard')
    }
}

export const actions: Actions = {
    default: async ({request}) => {
        const contentLength = request.headers.get('content-length')
        if (!contentLength || contentLength === '0') {
            redirect(301, '/login?error=content-length')
        }
        const contentType = request.headers.get('content-type')
        if (!contentType || contentType !== 'application/x-www-form-urlencoded') {
            redirect(301, '/login?error=content-type')
        }
        const formData = await request.formData()
        const email = formData.get('email') as string
        if (!email || !email.length || !/^.*@.*$/.test(email)) {
            redirect(301, '/login?error=bad-request')
        }
        const loginToken = randomString(6)
        await loginQueries.saveLoginToken(email, loginToken, getLoginRedirectToPathSearchParam(request.url))
        console.log(`http://localhost:5173/login/verify/${email}/${loginToken}`)
        // todo send email
        redirect(301, `/login/email-sent/${email}`)
    }
}

function getLoginRedirectToPathSearchParam(url: string): string | undefined {
    const searchIndex = url.indexOf('?')
    if (searchIndex !== -1) {
        const searchString = url.substring(searchIndex + 1)
        const searchParams = new URLSearchParams(searchString)
        return searchParams.get('to') ?? undefined
    }
}
