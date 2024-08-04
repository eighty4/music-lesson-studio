import {expect, request, test} from '@playwright/test'
import {activateDevice} from '../activate'
import {loginForToken} from '../login'

interface SSEEvent {
    data: string
    event: string
}

async function readSSEEvent(reader: ReadableStreamDefaultReader): Promise<SSEEvent | null> {
    const {value, done} = await reader.read()
    if (done) {
        return null
    } else {
        let data: string | undefined = undefined
        let event: string | undefined = undefined
        for (const line of new TextDecoder('utf-8').decode(value).trim().split('\n')) {
            const value = line.substring(line.indexOf(':') + 1).trim()
            if (line.startsWith('data:')) {
                data = value
            } else if (line.startsWith('event:')) {
                event = value
            }
        }
        return {data, event}
    }
}

test.describe('GET /api/device/activation', () => {
    test('sends event with auth token for device activation', ({baseURL, page}) => {
        const url = baseURL + '/api/device/activation'
        return fetch(url).then((response) => {
            const reader = response.body.getReader()
            return readSSEEvent(reader)
                .then(async sseEvent => {
                    expect(sseEvent.event).toBe('initiated')
                    await loginForToken(page)
                    await activateDevice(page, sseEvent.data)
                    return readSSEEvent(reader)
                })
                .then(async (sseEvent) => {
                    expect(sseEvent.event).toBe('activated')
                    return sseEvent.data
                })
                .then(async (authToken) => {
                    expect(await readSSEEvent(reader)).toBeNull()
                    const requestContext = await request.newContext()
                    const response = await requestContext.post('/api/lessons', {
                        headers: {
                            authorization: 'Bearer ' + authToken,
                        },
                    })
                    expect(response.status()).toBe(201)
                })
        })
    })
})
