import {type APIResponse, expect, type Page, request, test} from '@playwright/test'
import {loginForToken, logoutSession} from './login'

type ApiClientType = 'browser' | 'device'

interface ApiTestOpts {
    authToken?: string
    body?: string
    headers?: Record<string, string>
    method: 'get' | 'post' | 'put'
    path: string
    type?: ApiClientType
}

const API_CLIENT_TYPES: Array<ApiClientType> = ['browser', 'device']

async function doApiRequest(page: Page, opts: ApiTestOpts): Promise<APIResponse> {
    const headers: Record<string, string> = {
        ...opts.headers,
        'cache-control': 'no-cache',
    }
    if (opts.type === 'device' && !!opts.authToken) {
        headers['authorization'] = 'Bearer ' + opts.authToken
    }
    const requestContext = opts.type === 'browser' ? page.request : await request.newContext()
    switch (opts.method) {
        case 'get':
            return await requestContext.get(opts.path, {headers})
        case 'post':
        case 'put':
            return await requestContext[opts.method](opts.path, {headers, data: opts.body})
    }
}

const createLessonPlan = async (page: Page, authToken: string, clientType: ApiClientType): Promise<string> => {
    const response = await doApiRequest(page, {
        authToken,
        method: 'post',
        path: '/api/lessons',
        type: clientType,
    })
    return (await response.body()).toString()
}

const createLessonUnit = async (planId: string, page: Page, authToken: string, clientType: ApiClientType): Promise<string> => {
    const response = await doApiRequest(page, {
        authToken,
        method: 'post',
        path: `/api/lessons/${planId}/units`,
        type: clientType,
    })
    return (await response.body()).toString()
}

const fetchLessonUnit = async (planId: string, unitId: string, page: Page, authToken: string, clientType: ApiClientType): Promise<any> => {
    const response = await doApiRequest(page, {
        authToken,
        method: 'get',
        path: `/api/lessons/${planId}/units/${unitId}`,
        type: clientType,
    })
    return JSON.parse((await response.body()).toString())
}

test.describe('POST /api/lessons', () => API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('creates without request content', async ({page}) => {
                const response = await doApiRequest(page, {
                    authToken: await loginForToken(page),
                    method: 'post',
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
                    method: 'post',
                    path: '/api/lessons',
                    body: JSON.stringify({instrument: 'washboard'}),
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
                    method: 'post',
                    path: '/api/lessons',
                    body: JSON.stringify({name: 'eg'}),
                    headers: {'content-type': 'application/json'},
                    type: 'browser',
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for user auth', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                await logoutSession(page)
                const response = await doApiRequest(page, {
                    method: 'post',
                    path: `/api/lessons/${planId}/units`,
                    body: JSON.stringify({name: 'eg'}),
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(401)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    }),
)

test.describe('POST /api/lessons/$planId/units', () => API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('is rejected for invalid frames', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'post',
                    path: `/api/lessons/${planId}/units`,
                    body: JSON.stringify({frames: {}}),
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for invalid instrument', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'post',
                    path: `/api/lessons/${planId}/units`,
                    body: JSON.stringify({instrument: 'washboard'}),
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for invalid lesson name', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'post',
                    path: `/api/lessons/${planId}/units`,
                    body: JSON.stringify({name: 'eg'}),
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(400)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
            test('is rejected for user auth', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                await logoutSession(page)
                const response = await doApiRequest(page, {
                    method: 'post',
                    path: `/api/lessons/${planId}/units`,
                    body: JSON.stringify({name: 'eg'}),
                    headers: {'content-type': 'application/json'},
                    type: clientType,
                })
                expect(response.status()).toBe(401)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    }),
)

test.describe('PUT /api/lessons/$planId/units/$unitId/frames', () => API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('updates frame data', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const unitId = await createLessonUnit(planId, page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'put',
                    path: `/api/lessons/${planId}/units/${unitId}/frames`,
                    headers: {
                        'content-type': 'application/json',
                    },
                    body: JSON.stringify([{
                        entities: [{
                            type: 'measure',
                            rect: {x: 1, y: 2, w: 3, h: 4},
                        }],
                    }]),
                    type: clientType,
                })
                expect(response.status()).toBe(200)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
                const lessonUnit = await fetchLessonUnit(planId, unitId, page, authToken, clientType)
                expect(lessonUnit.frames[0].entities[0]).toStrictEqual({
                    type: 'measure',
                    rect: {x: 1, y: 2, w: 3, h: 4},
                })
            })
            test('is rejected for user auth', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const unitId = await createLessonUnit(planId, page, authToken, clientType)
                await logoutSession(page)
                const response = await doApiRequest(page, {
                    method: 'put',
                    path: `/api/lessons/${planId}/units/${unitId}/frames`,
                    headers: {
                        'content-type': 'application/json',
                    },
                    body: JSON.stringify([]),
                    type: clientType,
                })
                expect(response.status()).toBe(401)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    }),
)

test.describe('GET /api/lessons/$planId', () => API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('returns lesson plan data', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'get',
                    path: `/api/lessons/${planId}`,
                    type: clientType,
                })
                expect(response.status()).toBe(200)
                expect(response.headers()['content-type']).toBe('application/json')
                const lessonPlan = JSON.parse((await response.body()).toString())
                expect(lessonPlan.user.id.length).toBe(36)
                expect(lessonPlan.id).toBe(planId)
                expect(lessonPlan.name).toBeNull()
                expect(lessonPlan.created).not.toBeNull()
                expect(lessonPlan.updated).not.toBeNull()
            })
            test('is rejected for user auth', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                await logoutSession(page)
                const response = await doApiRequest(page, {
                    method: 'get',
                    path: `/api/lessons/${planId}`,
                    type: clientType,
                })
                expect(response.status()).toBe(401)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    }),
)

test.describe('GET /api/lessons/$planId/units/$unitId', () => API_CLIENT_TYPES.forEach(clientType => {
        test.describe(`${clientType} api client`, () => {
            test('returns lesson unit data', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const unitId = await createLessonUnit(planId, page, authToken, clientType)
                const response = await doApiRequest(page, {
                    authToken,
                    method: 'get',
                    path: `/api/lessons/${planId}/units/${unitId}`,
                    type: clientType,
                })
                expect(response.status()).toBe(200)
                expect(response.headers()['content-type']).toBe('application/json')
                const lessonUnit = JSON.parse((await response.body()).toString())
                expect(lessonUnit.user.id.length).toBe(36)
                expect(lessonUnit.plan.id).toBe(planId)
                expect(lessonUnit.plan.name).toBeNull()
                expect(lessonUnit.id).toBe(unitId)
                expect(lessonUnit.name).toBeNull()
                expect(lessonUnit.created).not.toBeNull()
                expect(lessonUnit.updated).not.toBeNull()
            })
            test('is rejected for user auth', async ({page}) => {
                const authToken = await loginForToken(page)
                const planId = await createLessonPlan(page, authToken, clientType)
                const unitId = await createLessonUnit(planId, page, authToken, clientType)
                await logoutSession(page)
                const response = await doApiRequest(page, {
                    method: 'get',
                    path: `/api/lessons/${planId}/units/${unitId}`,
                    type: clientType,
                })
                expect(response.status()).toBe(401)
                expect(response.headers()['content-type']).toBeUndefined()
                expect((await response.body()).toString()).toHaveLength(0)
            })
        })
    }),
)
