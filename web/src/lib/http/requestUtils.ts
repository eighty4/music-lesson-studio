export function hasJsonContentTypeHeader(request: Request): boolean {
    return request.headers.has('content-type') && request.headers.get('content-type')!.includes('application/json')
}

export function hasJsonContent(request: Request): boolean {
    return hasJsonContentTypeHeader(request) && request.headers.has('content-length')
        && parseInt(request.headers.get('content-length') as string, 10) > 0
}
