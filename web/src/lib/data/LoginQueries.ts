import type {Pool} from 'pg'

export default class LoginQueries {
    constructor(private readonly db: Pool) {
    }

    async saveDeviceToken(deviceToken: string): Promise<void> {
        await this.db.query({
            name: 'save-device-token',
            text: `
                insert into device_activations (token)
                values ($1);
            `,
            values: [deviceToken],
        })
    }

    async verifyDeviceToken(deviceToken: string): Promise<{verified: boolean}> {
        const result = await this.db.query({
            name: 'verify-device-token',
            text: `
                update device_activations d
                set verified = now()
                where d.token = $1
                  and d.verified is null
                  and d.created > (now() - interval '5 minutes')
            `,
            values: [deviceToken],
        })
        if (result.rowCount === 1) {
            return VERIFIED
        } else {
            return REJECTED
        }
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
