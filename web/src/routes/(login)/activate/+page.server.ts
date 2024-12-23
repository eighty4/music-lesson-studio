import {fail} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {loginQueries, userQueries} from '$lib/data/queries'
import {activationPool} from '$lib/devices/activation'
import {createAuthToken} from '$lib/token/createAuthToken'
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
        const deviceToken = formData.get('token') as string
        if (!isValidDeviceAuthToken(deviceToken)) {
            return fail(400, {error: 'invalid token', deviceToken})
        }

        const {verified} = await loginQueries.verifyDeviceToken(deviceToken)
        if (!verified) {
            return {error: 'bad data'}
        }
        const authToken = await createAuthToken(await userQueries.fetchUserById(user.userId!))
        const activated = activationPool.activate(deviceToken, authToken)
        if (!activated) {
            return {error: 'bad connection'}
        }
        return {success: true}
    },
}

function isValidDeviceAuthToken(token: string): boolean {
    return token.length === 6
}
