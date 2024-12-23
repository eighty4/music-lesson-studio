import {type RequestHandler} from '@sveltejs/kit'
import {env} from '$env/dynamic/private'
import {schoolQueries} from '$lib/data/queries'
import {acceptedMimeTypes, extensionForMimeType} from '../uploadImage'

export const POST: RequestHandler = async ({locals: {user}, params, request}) => {
    if (!user.authenticated || !await schoolQueries.isAdminForSchool(user.userId!, params.schoolId!)) {
        return new Response(null, {status: 401})
    }
    if (!request.headers.get('content-type')?.startsWith('application/json')) {
        return new Response(null, {status: 415})
    }
    if (!params.schoolId) {
        return new Response(null, {status: 400})
    }
    const {contentType} = await request.json()
    if (!contentType) {
        return new Response('{contentType} is required', {status: 400})
    }
    if (!acceptedMimeTypes.includes(contentType)) {
        return new Response(`{contentType: '${contentType}'} is not supported`, {status: 400})
    }
    const filename = `logos/${params.schoolId}.${extensionForMimeType(contentType)}`
    console.debug(`/signup/branding/${params.schoolId}/upload-url contentType=${contentType} filename=${filename}`)
    const result = await getPreSignedBucketUploadUrl(contentType, filename)
    console.debug(`/signup/branding/${params.schoolId}/upload-url result=${result}`)
    return new Response(result, {status: 201})
}

// https://www.linode.com/docs/api/object-storage/#object-storage-object-url-create
async function getPreSignedBucketUploadUrl(contentType: string, filename: string): Promise<string> {
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
