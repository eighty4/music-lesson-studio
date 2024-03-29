import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import SchoolQueries from './SchoolQueries'
import {randomString} from './util'

describe('SchoolQueries', () => {

    let db: pg.Pool
    let schoolQueries: SchoolQueries

    beforeAll(() => {
        db = new pg.Pool()
        schoolQueries = new SchoolQueries(db)
    })

    describe('lookupSchoolName', () => {
        it('returns school name', async () => {
            const result = await db.query('insert into schools (name) values ($1) returning id', ['School of Paula Abdul'])
            const schoolId = result.rows[0].id
            const schoolName = await schoolQueries.lookupSchoolName(schoolId)
            expect(schoolName).toBe('School of Paula Abdul')
        })

        it('throws error when not found', async () => {
            await expect(() => schoolQueries.lookupSchoolName('a28f3923-7f52-45f4-b41e-dfd8b4d1edb3'))
                .rejects
                .toThrowError(/^school a28f3923-7f52-45f4-b41e-dfd8b4d1edb3 not found$/)
        })
    })

    describe('lookupFaculty', () => {
        it('returns teachers for school id', async () => {
            const adminUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['jimmy@do.panic', 'Jimmy'])
            const adminUserId = adminUserResult.rows[0].id
            const teacherUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['john@do.panic', 'John'])
            const teacherUserId = teacherUserResult.rows[0].id
            const schoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Dave\'s Rhythm Section Schoolyard'])
            const schoolId = schoolResult.rows[0].id
            await db.query('insert into teachers (user_id, school_id, admin) values ($2, $1, true), ($3, $1, false)', [schoolId, adminUserId, teacherUserId])
            const result = await schoolQueries.lookupFaculty(schoolId)
            expect(result).toHaveLength(2)
            expect(result[0].id).toBe(adminUserId)
            expect(result[0].email).toBe('jimmy@do.panic')
            expect(result[0].admin).toBeTruthy()
            expect(result[1].id).toBe(teacherUserId)
            expect(result[1].email).toBe('john@do.panic')
            expect(result[1].admin).toBeFalsy()
        })
    })

    describe('lookupStudents', () => {
        it('does nothing', async () => {
            const schoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Dave\'s Rhythm Section Schoolyard'])
            const schoolId = schoolResult.rows[0].id
            expect(await schoolQueries.lookupStudents(schoolId)).toHaveLength(0)
        })
    })

    describe('saveNewSchool', () => {
        it('saves login token without path', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const userResult = await db.query({
                text: `insert into users (email, name)
                       values ($1, 'Adam')
                       returning id`,
                values: [email],
            })
            const {id: userId} = userResult.rows[0]
            const school = await schoolQueries.saveNewSchool(userId, 'Original School Name')
            expect(school.id.length).toBe(36)
            expect(school.name).toBe('Original School Name')
            expect(school.created).toBeDefined()
            const schoolResult = await db.query({
                text: `select *
                       from schools
                       where id = $1`,
                values: [school.id],
            })
            expect(schoolResult.rowCount).toBe(1)
            expect(schoolResult.rows[0]).toStrictEqual(school)
            const teacherResult = await db.query({
                text: `select *
                       from teachers
                       where user_id = $1
                         and school_id = $2`,
                values: [userId, school.id],
            })
            expect(teacherResult.rowCount).toBe(1)
            expect(teacherResult.rows[0]).toStrictEqual({
                user_id: userId,
                school_id: school.id,
                admin: true,
            })
        })

        it('closes transaction with rollback on exception', async () => {
            const schoolName = `${randomString(6)} School of ${randomString(6)} Music`
            await expect(() => schoolQueries.saveNewSchool('gibberish', schoolName))
                .rejects
                .toThrowError(/^invalid input syntax for type uuid/)
            const schoolResult = await db.query({
                text: `select *
                       from schools
                       where name = $1`,
                values: [schoolName],
            })
            expect(schoolResult.rowCount).toBe(0)
        })
    })

    describe('isAdminForSchool', () => {
        it('returns true when user is admin for school', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const createUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', [email, 'Boring Tester'])
            const createSchoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Blah Blah Testing Is Boring'])
            const {id: schoolId} = createSchoolResult.rows[0]
            const {id: userId} = createUserResult.rows[0]
            await db.query('insert into teachers (user_id, school_id, admin) values ($1, $2, $3)', [userId, schoolId, true])
            expect(await schoolQueries.isAdminForSchool(userId, schoolId)).toBe(true)
        })

        it('returns false when user is teacher but not an admin for school', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const createUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', [email, 'Boring Tester'])
            const createSchoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Blah Blah Testing Is Boring'])
            const {id: schoolId} = createSchoolResult.rows[0]
            const {id: userId} = createUserResult.rows[0]
            await db.query('insert into teachers (user_id, school_id, admin) values ($1, $2, $3)', [userId, schoolId, false])
            expect(await schoolQueries.isAdminForSchool(userId, schoolId)).toBe(false)
        })

        it('returns false when user is not affiliated with school', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const createUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', [email, 'Boring Tester'])
            const createSchoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Blah Blah Testing Is Boring'])
            const {id: schoolId} = createSchoolResult.rows[0]
            const {id: userId} = createUserResult.rows[0]
            expect(await schoolQueries.isAdminForSchool(userId, schoolId)).toBe(false)
        })

        it('throws exception when school does not exist', async () => {
            const email = `user_${randomString(6)}@eighty4.tech`
            const createUserResult = await db.query('insert into users (email, name) values ($1, $2) returning id', [email, 'Boring Tester'])
            const {id: userId} = createUserResult.rows[0]
            await expect(() => schoolQueries.isAdminForSchool(userId, 'gibberish'))
                .rejects
                .toThrowError(/^invalid input syntax for type uuid/)
        })

        it('throws exception when user does not exist', async () => {
            const createSchoolResult = await db.query('insert into schools (name) values ($1) returning id', ['Blah Blah Testing Is Boring'])
            const {id: schoolId} = createSchoolResult.rows[0]
            await expect(() => schoolQueries.isAdminForSchool('gibberish', schoolId))
                .rejects
                .toThrowError(/^invalid input syntax for type uuid/)
        })
    })
})
