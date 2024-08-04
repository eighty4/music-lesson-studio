import {expect, test} from '@playwright/test'
import {saveDeviceToken, testUserEmail} from './data'
import {performLogin} from './login'
import {attemptDeviceActivation} from './activate'

test.describe('/activate', () => {
    test('302', async ({page}) => {
        await page.goto('/activate')
        await page.waitForURL('/login?to=/activate')
    })

    test('400', async ({page}) => {
        await page.goto('/')
        await page.getByRole('link', {name: 'Login'}).click()
        await performLogin(page, testUserEmail())

        await attemptDeviceActivation(page, 'abc')
        await expect(page.getByText('invalid token')).toBeVisible()
    })

    test('error token does not exist in db', async ({page}) => {
        await page.goto('/')
        await page.getByRole('link', {name: 'Login'}).click()
        await performLogin(page, testUserEmail())

        await attemptDeviceActivation(page, 'abcdef')
        await expect(page.getByText('bad data')).toBeVisible()
    })

    test('error when device connection closed', async ({page}) => {
        await page.goto('/')
        await page.getByRole('link', {name: 'Login'}).click()
        await performLogin(page, testUserEmail())

        const deviceToken = await saveDeviceToken()

        await attemptDeviceActivation(page, deviceToken)
        await expect(page.getByText('bad connection')).toBeVisible()
    })
})
