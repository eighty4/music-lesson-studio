import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import UserQueries from './UserQueries'
import {randomString} from './util'

describe('UserQueries', () => {

    let db: pg.Pool
    let userQueries: UserQueries

    beforeAll(() => {
        db = new pg.Pool()
        userQueries = new UserQueries(db)
    })

    describe('lookupOrCreateNewUser', async () => {
        it('saves new user', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const user = await userQueries.lookupOrCreateNewUser(email)
            expect(user.id).toHaveLength(36)
            expect(user.email).toBe(email)
            expect(user.name).toBe('')
            const result = await db.query('select * from users where id = $1', [user.id])
            expect(result.rows).toHaveLength(1)
            expect(result.rows[0].id).toBe(user.id)
            expect(result.rows[0].email).toBe(email)
            expect(result.rows[0].name).toBe('')
        })
        it('returns existing user', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const result = await db.query('insert into users (email, name) values ($1, $2) returning id, created', [email, 'adam'])
            const {id, created} = result.rows[0]
            const user = await userQueries.lookupOrCreateNewUser(email)
            expect(user.id).toBe(id)
            expect(user.email).toBe(email)
            expect(user.name).toBe('adam')
            expect(user.created).toStrictEqual(created)
        })
    })
})
