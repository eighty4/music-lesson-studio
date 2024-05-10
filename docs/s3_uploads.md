# S3 file uploads

Integration docs for uploading files to AWS and Akamai's S3 services.
Supporting both providers increases resiliency and reduces costs.
File upload destination should be tracked in Postgres vs depending on an environment-resolved bucket and file URL.

## Use cases

- User profile images
- School branding images
- Lesson unit screenshot thumbnails
- Lesson unit picture embeds
- Lesson unit video embeds

## Pre-signed upload URLs

Example for creating a pre-signed URL and uploading to Akamai can be seen with [uploadImage.ts](../web/src/routes/(login)/signup/branding/[schoolId]/uploadImage.ts) and [upload-url/+server.ts](../web/src/routes/(login)/signup/branding/[schoolId]/upload-url/+server.ts).

## AWS

[//]: # (todo)

## Akamai

Akamai's API is likely to experience more downtime than AWS, as already experienced during development integration.

### Setup CORS for the Object Storage bucket

```shell
brew install s3cmd
s3cmd --configure
```

[s3cmd --configure instructions](https://www.linode.com/docs/products/storage/object-storage/guides/s3cmd/#configuring-s3cmd)

```shell
s3cmd ls
s3cmd info s3://bucket-name
```

This is the default CORS configuration for a new bucket with CORS enabled:

```xml
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedMethod>DELETE</AllowedMethod>
        <AllowedMethod>HEAD</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

Ideal CORS config for development to replicate an ideal production CORS config:

```xml
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedOrigin>http://localhost:5173</AllowedOrigin>
    </CORSRule>
    <CORSRule>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedOrigin>http://localhost:5173</AllowedOrigin>
    </CORSRule>
</CORSConfiguration>
```
