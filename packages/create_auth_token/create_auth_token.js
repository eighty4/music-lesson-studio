// todo remove all the duplication from //test which is not ideal but it's 2024 and TypeScript is still a PITA

import {chromium} from 'playwright'
import pg from 'pg'

async function createAuthToken() {
    // @ts-ignore
    (await import('playwright-core/lib/server')).installBrowsersForNpmInstall(['chromium'])
    const browser = await chromium.launch({
        headless: true,
        handleSIGTERM: false,
        handleSIGHUP: false,
        handleSIGINT: false,
    })
    const page = await browser.newPage({
        baseURL: 'http://localhost:5173',
    })
    const authToken = await loginForToken(page)
    await page.close()
    await browser.close()
    return authToken
}

createAuthToken().then(console.log)

function randomString(length) {
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

export function testUserEmail() {
    return `e2e_user_${randomString(6)}@mls.edu`
}

const getCurrentAuthToken = async (page) => (await page.context().cookies()).find((c) => c.name === 'mls-token')?.value

export async function loginForToken(page) {
    await page.goto('/login')
    await performLogin(page, testUserEmail())
    return await getCurrentAuthToken(page)
}

export async function performLogin(page, email) {
    await page.waitForURL('**/login')
    await page.getByRole('textbox', {name: 'email'}).focus()
    await page.getByRole('textbox', {name: 'email'}).pressSequentially(email)
    await page.getByRole('textbox', {name: 'email'}).blur()
    await page.getByRole('button', {name: 'Send login email'}).click()
    await page.waitForURL('**/login/email-sent/*')
    await page.getByText(`Email sent to ${email}.`).isVisible()
    const token = await readLoginToken(email)
    await page.goto(`/login/verify/${email}/${token}`)
    await page.waitForURL('**/dashboard')
}

async function readLoginToken(email) {
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
