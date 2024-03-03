import fs from 'node:fs'
import {env} from '$env/dynamic/private'

export const readKey = (keyEnvVar: string): Buffer => {
    const path = env[keyEnvVar]
    if (!path) {
        throw new Error(keyEnvVar + ' env var unset')
    }
    return fs.readFileSync(path)
}
