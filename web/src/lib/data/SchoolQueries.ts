import type {Pool} from 'pg'
import type {School} from './types'

export default class SchoolQueries {
    constructor(private readonly db: Pool) {
    }

    async saveNewSchool(userId: string, name: string): Promise<School> {
        const client = await this.db.connect()
        try {
            await client.query('begin')
            const result = await this.db.query({
                name: 'save-new-school',
                text: `
                    insert into music_lesson_studio.schools (name)
                    values ($1)
                    returning id, created
                `,
                values: [name],
            })
            const {id, created} = result.rows[0]
            await this.db.query({
                name: 'save-new-admin',
                text: `
                    insert into music_lesson_studio.teachers (user_id, school_id, admin)
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
}
