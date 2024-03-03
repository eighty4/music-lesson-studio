import jwt, {type SignOptions} from 'jsonwebtoken'
import type {User} from '$lib/data/types'
import {readKey} from './readKey'

const privateKey = readKey('TOKEN_PRIVATE_KEY')

const SIGN_OPTS: SignOptions = {expiresIn: '1 week', algorithm: 'ES256'}

interface JwtClaims {
    sub: string
}

export async function createAuthToken(user: User): Promise<string> {
    return new Promise((res, rej) => {
        jwt.sign({sub: user.id} as JwtClaims, privateKey, SIGN_OPTS, (err, token) => {
            if (err) {
                rej(err)
            } else {
                res(token!)
            }
        })
    })
}
