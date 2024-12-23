import pg from 'pg'
import {beforeAll, describe, expect, it} from 'vitest'
import {ZodError} from 'zod'
import type {Instrument, LessonFrame} from '$lib/data/LessonPlanTypes'
import LessonQueries from './LessonQueries'

const BAD_UUID = '59d40025-d814-49d8-b367-5858d701111c'

describe('LessonQueries', () => {

    let db: pg.Pool

    beforeAll(() => {
        db = new pg.Pool()
    })

    describe('findUserLessonPlans', () => {
        it('returns lesson plans', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3), ($1, $4, $5)',
                [userId, 'Banjo 101', 'banjo', 'Ukulele 201', 'ukulele'],
            )
            const result = await new LessonQueries(db).findUserLessonPlans(userId)
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
            expect(await new LessonQueries(db).findUserLessonPlans(BAD_UUID)).toHaveLength(0)
        })
        it('empty array when none found', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            expect(await new LessonQueries(db).findUserLessonPlans(userId)).toHaveLength(0)
        })
        it('with null name and instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            await db.query(
                'insert into lesson_plans (user_id) values ($1)',
                [userId],
            )
            const result = await new LessonQueries(db).findUserLessonPlans(userId)
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
            const result = await new LessonQueries(db).findUserLessonPlan(lessonPlanId, userId)
            expect(result.id).toBe(lessonPlanId)
            expect(result.user.id).toBe(userId)
            expect(result.name).toBe('Guitar 101')
            expect(result.instrument).toBe('guitar')
            expect(result.created).toStrictEqual(result.updated)
        })
        it('throws error when not found', async () => {
            await expect(() => new LessonQueries(db)
                .findUserLessonPlan(BAD_UUID, BAD_UUID))
                .rejects
                .toThrowError(`lesson plan ${BAD_UUID} for user ${BAD_UUID} not found`)
        })
        it('errors with mismatch user id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const planId = lessonPlanResult.rows[0].id
            await expect(() => new LessonQueries(db).findUserLessonPlan(BAD_UUID, planId))
                .rejects
                .toThrowError(`lesson plan ${BAD_UUID} for user ${planId} not found`)
        })
        it('with null name and instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id) values ($1) returning id',
                [userId],
            )
            const planId = lessonPlanResult.rows[0].id
            const result = await new LessonQueries(db).findUserLessonPlan(planId, userId)
            expect(result.id).toHaveLength(36)
            expect(result.user.id).toBe(userId)
            expect(result.name).toBe(null)
            expect(result.instrument).toBe(null)
            expect(result.created).toStrictEqual(result.updated)
        })
    })

    describe('findUserLessonUnits', () => {
        it('returns lesson units', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const planId = lessonPlanResult.rows[0].id
            const lessonUnitResult1 = await db.query(
                'insert into lesson_units (lesson_plan_id, name, instrument, entities) values ($1, $2, $3, $4) returning id',
                [planId, 'Chromatic Scale 1', 'banjo', '[]'],
            )
            const unitId1 = lessonUnitResult1.rows[0].id
            const lessonUnitResult2 = await db.query(
                'insert into lesson_units (lesson_plan_id, name, instrument, entities) values ($1, $2, $3, $4) returning id',
                [planId, 'Chromatic Scale 2', 'guitar', '[]'],
            )
            const unitId2 = lessonUnitResult2.rows[0].id
            const lessonUnitResult3 = await db.query(
                'insert into lesson_units (lesson_plan_id, name, instrument, entities) values ($1, $2, $3, $4) returning id',
                [planId, 'Chromatic Scale 3', 'mandolin', '[]'],
            )
            const unitId3 = lessonUnitResult3.rows[0].id
            const result = await new LessonQueries(db).findUserLessonUnits(userId, planId)
            expect(result.length).toBe(3)
            expect(result.map((unit) => unit.id)).toStrictEqual([unitId1, unitId2, unitId3])
            result.forEach(unit => {
                expect(unit.user.id).toBe(userId)
                expect(unit.plan.id).toBe(planId)
                expect(unit.plan.name).toBe('Guitar 101')
            })
            expect(result[0].instrument).toBe('banjo')
            expect(result[0].name).toBe('Chromatic Scale 1')
            expect(result[1].instrument).toBe('guitar')
            expect(result[1].name).toBe('Chromatic Scale 2')
            expect(result[2].instrument).toBe('mandolin')
            expect(result[2].name).toBe('Chromatic Scale 3')
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
            const result = await new LessonQueries(db).findUserLessonUnit(userId, planId, unitId)
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
            await expect(() => new LessonQueries(db).findUserLessonUnit(userId, BAD_UUID, unitId))
                .rejects
                .toThrowError('not found')
            await expect(() => new LessonQueries(db).findUserLessonUnit(BAD_UUID, planId, unitId))
                .rejects
                .toThrowError('not found')
        })
    })

    describe('createLessonPlan', () => {
        it('saves lesson plan', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await new LessonQueries(db).createLessonPlan({
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
            const lessonPlan = await new LessonQueries(db).createLessonPlan({user: {id: userId}})
            const result = await db.query('select * from lesson_plans where id = $1 and user_id = $2', [lessonPlan.id, userId])
            expect(result.rowCount).toBe(1)
            expect(result.rows[0].name).toBe(null)
            expect(result.rows[0].instrument).toBe(null)
            expect(result.rows[0].created).toStrictEqual(result.rows[0].updated)
        })

        describe('validation errors', () => {
            it('rejects bad instrument', async () => {
                const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
                const userId = userResult.rows[0].id
                await expect(() => new LessonQueries(db).createLessonPlan({
                    user: {id: userId},
                    name: 'Emmet Otter\'s Jug Band Christmas',
                    instrument: 'washboard' as Instrument,
                }))
                    .rejects
                    .toThrowError(ZodError)
            })

            it('rejects bad name', async () => {
                await expect(() => new LessonQueries(db).createLessonPlan({
                    user: {id: '59d40025-d814-49d8-b367-5858d701111c'},
                    name: 'ab',
                    instrument: 'banjo',
                }))
                    .rejects
                    .toThrowError(ZodError)
            })
        })
    })

    describe('createLessonUnit', () => {
        it('saves new lesson unit', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await new LessonQueries(db).createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 0,
                        y: 0,
                        w: 1,
                        h: 1,
                    },
                    type: 'measure',
                    data: {
                        instrument: 'banjo',
                        notes: [],
                    },
                }],
            }]
            const lessonUnit = await new LessonQueries(db).createLessonUnit({
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

        it('not found error on bad user id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await new LessonQueries(db).createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 0,
                        y: 0,
                        w: 1,
                        h: 1,
                    },
                    type: 'measure',
                    data: {
                        instrument: 'banjo',
                        notes: [],
                    },
                }],
            }]
            const lessonUnit = {
                user: {id: BAD_UUID},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames,
            }
            await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit))
                .rejects
                .toThrowError('not found')
        })

        it('not found error on bad lesson plan id', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 0,
                        y: 0,
                        w: 1,
                        h: 1,
                    },
                    type: 'measure',
                    data: {
                        instrument: 'banjo',
                        notes: [],
                    },
                }],
            }]
            const lessonUnit = {
                user: {id: userId},
                plan: {id: BAD_UUID},
                name: 'Chromatic Scale',
                frames,
            }
            await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit))
                .rejects
                .toThrowError('not found')
        })
        it('throws error from db client', async () => {
            const lessonUnit = {
                user: {id: 'asdf'},
                plan: {id: BAD_UUID},
                name: 'Chromatic Scale',
                frames: [],
            }
            await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit as any))
                .rejects
                .toThrowError(ZodError)
        })

        describe('validation errors', () => {
            it('throws error for bad instrument value', async () => {
                const lessonUnit = {
                    user: {id: 'asdf'},
                    plan: {id: 'fdsa'},
                    instrument: 'washboard',
                    frames: [],
                }
                await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit as any))
                    .rejects
                    .toThrowError(ZodError)
            })
            it('throws error for bad name value', async () => {
                const lessonUnit = {
                    user: {id: 'asdf'},
                    plan: {id: 'fdsa'},
                    name: 'ab',
                    frames: [],
                }
                await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit as any))
                    .rejects
                    .toThrowError(ZodError)
            })
            it('throws error for bad frame data', async () => {
                const lessonUnit = {
                    user: {id: 'asdf'},
                    plan: {id: 'fdsa'},
                    frames: {},
                }
                await expect(() => new LessonQueries(db).createLessonUnit(lessonUnit as any))
                    .rejects
                    .toThrowError(ZodError)
            })
        })
    })

    describe('updateLessonUnitFrames', () => {
        it('updates lesson unit frames', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlan = await new LessonQueries(db).createLessonPlan({
                user: {id: userId},
                name: 'Robert Fripp\'s Sweet Movin\' Dance',
                instrument: 'banjo',
            })
            const lessonUnit = await new LessonQueries(db).createLessonUnit({
                user: {id: userId},
                plan: {id: lessonPlan.id},
                name: 'Chromatic Scale',
                frames: [{
                    entities: [{
                        rect: {
                            x: 1,
                            y: 1,
                            w: 1,
                            h: 1,
                        },
                        type: 'measure',
                        data: {
                            instrument: 'banjo',
                            notes: [],
                        },
                    }],
                }],
            })
            const frames: Array<LessonFrame> = [{
                entities: [{
                    rect: {
                        x: 1,
                        y: 1,
                        w: 1,
                        h: 1,
                    },
                    type: 'chord',
                    data: {
                        chord: 'c',
                        instrument: 'banjo',
                    },
                }],
            }]
            await new Promise(res => setTimeout(res, 1000))
            await new LessonQueries(db).updateLessonUnitFrames(userId, lessonPlan.id, lessonUnit.id, frames)
            const result = await db.query('select * from lesson_units where id = $1', [lessonUnit.id])
            expect(result.rows).toHaveLength(1)
            expect(result.rows[0].id).toHaveLength(36)
            expect(result.rows[0].name).toBe('Chromatic Scale')
            expect(result.rows[0].entities).toBe(JSON.stringify(frames))
            expect(result.rows[0].created).not.toStrictEqual(result.rows[0].updated)
            expect(result.rows[0].created < result.rows[0].updated).toBeTruthy()
        })

        describe('validation errors', () => {
            it('throws error for bad frame data', async () => {
                const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
                const userId = userResult.rows[0].id
                const lessonPlan = await new LessonQueries(db).createLessonPlan({
                    user: {id: userId},
                    name: 'Robert Fripp\'s Sweet Movin\' Dance',
                    instrument: 'banjo',
                })
                const lessonUnit = await new LessonQueries(db).createLessonUnit({
                    user: {id: userId},
                    plan: {id: lessonPlan.id},
                    frames: [],
                })
                await expect(() => new LessonQueries(db).updateLessonUnitFrames(userId, lessonPlan.id, lessonUnit.id, {} as any))
                    .rejects
                    .toThrowError(ZodError)
            })
        })
    })

    describe('updateLessonPlanInstrument', () => {
        it('updates instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const lessonPlanId = lessonPlanResult.rows[0].id
            await new LessonQueries(db).updateLessonPlanInstrument(lessonPlanId, userId, 'ukulele')
            const result = await db.query('select instrument from lesson_plans where id = $1', [lessonPlanId])
            expect(result.rows[0].instrument).toBe('ukulele')
        })
    })

    describe('updateLessonPlanName', () => {
        it('updates instrument', async () => {
            const userResult = await db.query('insert into users (email, name) values ($1, $2) returning id', ['emmet@mls.edu', 'Emmet'])
            const userId = userResult.rows[0].id
            const lessonPlanResult = await db.query(
                'insert into lesson_plans (user_id, name, instrument) values ($1, $2, $3) returning id',
                [userId, 'Guitar 101', 'guitar'],
            )
            const lessonPlanId = lessonPlanResult.rows[0].id
            await new LessonQueries(db).updateLessonPlanName(lessonPlanId, userId, 'Guitar 201')
            const result = await db.query('select name from lesson_plans where id = $1', [lessonPlanId])
            expect(result.rows[0].name).toBe('Guitar 201')
        })
    })
})
