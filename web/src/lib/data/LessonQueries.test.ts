import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import LessonQueries from './LessonQueries'
import type {Instrument} from '$lib/data/LessonPlanTypes'

describe('LessonQueries', () => {

    let db: pg.Pool
    let lessonQueries: LessonQueries

    beforeAll(() => {
        db = new pg.Pool()
        lessonQueries = new LessonQueries(db)
    })

    describe('findUserLessonPlans', () => {
        it('returns lesson plans', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3), ($1, $4, $5)',
                [userId, 'Banjo 101', 'banjo', 'Ukulele 201', 'ukulele'],
            )
            const result = await lessonQueries.findUserLessonPlans(userId)
            expect(result).toHaveLength(2)
            expect(result[0].id).toHaveLength(36)
            expect(result[0].userId).toBe(userId)
            expect(result[0].name).toBe('Banjo 101')
            expect(result[0].instrument).toBe('banjo')
            expect(result[0].created).toStrictEqual(result[0].updated)
            expect(result[1].id).toHaveLength(36)
            expect(result[1].userId).toBe(userId)
            expect(result[1].name).toBe('Ukulele 201')
            expect(result[1].instrument).toBe('ukulele')
            expect(result[1].created).toStrictEqual(result[1].updated)
        })
        it('empty array for bunk user id', async () => {
            expect(await lessonQueries.findUserLessonPlans('59d40025-d814-49d8-b367-5858d701111c')).toHaveLength(0)
        })
        it('empty array when none found', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            expect(await lessonQueries.findUserLessonPlans(userId)).toHaveLength(0)
        })
    })

    describe('findUserLessonPlan', () => {
        it('returns lesson plan', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const lessonPlanId = lessonPlanResult.rows[0].id
            const result = await lessonQueries.findUserLessonPlan(lessonPlanId, userId)
            expect(result.id).toBe(lessonPlanId)
            expect(result.userId).toBe(userId)
            expect(result.name).toBe('Guitar 101')
            expect(result.instrument).toBe('guitar')
            expect(result.created).toStrictEqual(result.updated)
        })
        it('throws error when not found', async () => {
            await expect(() => lessonQueries
                .findUserLessonPlan(
                    '59d40025-d814-49d8-b367-5858d701111c',
                    '59d40025-d814-49d8-b367-5858d701111c'))
                .rejects
                .toThrowError('not found lesson plan')
        })
    })

    describe('createLessonPlan', () => {
        it('saves lesson plan', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanId = await lessonQueries.createLessonPlan(userId, 'Emmet Otter\'s Jug Band Christmas', 'banjo')
            const result = await db.query('select * from lesson_plans where id = $1 and user_id = $2', [lessonPlanId, userId])
            expect(result.rowCount).toBe(1)
            expect(result.rows[0].name).toBe('Emmet Otter\'s Jug Band Christmas')
            expect(result.rows[0].instrument).toBe('banjo')
            expect(result.rows[0].created).toStrictEqual(result.rows[0].updated)
        })

        it('rejects bad instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await expect(() => lessonQueries.createLessonPlan(userId, 'Emmet Otter\'s Jug Band Christmas', 'washboard' as Instrument))
                .rejects
                .toThrowError('invalid input value for enum instrument: "washboard"')
        })

        it('rejects bad user id', async () => {
            await expect(() => lessonQueries.createLessonPlan('59d40025-d814-49d8-b367-5858d701111c', 'Emmet Otter\'s Jug Band Christmas', 'banjo'))
                .rejects
                .toThrowError(/lesson_plans_user_id_fkey/)
        })
    })
})
