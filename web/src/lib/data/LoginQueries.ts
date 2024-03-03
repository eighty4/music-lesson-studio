import type {Pool} from 'pg'

export default class LoginQueries {
    constructor(private readonly db: Pool) {
    }

    async saveLoginToken(email: string, loginToken: string, path?: string): Promise<void> {
        await this.db.query({
            name: 'save-login-token',
            text: `
                insert into logins (email, token, path)
                values ($1, $2, $3);
            `,
            values: [email, loginToken, path || null],
        })
    }

    async verifyLoginToken(email: string, loginToken: string): Promise<{ verified: boolean, path?: string }> {
        const result = await this.db.query({
            name: 'verify-login-token',
            text: `
                update logins l
                set verified = now()
                where l.email = $1
                  and l.token = $2
                  and l.verified is null
                  and l.created > (now() - interval '5 minutes')
                  and l.token = (select ll.token
                                 from logins ll
                                 where ll.email = l.email
                                 order by ll.created desc
                                 limit 1)
                returning l.path
            `,
            values: [email, loginToken],
        })
        if (result.rowCount === 1) {
            if (result.rows[0].path) {
                return {verified: true, path: result.rows[0].path}
            } else {
                return VERIFIED
            }
        } else {
            return REJECTED
        }
    }
}

const VERIFIED = {verified: true}
const REJECTED = {verified: false}
