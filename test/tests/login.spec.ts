import {test} from '@playwright/test'
import {performNewUserLogin} from './login'

test('redirects authed user away from /login', async ({page}) => {
    await performNewUserLogin(page)
    await page.goto('/login')
    await page.waitForURL('/new-user')
})

test('initiate login sequence', async ({page}) => {
    await performNewUserLogin(page)
})
