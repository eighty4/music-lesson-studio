import type {PageServerLoad} from './$types'

export interface LandingPageData {
    authenticated: boolean
}

export const load: PageServerLoad = async ({locals: {user: {authenticated}}}): Promise<LandingPageData> => {
    return {authenticated}
}
