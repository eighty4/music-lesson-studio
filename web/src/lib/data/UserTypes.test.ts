import {describe, expect, it} from 'vitest'
import {isValidEmail, isValidName} from './UserTypes'

describe('UserTypes', () => {
    describe('isValidName', () => {
        it('validates name', () => {
            expect(isValidName('abc')).toBeTruthy()
            expect(isValidName('ab')).toBeFalsy()
            expect(isValidName(3 as any)).toBeFalsy()
            expect(isValidName(undefined as any)).toBeFalsy()
            expect(isValidName(null as any)).toBeFalsy()
        })
    })
    describe('isValidEmail', () => {
        it('validates email', () => {
            expect(isValidEmail('lindsay@eagleton.gov')).toBeTruthy()
            expect(isValidEmail('lindsay@')).toBeFalsy()
            expect(isValidEmail('@eagleton.gov')).toBeFalsy()
            expect(isValidEmail('Television')).toBeFalsy()
            expect(isValidEmail('')).toBeFalsy()
            expect(isValidEmail(3 as any)).toBeFalsy()
            expect(isValidEmail(undefined as any)).toBeFalsy()
            expect(isValidEmail(null as any)).toBeFalsy()
        })
    })
})