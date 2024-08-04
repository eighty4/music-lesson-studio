import {expect, type Page} from '@playwright/test'

export const activateDevice = (page: Page, deviceToken: string) => attemptDeviceActivation(page, deviceToken, true)

export async function attemptDeviceActivation(page: Page, deviceToken: string, expectActivation?: boolean) {
    await page.goto('/activate')
    await page.waitForURL('/activate')
    await page.getByRole('textbox', {name: 'token'}).focus()
    await page.getByRole('textbox', {name: 'token'}).pressSequentially(deviceToken)
    await page.getByRole('textbox', {name: 'token'}).blur()
    await page.getByRole('button', {name: 'Send device token'}).click()
    if (expectActivation === true) {
        await expect(page.getByText('Enjoy')).toBeVisible()
    }
}
