import type {Page} from '@playwright/test'

type SchoolId = string

export async function signupNewSchool(page: Page, schoolName: string): Promise<SchoolId> {
    await page.waitForURL('**/signup')
    await page.getByRole('textbox', {name: 'name'}).click()
    await page.getByRole('textbox', {name: 'name'}).pressSequentially(schoolName)
    await page.getByRole('textbox', {name: 'name'}).blur()
    await page.getByRole('button', {name: 'Continue'}).click()
    await page.waitForURL('**/signup/branding/*')
    const pathname = new URL(page.url()).pathname
    return pathname.substring(pathname.lastIndexOf('/') + 1)
}

export async function addFacultyMember(page: Page, name: string, email: string, admin?: boolean): Promise<void> {
    await page.waitForURL('**/signup/faculty/*')
    await page.getByRole('textbox', {name: 'name'}).click()
    await page.getByRole('textbox', {name: 'name'}).pressSequentially(name)
    await page.getByRole('textbox', {name: 'name'}).blur()
    await page.getByRole('textbox', {name: 'email'}).click()
    await page.getByRole('textbox', {name: 'email'}).pressSequentially(email)
    await page.getByRole('textbox', {name: 'email'}).blur()
    if (admin) {
        await page.getByRole('checkbox', {name: 'admin'}).click()
    }
    if (new URL(page.url()).searchParams.has('added')) {
        await page.getByRole('button', {name: 'Invite another'}).click()
    } else {
        await page.getByRole('button', {name: 'Send invite'}).click()
    }
    await page.waitForURL(`**/signup/faculty/*?added=${encodeURIComponent(name)}`)
    await page.getByText(`Invite email sent to ${email}.`).isVisible()
}
