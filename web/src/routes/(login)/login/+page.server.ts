import type {Actions} from './$types'
import {loginQueries} from '$lib'
import {redirect} from '@sveltejs/kit'

export const actions: Actions = {
    default: async ({cookies, request}) => {
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
        await loginQueries.saveLoginToken(email, loginToken)
        console.log('http://localhost:5173/login/verify/' + loginToken)
        // todo send email
        redirect(301, '/login/email-sent/' + email)
    }
}

function randomString(length: number): string {
    if (typeof length === 'undefined' || isNaN(length)) {
        throw new Error('must provide length')
    }
    const letters = 'abcdefghijklmnopqrstuvwxyz'
    let str = ''
    for (let i = 0; i < length; i++) {
        str += letters.charAt(Math.floor(Math.random() * 26))
    }
    return str
}
