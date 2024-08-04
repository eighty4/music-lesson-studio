import {expect, test} from '@playwright/test'
import {testUserEmail} from './data'
import {performLogin} from './login'
import {addFacultyMember, signupNewSchool} from './signup'

test('sign up new school, skip extra steps, land on school page', async ({page}) => {
    await page.goto('/')
    await page.getByRole('link', {name: 'Create a school program'}).click()
    await performLogin(page, testUserEmail(), {expectLoginRedirect: '/signup', expectNewUser: true})
    const schoolId = await signupNewSchool(page, 'EHS')
    expect(new URL(page.url()).pathname).toBe('/signup/branding/' + schoolId)
    await page.getByRole('link', {name: 'Skip this step'}).click()
    await page.waitForURL('**/signup/faculty/' + schoolId)
    await page.getByRole('link', {name: 'Skip this step'}).click()
    await page.waitForURL('**/signup/courses/' + schoolId)
    await page.getByRole('button', {name: 'Continue'}).click()
    await page.waitForURL('**/school/' + schoolId)
})

test('sign up new school, add faculty', async ({page}) => {
    await page.goto('/')
    await page.getByRole('link', {name: 'Create a school program'}).click()
    const userEmail = testUserEmail()
    await performLogin(page, userEmail, {expectLoginRedirect: '/signup', expectNewUser: true})
    const schoolId = await signupNewSchool(page, 'EHS')
    expect(new URL(page.url()).pathname).toBe('/signup/branding/' + schoolId)
    await page.getByRole('link', {name: 'Skip this step'}).click()
    await page.waitForURL('**/signup/faculty/' + schoolId)

    const adminEmail = testUserEmail()
    const adminName = 'Tony Bennett'
    await addFacultyMember(page, adminName, adminEmail, true)
    const teacherEmail = testUserEmail()
    const teacherName = 'David Lee Roth'
    await addFacultyMember(page, teacherName, teacherEmail)

    await page.getByRole('link', {name: 'Continue'}).click()
    await page.waitForURL('**/signup/courses/' + schoolId)
    await page.getByRole('button', {name: 'Continue'}).click()
    await page.waitForURL('**/school/' + schoolId)

    await page.getByRole('link', {name: 'Teachers'}).click()
    await page.waitForURL(`**/school/${schoolId}/teachers`)

    const teachers = await page.locator('.teacher').all()
    expect(await teachers[0].locator('.name').textContent()).toBe('')
    expect(await teachers[0].locator('.email').textContent()).toBe(userEmail)
    expect(await teachers[0].locator('.role').textContent()).toBe('teacher+')
    expect(await teachers[1].locator('.name').textContent()).toBe('David Lee Roth')
    expect(await teachers[1].locator('.email').textContent()).toBe(teacherEmail)
    expect(await teachers[1].locator('.role').textContent()).toBe('teacher')
    expect(await teachers[2].locator('.name').textContent()).toBe('Tony Bennett')
    expect(await teachers[2].locator('.email').textContent()).toBe(adminEmail)
    expect(await teachers[2].locator('.role').textContent()).toBe('teacher+')
})
