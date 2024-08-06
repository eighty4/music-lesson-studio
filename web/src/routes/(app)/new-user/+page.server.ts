import type {PageServerLoad} from './$types'
import {redirectUnauthenticatedUser} from '$lib/http/requestUtils'

export const load: PageServerLoad = redirectUnauthenticatedUser
