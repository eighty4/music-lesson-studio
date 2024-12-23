import z from 'zod'

export interface School {
    id: string
    name: string
    created: Date
}

const schoolNameValidator = z.string()
    .min(3, 'School name must be at least 3 characters long')
    .max(60, 'School name must be no more than 60 characters long')
    .regex(/^[a-z][a-z0-9'\s]+$/i, 'School name should only have letters and spaces')

export const validateSchoolName = (schoolName: string) => schoolNameValidator.parse(schoolName)
