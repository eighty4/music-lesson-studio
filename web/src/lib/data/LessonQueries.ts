import type {Pool} from 'pg'
import type {Instrument, LessonFrame, LessonPlan, LessonUnit} from '$lib/data/LessonPlanTypes'

export default class LessonQueries {
    constructor(private readonly db: Pool) {
    }

    async findUserLessonPlans(userId: string): Promise<Array<LessonPlan>> {
        const result = await this.db.query({
            name: 'find-user-lesson-plans',
            text: `
                select id, name, instrument, created, updated
                from lesson_plans
                where user_id = $1
            `,
            values: [userId],
        })
        return result.rows.map(row => {
            return {
                id: row['id'],
                userId: userId,
                name: row['name'],
                instrument: row['instrument'],
                created: row['created'],
                updated: row['updated'],
            }
        })
    }

    async findUserLessonPlan(lessonPlanId: string, userId: string): Promise<LessonPlan> {
        const result = await this.db.query({
            name: 'find-user-edit-lesson-plan',
            text: `
                select name, instrument, created, updated
                from lesson_plans
                where id = $1
                  and user_id = $2
                limit 1
            `,
            values: [lessonPlanId, userId],
        })
        if (result.rowCount === 0) {
            throw new Error(`not found lesson plan ${lessonPlanId} for user ${userId}`)
        }
        return {
            id: lessonPlanId,
            userId: userId,
            name: result.rows[0]['name'],
            instrument: result.rows[0]['instrument'],
            created: result.rows[0]['created'],
            updated: result.rows[0]['updated'],
        }
    }

    async createLessonPlan(userId: string, name: string | null, instrument: Instrument | null): Promise<string> {
        const result = await this.db.query({
            name: 'create-edit-lesson-plan',
            text: `
                insert into lesson_plans (user_id, name, instrument)
                values ($1, $2, $3)
                returning id
            `,
            values: [userId, name ?? null, instrument ?? null],
        })
        return result.rows[0].id
    }

    // todo constraint userId
    async saveLessonUnit(userId: string, lessonPlanId: string, createOrUpdateUnit: LessonUnit | Omit<LessonUnit, 'id'>): Promise<string> {
        const unit = createOrUpdateUnit as LessonUnit
        const framesAsJson = JSON.stringify(unit.frames)
        if (unit.id) {
            await this.db.query({
                name: 'update-lesson-unit',
                text: `
                    update lesson_units
                    set name     = $2,
                        entities = $3,
                        updated  = now()
                    where id = $1
                `,
                values: [unit.id, unit.name, framesAsJson],
            })
            return unit.id
        } else {
            const result = await this.db.query({
                name: 'create-lesson-unit',
                text: `
                    insert into lesson_units (lesson_plan_id, name, entities)
                    values ($1, $2, $3)
                    returning id
                `,
                values: [lessonPlanId, unit.name, framesAsJson],
            })
            return result.rows[0].id
        }
    }

    // todo constraint userId
    async updateLessonUnitFrames(userId: string, planId: string, unitId: string, frames: Array<LessonFrame>): Promise<void> {
        await this.db.query({
            name: 'update-lesson-unit-frames',
            text: `
                update lesson_units
                set entities = $3,
                    updated  = now()
                where id = $1
                  and lesson_plan_id = $2
            `,
            values: [unitId, planId, JSON.stringify(frames)],
        })
    }
}
