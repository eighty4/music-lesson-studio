import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import LessonQueries from './LessonQueries'
import type {Instrument, LessonFrame} from '$lib/data/LessonPlanTypes'

const BAD_UUID = '59d40025-d814-49d8-b367-5858d701111c'

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
            expect(result[0].user.id).toBe(userId)
            expect(result[0].name).toBe('Banjo 101')
            expect(result[0].instrument).toBe('banjo')
            expect(result[0].created).toStrictEqual(result[0].updated)
            expect(result[1].id).toHaveLength(36)
            expect(result[1].user.id).toBe(userId)
            expect(result[1].name).toBe('Ukulele 201')
            expect(result[1].instrument).toBe('ukulele')
            expect(result[1].created).toStrictEqual(result[1].updated)
        })
        it('empty array for bunk user id', async () => {
            expect(await lessonQueries.findUserLessonPlans(BAD_UUID)).toHaveLength(0)
        })
        it('empty array when none found', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            expect(await lessonQueries.findUserLessonPlans(userId)).toHaveLength(0)
        })
        it('with null name and instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await db.query(
                'insert into lesson_plans (user_id) values ($1)',
                [userId],
            )
            const result = await lessonQueries.findUserLessonPlans(userId)
            expect(result).toHaveLength(1)
            expect(result[0].id).toHaveLength(36)
            expect(result[0].user.id).toBe(userId)
            expect(result[0].name).toBe(null)
            expect(result[0].instrument).toBe(null)
            expect(result[0].created).toStrictEqual(result[0].updated)
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
            expect(result.user.id).toBe(userId)
            expect(result.name).toBe('Guitar 101')
            expect(result.instrument).toBe('guitar')
            expect(result.created).toStrictEqual(result.updated)
        })
        it('throws error when not found', async () => {
            await expect(() => lessonQueries
                .findUserLessonPlan(BAD_UUID, BAD_UUID))
                .rejects
                .toThrowError('not found lesson plan')
        })
        it('errors with mismatch user id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const planId = lessonPlanResult.rows[0].id
            await expect(() => lessonQueries.findUserLessonPlan(BAD_UUID, planId))
                .rejects
                .toThrowError('not found lesson plan')
        })
        it('with null name and instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id) values ($1) returning id',
                [userId],
            )
            const planId = lessonPlanResult.rows[0].id
            const result = await lessonQueries.findUserLessonPlan(planId, userId)
            expect(result.id).toHaveLength(36)
            expect(result.user.id).toBe(userId)
            expect(result.name).toBe(null)
            expect(result.instrument).toBe(null)
            expect(result.created).toStrictEqual(result.updated)
        })
    })

    describe('findUserLessonUnit', () => {
        it('returns lesson unit', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const planId = lessonPlanResult.rows[0].id
            const lessonUnitResult = await db.query(
                'insert into lesson_units (lesson_plan_id, name, instrument, entities) values ($1, $2, $3, $4) returning id',
                [planId, 'Chromatic Scale', 'banjo', '[]'],
            )
            const unitId = lessonUnitResult.rows[0].id
            const result = await lessonQueries.findUserLessonUnit(userId, planId, unitId)
            expect(result.id).toBe(unitId)
            expect(result.plan.id).toBe(planId)
            expect(result.plan.name).toBe('Guitar 101')
            expect(result.user.id).toBe(userId)
            expect(result.name).toBe('Chromatic Scale')
            expect(result.instrument).toBe('banjo')
            expect(result.created).toStrictEqual(result.updated)
        })
        it('does not match with different user or plan id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const planId = lessonPlanResult.rows[0].id
            const lessonUnitResult = await db.query(
                'insert into lesson_units (lesson_plan_id, name, instrument, entities) values ($1, $2, $3, $4) returning id',
                [planId, 'Chromatic Scale', 'banjo', '{}'],
            )
            const unitId = lessonUnitResult.rows[0].id
            await expect(() => lessonQueries.findUserLessonUnit(userId, BAD_UUID, unitId))
                .rejects
                .toThrowError('not found')
            await expect(() => lessonQueries.findUserLessonUnit(BAD_UUID, planId, unitId))
                .rejects
                .toThrowError('not found')
        })
    })

    describe('createLessonPlan', () => {
        it('saves lesson plan', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Emmet Otter\'s Jug Band Christmas',
                instrument: 'banjo',
            })
            const result = await db.query('select * from lesson_plans where id = $1 and user_id = $2', [lessonPlan.id, userId])
            expect(result.rowCount).toBe(1)
            expect(result.rows[0].name).toBe('Emmet Otter\'s Jug Band Christmas')
            expect(result.rows[0].instrument).toBe('banjo')
            expect(result.rows[0].created).toStrictEqual(result.rows[0].updated)
        })

        it('save with null instrument and name', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({user: {id: userId}})
            const result = await db.query('select * from lesson_plans where id = $1 and user_id = $2', [lessonPlan.id, userId])
            expect(result.rowCount).toBe(1)
            expect(result.rows[0].name).toBe(null)
            expect(result.rows[0].instrument).toBe(null)
            expect(result.rows[0].created).toStrictEqual(result.rows[0].updated)
        })

        it('rejects bad instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await expect(() => lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Emmet Otter\'s Jug Band Christmas',
                instrument: 'washboard' as Instrument,
            }))
                .rejects
                .toThrowError('invalid input value for enum instrument: "washboard"')
        })

        it('rejects bad user id', async () => {
            await expect(() => lessonQueries.createLessonPlan({
                user: {id: '59d40025-d814-49d8-b367-5858d701111c'},
                name: 'Emmet Otter\'s Jug Band Christmas',
                instrument: 'banjo',
            }))
                .rejects
                .toThrowError(/lesson_plans_user_id_fkey/)
        })
    })

    describe('createLessonUnit', () => {
        it('saves new lesson unit', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 1,
                        y: 2,
                        w: 3,
                        h: 4,
                    },
                    type: 'measure',
                }],
            }]
            const lessonUnit = await lessonQueries.createLessonUnit({
                user: {id: userId},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames,
            })
            const result = await db.query('select * from lesson_units where id = $1', [lessonUnit.id])
            expect(result.rows).toHaveLength(1)
            expect(result.rows[0].lesson_plan_id).toBe(lessonPlan.id)
            expect(result.rows[0].name).toBe('Chromatic Scale')
            expect(result.rows[0].entities).toBe(JSON.stringify(frames))
            expect(result.rows[0].created).toStrictEqual(result.rows[0].updated)
        })
        it('errors on bad user id for lesson plan', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 1,
                        y: 2,
                        w: 3,
                        h: 4,
                    },
                    type: 'measure',
                }],
            }]
            const lessonUnit = {
                user: {id: BAD_UUID},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames,
            }
            await expect(() => lessonQueries.createLessonUnit(lessonUnit))
                .rejects
                .toThrowError('null value in column "lesson_plan_id" of relation "lesson_units" violates not-null constraint')
        })
    })

    describe('updateLessonUnitFrames', () => {
        it('updates lesson unit frames', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const lessonUnit = await lessonQueries.createLessonUnit({
                user: {id: userId},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames: [{
                    entities: [{
                        rect: {
                            x: 1,
                            y: 2,
                            w: 3,
                            h: 4,
                        },
                        type: 'measure',
                    }],
                }],
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 4,
                        y: 3,
                        w: 2,
                        h: 1,
                    },
                    type: 'chord',
                }],
            }]
            await new Promise(res => setTimeout(res, 1000))
            await lessonQueries.updateLessonUnitFrames(userId, lessonPlan.id, lessonUnit.id, frames)
            const result = await db.query('select * from lesson_units where id = $1', [lessonUnit.id])
            expect(result.rows).toHaveLength(1)
            expect(result.rows[0].id).toHaveLength(36)
            expect(result.rows[0].name).toBe('Chromatic Scale')
            expect(result.rows[0].entities).toBe(JSON.stringify(frames))
            expect(result.rows[0].created).not.toStrictEqual(result.rows[0].updated)
            expect(result.rows[0].created < result.rows[0].updated).toBeTruthy()
        })
        it('throws up for bad user id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await lessonQueries.createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const lessonUnit = await lessonQueries.createLessonUnit({
                user: {id: userId},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames: [],
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 4,
                        y: 3,
                        w: 2,
                        h: 1,
                    },
                    type: 'chord',
                }],
            }]
            await new Promise(res => setTimeout(res, 1000))
            await expect(() => lessonQueries.updateLessonUnitFrames(BAD_UUID, lessonPlan.id, lessonUnit.id, frames))
                .rejects
                .toThrowError('not found')
        })
    })
})
