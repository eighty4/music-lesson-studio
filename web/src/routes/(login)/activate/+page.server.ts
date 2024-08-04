import {fail} from '@sveltejs/kit'
import type {Actions, PageServerLoad} from './$types'
import {redirectRejectedToken} from '$lib/token/redirectRejectedToken'
import {loginQueries, userQueries} from '$lib/data/instances'
import {activationPool} from '$lib/device/instances'
import {createAuthToken} from '$lib/token/createAuthToken'

const REDIRECT_URI = '/login?to=/activate'

export const load: PageServerLoad = async ({cookies}) => {
    await redirectRejectedToken(cookies, REDIRECT_URI)
}

export const actions: Actions = {
    default: async ({cookies, request}) => {
        const userId = await redirectRejectedToken(cookies, REDIRECT_URI)
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
        const authToken = await createAuthToken(await userQueries.fetchUserById(userId))
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
