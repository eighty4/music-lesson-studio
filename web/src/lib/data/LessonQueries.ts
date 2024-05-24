import type {Pool} from 'pg'
import type {LessonFrame, LessonPlan, LessonUnit} from '$lib/data/LessonPlanTypes'

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
        const user = {id: userId}
        return result.rows.map(row => {
            return {
                user,
                id: row['id'],
                name: row['name'],
                instrument: row['instrument'],
                created: row['created'],
                updated: row['updated'],
            }
        })
    }

    async findUserLessonPlan(planId: string, userId: string): Promise<LessonPlan> {
        const result = await this.db.query({
            name: 'find-user-lesson-plan',
            text: `
                select name, instrument, created, updated
                from lesson_plans
                where id = $1
                  and user_id = $2
                limit 1
            `,
            values: [planId, userId],
        })
        if (result.rowCount === 0) {
            throw new Error(`not found lesson plan ${planId} for user ${userId}`)
        }
        return {
            user: {id: userId},
            id: planId,
            name: result.rows[0]['name'],
            instrument: result.rows[0]['instrument'],
            created: result.rows[0]['created'],
            updated: result.rows[0]['updated'],
        }
    }

    async findUserLessonUnit(userId: string, planId: string, unitId: string): Promise<LessonUnit> {
        const result = await this.db.query({
            name: 'find-user-lesson-unit',
            text: `select lu.name, lu.entities, lu.instrument, lu.created, lu.updated, lp.name as plan_name
                   from lesson_units lu
                            join lesson_plans lp on lu.lesson_plan_id = lp.id
                            join users u on u.id = lp.user_id
                   where lu.id = $3
                     and lp.id = $2
                     and u.id = $1`,
            values: [userId, planId, unitId],
        })
        if (result.rowCount === 0) {
            throw new Error('not found')
        }
        const row = result.rows[0]
        return {
            user: {id: userId},
            plan: {id: planId, name: row.plan_name},
            id: unitId,
            name: row.name,
            instrument: row.instrument,
            frames: JSON.parse(row.entities),
            created: row.created,
            updated: row.updated,
        }
    }

    async createLessonPlan(lessonPlan: Omit<LessonPlan, 'id' | 'created' | 'updated'>): Promise<LessonPlan> {
        const result = await this.db.query({
            name: 'create-lesson-plan',
            text: `
                insert into lesson_plans (user_id, name, instrument)
                values ($1, $2, $3)
                returning id, created
            `,
            values: [lessonPlan.user.id, lessonPlan.name, lessonPlan.instrument],
        })
        return {
            ...lessonPlan,
            id: result.rows[0].id,
            created: result.rows[0].created,
            updated: result.rows[0].created,
        }
    }

    async createLessonUnit(lessonUnit: Omit<LessonUnit, 'id' | 'created' | 'updated'>): Promise<LessonUnit> {
        const framesAsJson = !lessonUnit.frames ? null : JSON.stringify(lessonUnit.frames)
        const result = await this.db.query({
            name: 'create-lesson-unit',
            text: `
                insert into lesson_units (name, instrument, entities, lesson_plan_id)
                values ($3, $4, $5,
                        (select lp.id from lesson_plans lp where lp.id = $2 and user_id = $1))
                returning id, created
            `,
            values: [lessonUnit.user.id, lessonUnit.plan.id, lessonUnit.name, lessonUnit.instrument, framesAsJson],
        })
        return {
            ...lessonUnit,
            id: result.rows[0].id,
            created: result.rows[0].created,
            updated: result.rows[0].created,
        }
    }

    async updateLessonUnitFrames(userId: string, planId: string, unitId: string, frames: Array<LessonFrame>): Promise<void> {
        const result = await this.db.query({
            name: 'update-lesson-unit-frames',
            text: `
                update lesson_units
                set entities = $3,
                    updated  = now()
                where id = $1
                  and lesson_plan_id = $2
                  and $4 = (select lp.user_id from lesson_plans lp where lp.id = $2)
            `,
            values: [unitId, planId, JSON.stringify(frames), userId],
        })
        if (!result.rowCount) {
            throw new Error('not found')
        }
    }
}
