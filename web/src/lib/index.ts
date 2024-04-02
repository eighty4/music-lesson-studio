import pg from 'pg'
import LessonQueries from '$lib/data/LessonQueries'
import LoginQueries from '$lib/data/LoginQueries'
import SchoolQueries from '$lib/data/SchoolQueries'
import UserQueries from '$lib/data/UserQueries'
import {env} from '$env/dynamic/private'

export {randomString} from './data/util'
export {AUTH_TOKEN_NAME} from './token/authToken'
export {createAuthToken} from './token/createAuthToken'
export {redirectRejectedToken} from './token/redirectRejectedToken'
export {redirectVerifiedToken} from './token/redirectVerifiedToken'
export {verifyAuthToken} from './token/verifyAuthToken'

const db = new pg.Pool({
    max: 20,
    maxUses: 1000,
    // todo figure out how to make db prop reads consistent between dotenv for vitest and $env for sveltekit
    host: env.PGHOST,
    port: parseInt(env.PGPORT || '5432', 10),
    database: env.PGDATABASE,
    user: env.PGUSER,
    password: env.PGPASSWORD,
    options: env.PGOPTIONS,
})

export const lessonQueries = new LessonQueries(db)

export const loginQueries = new LoginQueries(db)

export const schoolQueries = new SchoolQueries(db)

export const userQueries = new UserQueries(db)
