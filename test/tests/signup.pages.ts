import type {Page} from '@playwright/test'

type SchoolId = string

export class SignupPages {
    constructor(private readonly page: Page) {
    }

    async signupNewSchool(schoolName: string): Promise<SchoolId> {
        await this.page.waitForURL('**/signup')
        await this.page.getByRole('textbox', {name: 'name'}).click()
        await this.page.getByRole('textbox', {name: 'name'}).pressSequentially(schoolName)
        await this.page.getByRole('textbox', {name: 'name'}).blur()
        await this.page.getByRole('button', {name: 'Continue'}).click()
        await this.page.waitForURL('**/signup/branding/*')
        const pathname = new URL(this.page.url()).pathname
        return pathname.substring(pathname.lastIndexOf('/') + 1)
    }
}
