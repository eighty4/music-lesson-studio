import {chromium} from 'playwright'
import {loginForToken} from '../../test/tests/login'

async function createAuthToken() {
    // @ts-ignore
    (await import('playwright-core/lib/server')).installBrowsersForNpmInstall(['chromium'])
    const browser = await chromium.launch({
        headless: true,
        handleSIGTERM: false,
        handleSIGHUP: false,
        handleSIGINT: false,
    })
    const page = await browser.newPage({
        baseURL: 'http://localhost:5173',
    })
    const authToken = await loginForToken(page)
    await page.close()
    await browser.close()
    return authToken
}

createAuthToken().then(console.log)
