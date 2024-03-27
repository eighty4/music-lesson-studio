import type {Pool} from 'pg'
import type {School} from './UserTypes'

export default class SchoolQueries {
    constructor(private readonly db: Pool) {
    }

    async saveNewSchool(userId: string, name: string): Promise<School> {
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
                values: [name],
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
            return {id, name, created}
        } catch (e: any) {
            await client.query('rollback')
            console.error(e.message)
            throw e
        } finally {
            client.release()
        }
    }

    async isAdminForSchool(userId: string, schoolId: string): Promise<boolean> {
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
