import {expect, test} from '@playwright/test'
import {performLogin} from './login'
import {testUserEmail} from './data'
import {SignupPages} from './signup.pages'

test('sign up new school, skip extra steps, land on school page', async ({page}) => {
    await page.goto('http://localhost:5173/')
    await page.getByRole('link', {name: 'Create a program'}).click()
    await performLogin(page, testUserEmail(), '/signup')
    const schoolId = await new SignupPages(page).signupNewSchool('EHS')
    expect(new URL(page.url()).pathname).toBe('/signup/branding/' + schoolId)
    await page.getByRole('link', {name: 'Skip this step'}).click()
    await page.waitForURL('**/signup/faculty/' + schoolId)
    await page.getByRole('link', {name: 'Skip this step'}).click()
    await page.waitForURL('**/signup/courses/' + schoolId)
    await page.getByRole('button', {name: 'Continue'}).click()
    await page.waitForURL('**/school/' + schoolId)
})
