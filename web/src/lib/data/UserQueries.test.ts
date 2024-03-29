import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import UserQueries, {type FacultyMemberImport} from './UserQueries'
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

    describe('lookupUserSchools', () => {
        it('returns what it should', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['john@do.panic', 'John'])
            const userId = userResult.rows[0].id
            const schoolResult1 = await db.query('insert into schools (name) values ($1) returning id', ['School 1'])
            const schoolId1 = schoolResult1.rows[0].id
            const schoolResult3 = await db.query('insert into schools (name) values ($1) returning id', ['School 3'])
            const schoolId3 = schoolResult3.rows[0].id
            const schoolResult2 = await db.query('insert into schools (name) values ($1) returning id', ['School 2'])
            const schoolId2 = schoolResult2.rows[0].id
            await db.query('insert into teachers (user_id, school_id, admin) values ($4, $1, true), ($4, $2, false), ($4, $3, false)', [schoolId1, schoolId2, schoolId3, userId])
            const result = await userQueries.lookupUserSchools(userId)
            expect(result.teacher).toHaveLength(3)
            expect(result.teacher[0].name).toBe('School 1')
            expect(result.teacher[1].name).toBe('School 2')
            expect(result.teacher[2].name).toBe('School 3')
            expect(result.student).toHaveLength(0)
        })
    })

    describe('saveFacultyMember', () => {
        it('saves faculty member', async () => {
            const teacher: FacultyMemberImport = {
                email: `user_${randomString(6)}@eighty4.tech`,
                name: 'Adam Levine',
                admin: false,
            }
            const result = await db.query('insert into schools (name) values ($1) returning id', ['Hard Knocks'])
            const {id} = result.rows[0]
            await userQueries.saveFacultyMember(id, teacher)
            const {rows: teachers} = await db.query('select t.user_id, t.school_id, t.admin, u.name, u.email, u.created from users u join teachers t on u.id = t.user_id where t.school_id = $1', [id])
            expect(teachers).toHaveLength(1)
            const adam = teachers.find(t => t.name === 'Adam Levine')
            expect(adam).not.toBeNull()
            expect(adam.user_id).toHaveLength(36)
            expect(adam.created).toBeDefined()
            expect(adam.email).toBe(teacher.email)
            expect(adam.admin).toBe(false)
        })
        it('saves admin', async () => {
            const teacher: FacultyMemberImport = {
                email: `user_${randomString(6)}@eighty4.tech`,
                name: 'Bono',
                admin: true,
            }
            const result = await db.query('insert into schools (name) values ($1) returning id', ['Hard Knocks'])
            const {id} = result.rows[0]
            await userQueries.saveFacultyMember(id, teacher)
            const {rows: teachers} = await db.query('select t.user_id, t.school_id, t.admin, u.name, u.email, u.created from users u join teachers t on u.id = t.user_id where t.school_id = $1', [id])
            expect(teachers).toHaveLength(1)
            const adam = teachers.find(t => t.name === 'Bono')
            expect(adam).not.toBeNull()
            expect(adam.user_id).toHaveLength(36)
            expect(adam.created).toBeDefined()
            expect(adam.email).toBe(teacher.email)
            expect(adam.admin).toBe(true)
        })
    })

    describe('saveFacultyMembers', () => {
        it('saves bulk faculty members', async () => {
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
