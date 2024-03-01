import type {Pool} from 'pg'

export default class LoginQueries {
    constructor(private readonly db: Pool) {}

    async saveLoginToken(email: string, loginToken: string): Promise<void> {

    }

    async verifyLoginToken(email: string, loginToken: string): Promise<void> {

    }
}
