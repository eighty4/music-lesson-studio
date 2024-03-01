import pg from 'pg'
import LoginQueries from '$lib/data/LoginQueries'

const db = new pg.Pool({
    max: 20,
    maxUses: 1000,
})

export const loginQueries = new LoginQueries(db)
