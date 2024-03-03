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
    })
})
