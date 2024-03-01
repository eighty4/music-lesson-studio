import {test, expect} from '@playwright/test'

test('initiate login sequence', async ({page}) => {
    await page.goto('http://localhost:5173/')
    await page.getByRole('link', {name: 'Login'}).click()
    await page.waitForURL('**/login')
    expect(new URL(page.url()).pathname).toBe('/login')
    await page.getByRole('textbox', {name: 'email'}).fill('asdf@asdf')
    await page.getByRole('button', {name: 'Send login email'}).click()
    await page.waitForURL('**/login/email-sent/asdf@asdf')
    expect(new URL(page.url()).pathname).toBe('/login/email-sent/asdf@asdf')
    await page.getByText('Email sent to asdf@asdf.').isVisible()
})
