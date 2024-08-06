import {expect, type Page} from '@playwright/test'
import {readLoginToken, testUserEmail} from './data'

const getCurrentAuthToken = async (page: Page): Promise<string> => (await page.context().cookies()).find((c) => c.name === 'mls-token')!.value

export async function loginForToken(page: Page): Promise<string> {
    await performNewUserLogin(page)
    return await getCurrentAuthToken(page)
}

export async function performNewUserLogin(page: Page): Promise<string> {
    await page.goto('/')
    await page.getByRole('link', {name: 'Sign in'}).click()
    const email = testUserEmail()
    await performLogin(page, email, {expectNewUser: true})
    return email
}

export interface LoginOpts {
    expectLoginRedirect?: string
    expectNewUser?: boolean
}

export async function performLogin(page: Page, email: string, opts?: LoginOpts) {
    await page.waitForURL(opts?.expectLoginRedirect ? `**/login?to=${opts.expectLoginRedirect}` : '**/login')
    const loginUrl = new URL(page.url())
    expect(loginUrl.pathname).toBe('/login')
    expect(loginUrl.searchParams.get('to')).toBe(opts?.expectLoginRedirect ?? null)
    await page.getByRole('textbox', {name: 'email'}).focus()
    await page.getByRole('textbox', {name: 'email'}).pressSequentially(email)
    await page.getByRole('textbox', {name: 'email'}).blur()
    await page.getByRole('button', {name: 'Send login email'}).click()
    await page.waitForURL('**/login/email-sent/*')
    expect(new URL(page.url()).pathname).toBe(`/login/email-sent/${email}`)
    await expect(page.getByText(`Email sent to ${email}`)).toBeVisible()
    const token = await readLoginToken(email)
    await page.goto(`/login/verify/${email}/${token}`)
    if (opts?.expectLoginRedirect) {
        await page.waitForURL(`**${opts.expectLoginRedirect}`)
    } else if (opts?.expectNewUser) {
        await page.waitForURL('/new-user')
    } else {
        await page.waitForURL('/dashboard')
    }
}

export async function logoutSession(page: Page): Promise<void> {
    await page.goto('/')
    await page.getByRole('button', {name: 'Logout'}).click()
    await page.waitForURL('/')
    await expect(page.getByRole('link', {name: 'Sign in'})).toBeVisible()
}
