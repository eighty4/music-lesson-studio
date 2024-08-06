import jwt, {type VerifyOptions} from 'jsonwebtoken'
import type {User} from '$lib/data/UserTypes'
import {readKey} from './authToken'

const publicKey = readKey('TOKEN_PUBLIC_KEY')

const VERIFY_OPTIONS: VerifyOptions = {algorithms: ['ES256']}

interface JwtClaims {
    exp: number
    iat: number
    sub: string
}

export async function verifyAuthToken(token: string | null | undefined): Promise<User['id'] | undefined> {
    if (!token) {
        return undefined
    }
    return new Promise((res, rej) => {
        jwt.verify(token, publicKey, VERIFY_OPTIONS, (err, decoded: any) => {
            decoded = decoded as JwtClaims | undefined
            if (err) {
                rej('error verifying jwt token' + err.message)
            } else if (!decoded) {
                rej('unknown jwt verify state')
            } else {
                res(decoded.sub)
            }
        })
    })
}
