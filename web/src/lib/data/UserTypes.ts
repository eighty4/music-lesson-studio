export interface School {
    id: string
    name: string
    created: Date
}

export interface UserSchools {
    teacher: Array<Omit<School, 'created'> & { admin: boolean }>
    student: Array<School>
}

export interface User {
    id: string
    email: string
    name: string
    created: Date
}

export interface SchoolFaculty extends User {
    admin: boolean
}

export function isValidName(name: string): boolean {
    return isString(name) && name.length > 2
}

export function isValidEmail(email: string): boolean {
    return isString(email) && /.+@.+/.test(email)
}

function isString(s: any): boolean {
    switch (typeof s) {
        case 'string':
            return true
        case 'object':
            return s !== null && s.constructor.toString().startsWith('function String')
        default:
            return false
    }
}
