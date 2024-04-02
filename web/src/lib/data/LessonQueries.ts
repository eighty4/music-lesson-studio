import type {Pool} from 'pg'
import type {Instrument, LessonPlan} from '$lib/data/LessonPlanTypes'

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
            name: 'find-user-lesson-plan',
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

    async createLessonPlan(userId: string, name: string, instrument: Instrument): Promise<string> {
        const result = await this.db.query({
            name: 'create-lesson-plan',
            text: `
                insert into lesson_plans (user_id, name, instrument)
                values ($1, $2, $3)
                returning id
            `,
            values: [userId, name, instrument],
        })
        return result.rows[0].id
    }
}
