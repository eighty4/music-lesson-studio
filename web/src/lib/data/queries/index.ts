import pg from 'pg'
import {env} from '$env/dynamic/private'
import LessonQueries from './LessonQueries'
import LoginQueries from './LoginQueries'
import SchoolQueries from './SchoolQueries'
import UserQueries from './UserQueries'

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
