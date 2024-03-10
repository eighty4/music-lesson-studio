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

    describe('saveFacultyMembers', () => {
        it('saves multiple users', async () => {
            const faculty = [{
                email: `user_${randomString(6)}@eighty4.tech`,
                name: 'peter',
                admin: false,
            }, {
                email: `user_${randomString(6)}@eighty4.tech`,
                name: 'paul',
                admin: true,
            }, {
                email: `user_${randomString(6)}@eighty4.tech`,
                name: 'mary',
                admin: true,
            }]
            const result = await db.query('insert into schools (name) values ($1) returning id', ['Hard Knocks'])
            const {id} = result.rows[0]
            await userQueries.saveFacultyMembers(id, faculty)
            const {rows: teachers} = await db.query('select t.user_id, t.school_id, t.admin, u.name, u.email, u.created from users u join teachers t on u.id = t.user_id where t.school_id = $1', [id])
            expect(teachers).toHaveLength(3)
            const peter = teachers.find(t => t.name === 'peter')
            expect(peter).not.toBeNull()
            expect(peter.user_id).toHaveLength(36)
            expect(peter.created).toBeDefined()
            expect(peter.email).toBe(faculty[0].email)
            expect(peter.admin).toBe(false)
            const paul = teachers.find(t => t.name === 'paul')
            expect(paul).not.toBeNull()
            expect(paul.user_id).toHaveLength(36)
            expect(paul.created).toBeDefined()
            expect(paul.email).toBe(faculty[1].email)
            expect(paul.admin).toBe(true)
            const mary = teachers.find(t => t.name === 'mary')
            expect(mary).not.toBeNull()
            expect(mary.user_id).toHaveLength(36)
            expect(mary.created).toBeDefined()
            expect(mary.email).toBe(faculty[2].email)
            expect(mary.admin).toBe(true)
        })

        it('closes transaction with rollback on exception', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const faculty = [{
                email: email,
                name: 'peter tosh',
                admin: false,
            }]
            const result = await db.query('insert into schools (name) values ($1) returning id', ['Hard Knocks'])
            const schoolId = result.rows[0].id
            const malformedSchoolId = schoolId.substring(1)
            await expect(() => userQueries.saveFacultyMembers(malformedSchoolId, faculty))
                .rejects
                .toThrowError(/^invalid input syntax for type uuid/)
            const {rows: teachers} = await db.query('select t.user_id, t.school_id, t.admin, u.name, u.email, u.created from users u join teachers t on u.id = t.user_id where t.school_id = $1', [schoolId])
            expect(teachers).toHaveLength(0)
            const {rows: users} = await db.query('select * from users where email = $1', [email])
            expect(users).toHaveLength(0)
        })
    })
})
