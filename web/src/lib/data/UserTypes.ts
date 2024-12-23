import z from 'zod'
import type {School} from './SchoolTypes'

export interface UserSchools {
    teacher: Array<Omit<School, 'created'> & { admin: boolean }>
    student: Array<School>
}

const personNameValidator = z.string()
    .min(2, 'Name must be at least 2 characters long')
    .max(35, 'Name must be no more than 35 characters')
    .regex(/^[a-z][a-z0-9'\s\-]+$/i, 'Name should only use letters and spaces')

export function validatePersonName(name: string) {
    personNameValidator.parse(name)
}

const emailValidator = z.string()
    .min(3, 'Your email couldn\'t possibly be les than 3 characters')
    .max(320, 'Email cannot exceed 320 characters')
    .email('Email is not a valid address')

export function validateEmail(email: string) {
    emailValidator.parse(email)
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

const newFacultyValidator = z.object({
    email: emailValidator,
    name: personNameValidator.nullish(),
    admin: z.boolean(),
}).strict()

export function validateNewFacultyMember(facultyMember: Omit<User, 'id' | 'created'> & { admin: boolean }) {
    newFacultyValidator.parse(facultyMember)
}
