import z from 'zod'
import {BadData} from './ErrorTypes'

const uuidValidator = z.string().uuid()

// map validation on UUIDs to BadData to send 500 status to client
export function validateIdentifier(uuid: string) {
    try {
        uuidValidator.parse(uuid)
    } catch (e: any) {
        throw new BadData(`bad data: expected ${uuid} to be a uuid`)
    }
}
