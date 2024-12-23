import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import {ZodError} from 'zod'
import {BadData} from '$lib/data/ErrorTypes'
import {randomString} from '$lib/data/generate'
import LoginQueries from './LoginQueries'

describe('LoginQueries', () => {

    let db: pg.Pool
    let loginQueries: LoginQueries

    beforeAll(() => {
        db = new pg.Pool()
        loginQueries = new LoginQueries(db)
    })

    describe('createDeviceToken', () => {
        it('saves device token', async () => {
            const deviceToken = await loginQueries.createDeviceToken()
            const result = await db.query({
                text: 'select * from device_activations where token = $1',
                values: [deviceToken],
            })
            expect(result.rowCount).toBe(1)
            const [row] = result.rows
            expect(row['token']).toBe(deviceToken)
            expect(row['created']).toBeDefined()
        })
    })

    describe('verifyDeviceToken', () => {
        it('verifies device token without path', async () => {
            const deviceToken = await loginQueries.createDeviceToken()
            expect(await loginQueries.verifyDeviceToken(deviceToken)).toStrictEqual({verified: true})
        })
        it('rejects bogus device token', async () => {
            await loginQueries.createDeviceToken()
            expect(await loginQueries.verifyDeviceToken('bogus_token')).toStrictEqual({verified: false})
        })
        it('rejects verified device token', async () => {
            const deviceToken = await loginQueries.createDeviceToken()
            await loginQueries.verifyDeviceToken(deviceToken)
            expect(await loginQueries.verifyDeviceToken(deviceToken)).toStrictEqual({verified: false})
        })
        it('rejects previous device token', async () => {
            const deviceToken = await loginQueries.createDeviceToken()
            await loginQueries.createDeviceToken()
            await loginQueries.verifyDeviceToken(deviceToken)
            expect(await loginQueries.verifyDeviceToken(deviceToken)).toStrictEqual({verified: false})
        })
    })

    describe('saveLoginToken', () => {
        it('saves login token without path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email)
            const result = await db.query({
                text: 'select * from logins where email = $1 and token = $2',
                values: [email, loginToken],
            })
            expect(result.rowCount).toBe(1)
            const [row] = result.rows
            expect(row['email']).toBe(email)
            expect(row['token']).toBe(loginToken)
            expect(row['path']).toBe(null)
        })
        it('saves login token with path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email, '/classes')
            const result = await db.query({
                text: 'select * from logins where email = $1 and token = $2',
                values: [email, loginToken],
            })
            expect(result.rowCount).toBe(1)
            const [row] = result.rows
            expect(row['email']).toBe(email)
            expect(row['token']).toBe(loginToken)
            expect(row['path']).toBe('/classes')
        })
        it('rejects bad email', async () => {
            const email = 'wealthy_prince'
            await expect(() => loginQueries.createLoginToken(email))
                .rejects
                .toThrowError(ZodError)
        })
        it('rejects bad path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            await expect(() => loginQueries.createLoginToken(email, 'foo bar'))
                .rejects
                .toThrowError(BadData)
        })
    })

    describe('verifyLoginToken', () => {
        it('verifies login token without path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: true})
        })
        it('verifies login token with path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email, '/lessons')
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({
                verified: true,
                path: '/lessons',
            })
        })
        it('rejects bogus email', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email)
            expect(await loginQueries.verifyLoginToken('bogus_email@eighty4.tech', loginToken)).toStrictEqual({verified: false})
        })
        it('rejects bogus login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            await loginQueries.createLoginToken(email)
            expect(await loginQueries.verifyLoginToken(email, 'bogus_token')).toStrictEqual({verified: false})
        })
        it('rejects verified login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email)
            await loginQueries.verifyLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: false})
        })
        it('rejects previous login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = await loginQueries.createLoginToken(email)
            await loginQueries.createLoginToken(email)
            await loginQueries.verifyLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: false})
        })
    })
})
