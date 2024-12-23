import type {Pool} from 'pg'
import z from 'zod'
import {BadData} from '$lib/data/ErrorTypes'
import {randomString} from '$lib/data/generate'
import {validateEmail} from '$lib/data/UserTypes'

const tokenValidator = z.string()
    .length(6, 'Verification token should be 6 characters')
    .regex(/^[a-z]{6}$/i, 'Token does not use valid characters')

const loginRedirectPathValidator = z.string()
    .min(1)
    .max(90)
    .regex(/^(\/[a-z0-9\-_]*)+(\?.*)?$/i, 'Not a valid URL path')
    .nullish()

export default class LoginQueries {
    constructor(private readonly db: Pool) {
    }

    async createDeviceToken(): Promise<string> {
        const deviceToken = randomString(6)
        await this.db.query({
            name: 'save-device-token',
            text: `
                insert into device_activations (token)
                values ($1);
            `,
            values: [deviceToken],
        })
        return deviceToken
    }

    async verifyDeviceToken(deviceToken: string): Promise<{ verified: boolean }> {
        try {
            tokenValidator.parse(deviceToken)
        } catch (e) {
            return REJECTED
        }
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

    async createLoginToken(email: string, path?: string): Promise<string> {
        validateEmail(email)
        try {
            loginRedirectPathValidator.parse(path)
        } catch (e: any) {
            console.warn('bad login redirect path', e.message)
            throw new BadData(`save login token for user ${email} with bad login redirect: ${path}`)
        }
        const loginToken = randomString(6)
        await this.db.query({
            name: 'save-login-token',
            text: `
                insert into logins (email, token, path)
                values ($1, $2, $3);
            `,
            values: [email, loginToken, path || null],
        })
        return loginToken
    }

    async verifyLoginToken(email: string, loginToken: string): Promise<{ verified: boolean, path?: string }> {
        try {
            validateEmail(email)
            tokenValidator.parse(loginToken)
        } catch (e) {
            return REJECTED
        }
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
