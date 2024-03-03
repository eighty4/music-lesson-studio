import type {RequestHandler} from '@sveltejs/kit'
import {env} from '$env/dynamic/private'
import {AUTH_TOKEN_NAME, verifyAuthToken} from '$lib'

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
const contentTypes: Record<string, string> = {
    png: 'image/png',
    jpeg: 'image/jpeg',
    webp: 'image/webp',
}

export const GET: RequestHandler = async ({cookies, params, url, request}) => {
    try {
        const user = verifyAuthToken(cookies.get(AUTH_TOKEN_NAME))
        // todo verify user is admin for school id
    } catch (e) {
        return new Response(null, {status: 401})
    }
    if (!params.schoolId || !params.extension) {
        return new Response(null, {status: 400})
    }
    const contentType = contentTypes[params.extension]
    if (!contentType) {
        return new Response(null, {status: 400})
    }
    const filename = `${params.schoolId}.${params.extension}`
    return new Response(await getPreSignedBucketUploadUrl(contentType, filename))
}

// https://www.linode.com/docs/api/object-storage/#object-storage-object-url-create
async function getPreSignedBucketUploadUrl(filename: string, contentType: string): Promise<string> {
    const url = `https://api.linode.com/v4/object-storage/buckets/${env.S3_REGION}/${env.S3_BUCKET}/object-url`
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer ' + env.S3_API_TOKEN,
        },
        body: JSON.stringify({
            content_type: contentType,
            expires_in: 360,
            method: 'PUT',
            name: filename,
        }),
    })
    if (response.status === 200) {
        const {url} = await response.json()
        return url
    } else {
        throw new Error('ObjectStorage object error with response ' + response.status + ': ' + (await response.text()))
    }
}
