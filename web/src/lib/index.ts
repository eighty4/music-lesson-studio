export {randomString} from './data/util'
export {createAuthToken} from './token/createAuthToken'
export {verifyAuthToken} from './token/verifyAuthToken'

export const AUTH_TOKEN_NAME = 'mlt-token'

import pg from 'pg'
import LoginQueries from '$lib/data/LoginQueries'
import {env} from '$env/dynamic/private'

const db = new pg.Pool({
    max: 20,
    maxUses: 1000,
    // todo figure out how to make db prop reads consistent between dotenv for vitest and $env for sveltekit
    host: env.PGHOST,
    port: parseInt(env.PGPORT || '5432', 10),
    database: env.PGDATABASE,
    user: env.PGUSER,
    password: env.PGPASSWORD,
})

export const loginQueries = new LoginQueries(db)
