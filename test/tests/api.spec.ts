import {type APIResponse, expect, type Page, request, test} from '@playwright/test'
import {loginForToken} from './login'

type ApiClientType = 'browser' | 'device'

interface ApiTestOpts {
    authToken: string
    data?: any
    headers?: Record<string, string>
    path: string
    type?: ApiClientType
}

const API_CLIENT_TYPES: Array<ApiClientType> = ['browser', 'device']

async function doApiRequest(page: Page, opts: ApiTestOpts): Promise<APIResponse> {
    const headers: Record<string, string> = {
        ...opts.headers,
        'cache-control': 'no-cache',
    }
    if (opts.type === 'device') {
        headers['authorization'] = 'Bearer ' + opts.authToken
    }
    const requestContext = opts.type === 'browser' ? page.request : await request.newContext()
    return await requestContext.post(opts.path, {
        headers,
        data: opts.data ? JSON.stringify(opts.data) : undefined,
    })
}

test.describe('POST /api/lessons', () => {
    API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('creates without request content', async ({page}) => {
                const response = await doApiRequest(page, {
                    authToken: await loginForToken(page),
                    path: '/api/lessons',
                    type: clientType,
                })
                expect(response.status()).toBe(201)
                expect(response.headers()['content-type']).toBe('text/plain;charset=UTF-8')
                expect((await response.body()).toString()).toHaveLength(36)
            })
            test('is rejected for invalid instrument', async ({page}) => {
                const response = await doApiRequest(page, {
                    authToken: await loginForToken(page),
                    path: '/api/lessons',
                    data: {instrument: 'washboard'},
                    headers: {'content-type': 'application/json'},
                    type: 'browser',
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for invalid name', async ({page}) => {
                const response = await doApiRequest(page, {
                    authToken: await loginForToken(page),
                    path: '/api/lessons',
                    data: {name: 'eg'},
                    headers: {'content-type': 'application/json'},
                    type: 'browser',
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    })
})

test.describe('POST /api/lessons/$planId/units', () => {

    API_CLIENT_TYPES.forEach(clientType => {
        const createLessonPlan = async (page: Page, authToken: string): Promise<string> => {
            const response = await doApiRequest(page, {
                authToken,
                path: '/api/lessons',
                type: clientType,
            })
            return (await response.body()).toString()
        }
        test.describe(`${clientType} api client`, () => {
            test('is rejected for invalid frames', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken)
                const response = await doApiRequest(page, {
                    authToken,
                    path: `/api/lessons/${planId}/units`,
                    data: {frames: {}},
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for invalid instrument', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken)
                const response = await doApiRequest(page, {
                    authToken,
                    path: `/api/lessons/${planId}/units`,
                    data: {instrument: 'washboard'},
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for invalid lesson name', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken)
                const response = await doApiRequest(page, {
                    authToken,
                    path: `/api/lessons/${planId}/units`,
                    data: {name: 'eg'},
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    })
})
