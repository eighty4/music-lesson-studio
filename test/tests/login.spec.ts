import {test} from '@playwright/test'
import {testUserEmail} from './data'
import {performLogin} from './login'

test('initiate login sequence', async ({page}) => {
    await page.goto('/')
    await page.getByRole('link', {name: 'Login'}).click()
    await performLogin(page, testUserEmail())
})
