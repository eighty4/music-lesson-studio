import {expect, test} from '@playwright/test'
import {attemptDeviceActivation, clearDeviceTokenInput} from './activate'
import {saveDeviceToken} from './data'
import {performNewUserLogin} from './login'

test.describe('/activate', () => {
    test('302', async ({page}) => {
        await page.goto('/activate')
        await page.waitForURL('/login?to=/activate')
    })

    test('input validation', async ({page}) => {
        await performNewUserLogin(page)

        await attemptDeviceActivation(page, 'abc')
        await expect(page.locator('input[name="token"]:invalid')).toBeInViewport()
        await clearDeviceTokenInput(page)

        await attemptDeviceActivation(page, 'abcde!')
        await expect(page.locator('input[name="token"]:invalid')).toBeInViewport()
        await clearDeviceTokenInput(page)

        await attemptDeviceActivation(page, 'abcdefg')
        await expect(page.locator('input[name="token"]:invalid')).toBeInViewport()
        await clearDeviceTokenInput(page)

        await attemptDeviceActivation(page, 'abcdef')
        await expect(page.locator('input[name="token"]:not(invalid)')).toBeInViewport()
    })

    test('error token does not exist in db', async ({page}) => {
        await performNewUserLogin(page)

        await attemptDeviceActivation(page, 'abcdef')
        await expect(page.getByText('bad data')).toBeVisible()
    })

    test('error when device connection closed', async ({page}) => {
        await performNewUserLogin(page)

        const deviceToken = await saveDeviceToken()

        await attemptDeviceActivation(page, deviceToken)
        await expect(page.getByText('bad connection')).toBeVisible()
    })
})
