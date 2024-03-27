export interface School {
    id: string
    name: string
    created: Date
}

export interface User {
    id: string
    email: string
    name: string
    created: Date
}

export function isValidName(name: string): boolean {
    return !!name && name.length > 2
}

export function isValidEmail(email: string): boolean {
    return /.+@.+/.test(email)
}
