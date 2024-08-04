import {test} from '@playwright/test'
import {performNewUserLogin} from './login'

test('initiate login sequence', async ({page}) => {
    await performNewUserLogin(page)
})
