import {readLoginToken, testUserEmail} from './data'
import {expect, type Page} from '@playwright/test'

const getCurrentAuthToken = async (page: Page): Promise<string> => (await page.context().cookies()).find((c) => c.name === 'mls-token')?.value

export async function loginForToken(page: Page): Promise<string> {
    await page.goto('/login')
    await performLogin(page, testUserEmail())
    return await getCurrentAuthToken(page)
}

export async function performLogin(page: Page, email: string, expectRedirect: string | null = null) {
    await page.waitForURL(expectRedirect ? `**/login?to=${expectRedirect}` : '**/login')
    const loginUrl = new URL(page.url())
    expect(loginUrl.pathname).toBe('/login')
    expect(loginUrl.searchParams.get('to')).toBe(expectRedirect)
    await page.getByRole('textbox', {name: 'email'}).focus()
    await page.getByRole('textbox', {name: 'email'}).pressSequentially(email)
    await page.getByRole('textbox', {name: 'email'}).blur()
    await page.getByRole('button', {name: 'Send login email'}).click()
    await page.waitForURL('**/login/email-sent/*')
    expect(new URL(page.url()).pathname).toBe(`/login/email-sent/${email}`)
    await page.getByText(`Email sent to ${email}.`).isVisible()
    const token = await readLoginToken(email)
    await page.goto(`/login/verify/${email}/${token}`)
    await page.waitForURL(`**${expectRedirect ?? '/dashboard'}`)
}
