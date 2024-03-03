import type {Pool} from 'pg'
import type {User} from './types'

export default class UserQueries {
    constructor(private readonly db: Pool) {
    }

    async lookupOrCreateNewUser(email: string): Promise<User> {
        const select = await this.db.query({
            name: 'select-user',
            text: `
                select *
                from users
                where email = $1
            `,
            values: [email],
        })
        if (select.rowCount === 1) {
            const {id, name, created} = select.rows[0]
            return {id, email, name, created}
        }
        const insert = await this.db.query({
            name: 'insert-user',
            text: `
                insert into users (email, name)
                values ($1, $2)
                returning id, created
            `,
            values: [email, ''],
        })
        const {id, created} = insert.rows[0]
        return {id, created, email, name: ''}
    }
}
