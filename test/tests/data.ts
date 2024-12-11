import pg from 'pg'

function randomString(length: number): string {
    if (typeof length === 'undefined' || isNaN(length)) {
        throw new Error('must provide length')
    }
    const letters = 'abcdefghijklmnopqrstuvwxyz'
    let str = ''
    for (let i = 0; i < length; i++) {
        str += letters.charAt(Math.floor(Math.random() * 26))
    }
    return str
}

export function testUserEmail(): string {
    return `e2e_user_${randomString(6)}@mls.edu`
}

function createDbClient(): pg.Client {
    return new pg.Client({
        host: 'localhost',
        port: 5432,
        database: 'eighty4',
        user: 'eighty4',
        password: 'eighty4',
        options: '-c search_path=music_lesson_studio',
    })
}

export async function readLoginToken(email: string): Promise<string> {
    const db = createDbClient()
    await db.connect()
    try {
        const result = await db.query(`
                    select token
                    from logins
                    where email = $1
                      and verified is null
                      and created > (now() - interval '5 minutes')
                    order by created
                            desc
                    limit 1
            `,
            [email])
        if (result.rowCount !== 1) {
            throw new Error()
        } else {
            return result.rows[0].token
        }
    } finally {
        await db.end()
    }
}

export async function insertLessonPlanRecord(userId: string, name: string): Promise<string> {
    const db = new pg.Client({
        host: 'localhost',
        port: 5432,
        database: 'eighty4',
        user: 'eighty4',
        password: 'eighty4',
        options: '-c search_path=music_lesson_studio',
    })
    await db.connect()
    try {
        const result = await db.query(`
                    insert into lesson_plans (user_id, name)
                    values ($1, $2)
                    returning id
            `,
            [userId, name])
        if (result.rowCount !== 1) {
            throw new Error()
        } else {
            return result.rows[0].id
        }
    } finally {
        await db.end()
    }
}

export async function saveDeviceToken(): Promise<string> {
    const deviceToken = randomString(6)
    const db = createDbClient()
    await db.connect()
    try {
        await db.query('insert into device_activations (token) values ($1)', [deviceToken])
        return deviceToken
    } finally {
        await db.end()
    }
}
