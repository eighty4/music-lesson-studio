import {readLoginToken} from './data'
import {expect, type Page} from '@playwright/test'

export async function performLogin(page: Page, email: string) {
    await page.waitForURL('**/login')
    expect(new URL(page.url()).pathname).toBe('/login')
    await page.getByRole('textbox', {name: 'email'}).focus()
    await page.getByRole('textbox', {name: 'email'}).pressSequentially(email)
    await page.getByRole('textbox', {name: 'email'}).blur()
    await page.getByRole('button', {name: 'Send login email'}).click()
    await page.waitForURL(`**/login/email-sent/*`)
    expect(new URL(page.url()).pathname).toBe(`/login/email-sent/${email}`)
    await page.getByText(`Email sent to ${email}.`).isVisible()
    const token = await readLoginToken(email)
    await page.goto(`http://localhost:5173/login/verify/${email}/${token}`)
    await page.waitForURL('**/dashboard')
}
