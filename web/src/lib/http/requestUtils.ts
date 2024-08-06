import {redirect} from '@sveltejs/kit'

export function hasJsonContentTypeHeader(request: Request): boolean {
    return request.headers.has('content-type') && request.headers.get('content-type')!.includes('application/json')
}

export function hasJsonContent(request: Request): boolean {
    return hasJsonContentTypeHeader(request) && request.headers.has('content-length')
        && parseInt(request.headers.get('content-length') as string, 10) > 0
}

export function loginRedirect(redirectAfterLogin: URL): never {
    redirect(302, `/login?to=${redirectAfterLogin.pathname}`)
}

interface PageServerLoadParams {
    locals: App.Locals
    url: URL
}

export const redirectUnauthenticatedUser = ({locals: {user}, url}: PageServerLoadParams): never | void => {
    if (!user.authenticated) {
        loginRedirect(url)
    }
}
