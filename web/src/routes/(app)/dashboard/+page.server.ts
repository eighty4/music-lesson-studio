import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({params, request}) => {
    if (!request.headers.get('Cookie')) {
        console.log('redirecting /dashboard to /login')
        redirect(301, '/login')
    }
    return Promise.resolve()
}
