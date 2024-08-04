import {expect, type Locator, type Page} from '@playwright/test'

export const activateDevice = (page: Page, deviceToken: string) => attemptDeviceActivation(page, deviceToken, true)

export async function attemptDeviceActivation(page: Page, deviceToken: string, expectActivation?: boolean) {
    await page.goto('/activate')
    await page.waitForURL('/activate')
    await getDeviceTokenInput(page).focus()
    await getDeviceTokenInput(page).pressSequentially(deviceToken)
    await getDeviceTokenInput(page).blur()
    await page.getByRole('button', {name: 'Send device token'}).click()
    if (expectActivation === true) {
        await expect(page.getByText('Enjoy')).toBeVisible()
    }
}

export async function clearDeviceTokenInput(page: Page) {
    await getDeviceTokenInput(page).fill('')
}

function getDeviceTokenInput(page: Page): Locator {
    return page.getByRole('textbox', {name: 'token'})
}
