import {test} from '@playwright/test'
import {performNewUserLogin} from './login'

test('create a lesson plan', async ({page}) => {
    await performNewUserLogin(page)
    await page.getByRole('link', {name: 'Create a lesson plan'}).click()
    await page.waitForURL('**/create-lesson-plan')
    // await page.getByRole('textbox', {name: 'name'}).click()
    // await page.getByRole('textbox', {name: 'name'}).pressSequentially('Ukulele 101')
    // await page.getByRole('textbox', {name: 'name'}).blur()
    // await page.selectOption('select', {label: 'Ukulele'})
    // await page.getByRole('button', {name: 'Continue'}).click()
    // await page.waitForURL(/^.*\/lesson-plans\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    // const lessonPlanUrl = new URL(page.url())
    // const lessonPlanId = lessonPlanUrl.pathname.substring(lessonPlanUrl.pathname.lastIndexOf('/') + 1)
    // await expect(page.getByText('Ukulele 101')).toBeVisible()
    // await expect(page.getByText('Instrument: ukulele')).toBeVisible()
    // await page.getByRole('link', {name: 'Add lesson unit'}).click()
    // await page.waitForURL(`**/lesson-plans/*/add-unit`)
    // expect(new URL(page.url()).pathname).toBe(`/lesson-plans/${lessonPlanId}/add-unit`)
})
