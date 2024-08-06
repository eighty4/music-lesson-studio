// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
export const acceptedMimeTypes = Object.freeze(['image/jpeg', 'image/png', 'image/webp'])

export function extensionForMimeType(contentType: string): string {
    if (contentType === 'image/jpeg') {
        return 'jpg'
    } else if (contentType === 'image/png') {
        return 'png'
    } else if (contentType === 'image/webp') {
        return 'webp'
    } else {
        throw new Error(`what is ${contentType}`)
    }
}

export async function uploadImageFile(schoolId: string, file: File, progressCb: (p: number) => void): Promise<void> {
    const s3UploadUrl = await getS3UploadUrl(schoolId, file.type)
    await xhrUpload(s3UploadUrl, file, progressCb)
}

async function getS3UploadUrl(schoolId: string, contentType: string): Promise<string> {
    const response = await fetch(`/signup/branding/${schoolId}/upload-url`, {
        body: JSON.stringify({contentType}),
        headers: {'content-type': 'application/json'},
        method: 'POST'
    })
    if (response.status === 201) {
        return await response.text()
    } else {
        throw new Error(`getS3UploadUrl http response status ${response.status}`)
    }
}

function xhrUpload(url: string, file: File, progressCb: (p: number) => void): Promise<void> {
    return new Promise((res, rej) => {
        const xhr = new XMLHttpRequest()
        xhr.upload.onprogress = (e) => progressCb(e.loaded / e.total)
        xhr.upload.onerror = () => rej('xhr upload errored')
        xhr.upload.onabort = () => rej('xhr upload aborted')
        xhr.onload = () => {
            if (xhr.status === 200) {
                res()
            } else {
                rej('invalid xhr load status: ' + xhr.status)
            }
        }
        xhr.open('PUT', url, true)
        xhr.setRequestHeader('content-type', file.type)
        try {
            xhr.send(file)
        } catch (e: any) {
            rej('upload xhr exception' + e.message)
        }
    })
}
