import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import {randomString} from './generate'
import LoginQueries from './LoginQueries'

describe('LoginQueries', () => {

    let db: pg.Pool
    let loginQueries: LoginQueries

    beforeAll(() => {
        db = new pg.Pool()
        loginQueries = new LoginQueries(db)
    })

    describe('saveLoginToken', () => {
        it('saves login token without path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
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
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken, '/classes')
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
            const loginToken = randomString(6)
            await expect(() => loginQueries.saveLoginToken(email, loginToken))
                .rejects
                .toThrowError(/email_valid_chk/)
        })
        it('rejects bad login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(5)
            await expect(() => loginQueries.saveLoginToken(email, loginToken))
                .rejects
                .toThrowError(/token_length_chk/)
        })
        it('rejects bad path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(5)
            await expect(() => loginQueries.saveLoginToken(email, loginToken, 'foo bar'))
                .rejects
                .toThrowError(/path_valid_chk/)
        })
    })

    describe('verifyLoginToken', () => {
        it('verifies login token without path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: true})
        })
        it('verifies login token with path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken, '/lessons')
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({
                verified: true,
                path: '/lessons',
            })
        })
        it('rejects bogus email', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken('bogus_email@eighty4.tech', loginToken)).toStrictEqual({verified: false})
        })
        it('rejects bogus login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, 'bogus_token')).toStrictEqual({verified: false})
        })
        it('rejects verified login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
            await loginQueries.verifyLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: false})
        })
        it('rejects previous login token', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const loginToken = randomString(6)
            await loginQueries.saveLoginToken(email, loginToken)
            await loginQueries.saveLoginToken(email, randomString(6))
            await loginQueries.verifyLoginToken(email, loginToken)
            expect(await loginQueries.verifyLoginToken(email, loginToken)).toStrictEqual({verified: false})
        })
    })
})
