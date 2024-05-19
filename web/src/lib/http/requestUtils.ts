export function hasJsonRequestBody(request: Request): boolean {
    return request.headers.has('content-type')
        && request.headers.has('content-length')
        && request.headers.get('content-type')!.includes('application/json')
        && parseInt(request.headers.get('content-length') as string, 10) > 0
}
