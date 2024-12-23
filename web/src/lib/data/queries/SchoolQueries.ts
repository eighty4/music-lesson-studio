import type {Pool} from 'pg'
import {validateIdentifier} from '$lib/data/CommonTypes'
import {NotFound} from '$lib/data/ErrorTypes'
import type {SchoolFaculty, User} from '$lib/data/UserTypes'
import {type School, validateSchoolName} from '$lib/data/SchoolTypes'

export default class SchoolQueries {
    constructor(private readonly db: Pool) {
    }

    async lookupSchoolName(schoolId: string): Promise<string> {
        validateIdentifier(schoolId)
        const result = await this.db.query({
            name: 'lookup-school-name',
            text: `
                select name
                from schools
                where id = $1
            `,
            values: [schoolId],
        })
        if (result.rowCount !== 1) {
            throw new NotFound(`school ${schoolId} not found`)
        } else {
            return result.rows[0].name
        }
    }

    async lookupFaculty(schoolId: string): Promise<Array<SchoolFaculty>> {
        validateIdentifier(schoolId)
        const result = await this.db.query({
            name: 'lookup-school-faculty',
            text: `
                select t.user_id, u.name, u.email, u.created, t.admin
                from users u
                         join teachers t on u.id = t.user_id
                where t.school_id = $1
                order by u.name
            `,
            values: [schoolId],
        })
        return result.rows.map(row => {
            return {
                id: row['user_id'],
                name: row['name'],
                email: row['email'],
                created: row['created'],
                admin: row['admin'],
            }
        })
    }

    async lookupStudents(schoolId: string): Promise<Array<User>> {
        validateIdentifier(schoolId)
        return Promise.resolve([])
    }

    async createNewSchool(userId: string, schoolName: string): Promise<School> {
        validateIdentifier(userId)
        validateSchoolName(schoolName)
        const client = await this.db.connect()
        try {
            await client.query('begin')
            const result = await client.query({
                name: 'save-new-school',
                text: `
                    insert into schools (name)
                    values ($1)
                    returning id, created
                `,
                values: [schoolName],
            })
            const {id, created} = result.rows[0]
            await client.query({
                name: 'save-new-admin',
                text: `
                    insert into teachers (user_id, school_id, admin)
                    values ($1, $2, $3)
                `,
                values: [userId, id, true],
            })
            await client.query('commit')
            return {id, name: schoolName, created}
        } catch (e: any) {
            await client.query('rollback')
            console.error(e.message)
            throw e
        } finally {
            client.release()
        }
    }

    async isAdminForSchool(userId: string, schoolId: string): Promise<boolean> {
        validateIdentifier(userId)
        validateIdentifier(schoolId)
        const result = await this.db.query({
            name: 'check-user-admin',
            text: `
                select admin
                from teachers
                where school_id = $1
                  and user_id = $2
            `,
            values: [schoolId, userId],
        })
        if (result.rowCount === 0) {
            return false
        } else {
            return result.rows[0].admin
        }
    }
}
