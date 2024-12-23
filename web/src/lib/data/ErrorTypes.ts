export {ZodError} from 'zod'

export class BadData {
    constructor(readonly message: string) {
    }
}

export class NotFound {
    constructor(readonly message: string) {
    }
}
