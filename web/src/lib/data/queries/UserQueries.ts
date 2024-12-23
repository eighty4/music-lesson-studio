import type {Pool} from 'pg'
import {validateIdentifier} from '$lib/data/CommonTypes'
import {NotFound} from '$lib/data/ErrorTypes'
import {type User, type UserSchools, validateEmail, validateNewFacultyMember} from '$lib/data/UserTypes'

export type FacultyMemberImport = Omit<User, 'id' | 'created'> & { admin: boolean }

export default class UserQueries {
    constructor(private readonly db: Pool) {
    }

    async fetchUserById(userId: User['id']): Promise<User> {
        validateIdentifier(userId)
        const result = await this.db.query({
            name: 'select-user-by-id',
            text: 'select * from users where id = $1',
            values: [userId],
        })
        if (result.rows.length === 0) {
            throw new NotFound(`unable to find user by id ${userId}`)
        } else {
            return {
                id: userId,
                name: result.rows[0].name,
                email: result.rows[0].email,
                created: result.rows[0].created,
            }
        }
    }

    async lookupOrCreateNewUser(email: string): Promise<User> {
        validateEmail(email)
        const select = await this.db.query({
            name: 'select-user',
            text: 'select * from users where email = $1',
            values: [email],
        })
        if (select.rowCount === 1) {
            const {id, name, created} = select.rows[0]
            return {id, email, name, created}
        }
        const insert = await this.db.query({
            name: 'insert-user',
            text: `
                insert into users (email)
                values ($1)
                returning id, created
            `,
            values: [email],
        })
        const {id, created} = insert.rows[0]
        return {id, created, email, name: ''}
    }

    async lookupUserSchools(userId: User['id']): Promise<UserSchools> {
        validateIdentifier(userId)
        const result = await this.db.query({
            name: 'lookup-user-schools',
            text: `
                select s.id, s.name, t.admin
                from schools s
                         join teachers t on s.id = t.school_id
                where t.user_id = $1
                order by s.name
            `,
            values: [userId],
        })
        return {
            teacher: result.rows.map(row => {
                return {
                    id: row['id'],
                    name: row['name'],
                    admin: row['admin'],
                }
            }),
            student: [],
        }
    }

    async saveFacultyMember(schoolId: string, teacher: FacultyMemberImport): Promise<void> {
        validateIdentifier(schoolId)
        validateNewFacultyMember(teacher)
        await this.db.query({
            name: 'save-teacher',
            text: `
                with create_user as (
                    insert into users (email, name) values ($1, $2) returning id)
                insert
                into teachers (user_id, school_id, admin)
                values ((select id from create_user), $3, $4)
            `,
            values: [teacher.email, teacher.name, schoolId, teacher.admin],
        })
    }

    async saveFacultyMembers(schoolId: string, faculty: Array<FacultyMemberImport>): Promise<void> {
        validateIdentifier(schoolId)
        faculty.forEach(validateNewFacultyMember)
        const client = await this.db.connect()
        try {
            await client.query('begin')
            let values: Array<any> = []
            faculty.forEach(person => {
                values.push(person.email, person.name)
            })
            let i = 0
            const result = await client.query({
                text: `
                    insert into users (email, name)
                    values
                    ${faculty.map(person => `($${++i}, $${++i})`).join(', ')}
                    returning id
                `,
                values,
            })
            values = []
            faculty.forEach((person, i) => {
                values.push(result.rows[i].id, schoolId, person.admin)
            })
            i = 0
            await client.query({
                text: `
                    insert into teachers (user_id, school_id, admin)
                    values
                    ${faculty.map(person => `($${++i}, $${++i}, $${++i})`).join(', ')}
                `,
                values,
            })
            await client.query('commit')
        } catch (e: any) {
            await client.query('rollback')
            console.error(e.message)
            throw e
        } finally {
            client.release()
        }
    }
}
