import {test} from '@playwright/test'
import {performNewUserLogin} from './login'

test('redirects anonymous user to /login', async ({page}) => {
    await page.goto('/dashboard')
    await page.waitForURL('/login?to=/dashboard')
})

test('redirects user without lessons or classes to /new-user', async ({page}) => {
    await performNewUserLogin(page)
    await page.goto('/dashboard')
    await page.waitForURL('/new-user')
})
