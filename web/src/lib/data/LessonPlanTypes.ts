import z from 'zod'
import type {User} from './UserTypes'

const InstrumentValues = ['banjo', 'guitar', 'mandolin', 'ukulele'] as const
export type Instrument = typeof InstrumentValues[number]

const instrumentValidator = z.enum(InstrumentValues)

export const validateInstrument = (instrument: Instrument) => instrumentValidator.parse(instrument)

// todo remaining note types
const ChordValues = ['a', 'b', 'c', 'd', 'e', 'f', 'g'] as const
export type Chord = typeof ChordValues[number]

const chordValidator = z.enum(ChordValues)

export const validateChord = (chord: Chord) => chordValidator.parse(chord)

export const FrameEntityTypeValues = ['measure', 'chord'] as const
export type FrameEntityType = typeof FrameEntityTypeValues[number]

export interface EntityRect {
    x: number
    y: number
    h: number
    w: number
}

const entityRectValidator = z.object({
    x: z.number().gte(0).lte(1),
    y: z.number().gte(0).lte(1),
    h: z.number().gte(0).lte(1),
    w: z.number().gte(0).lte(1),
})

export interface ChordChartData {
    chord: Chord
    instrument: Instrument
}

const chordChartDataValidator = z.object({
    chord: chordValidator,
    instrument: instrumentValidator,
})

export interface Note {
    // fret
    f?: number | null
    // melody
    m?: boolean | null
    // string
    s: number
    // timing
    t: number
}

// todo cap fret by instrument
// todo note.s depends on instrument
// todo note.t
const noteValidator = z.object({
    f: z.number().gte(1).lte(5).nullish(),
    m: z.boolean().nullish(),
    s: z.number().gte(1).lte(6),
    t: z.number().gte(1).lte(16),
})

export interface MeasureChartData {
    instrument: Instrument
    notes: Array<Note>
}

const measureChartDataValidator = z.object({
    instrument: instrumentValidator,
    notes: z.array(noteValidator),
})

export interface FrameEntity<T> {
    type: FrameEntityType
    rect: EntityRect
    data: T
}

const entityValidator = z.discriminatedUnion('type', [
    z.object({
        type: z.literal('chord'),
        rect: entityRectValidator,
        data: chordChartDataValidator,
    }),
    z.object({
        type: z.literal('measure'),
        rect: entityRectValidator,
        data: measureChartDataValidator,
    }),
])

export function validateFrameEntity(frameEntity: FrameEntity<any>) {
    entityValidator.parse(frameEntity)
}

export interface LessonFrame {
    entities: Array<FrameEntity<any>>
}

const frameValidator = z.object({
    entities: z.array(entityValidator).max(10),
})

const framesValidator = z.array(frameValidator).max(10).nullish()

export function validateLessonFrames(frames: Array<LessonFrame>) {
    return framesValidator.parse(frames)
}

export interface LessonUnit {
    plan: Pick<LessonPlan, 'id' | 'name'>
    user: Pick<User, 'id'>
    id: string
    name?: string
    instrument?: Instrument
    frames?: Array<LessonFrame>
    created: Date
    updated: Date
}

const lessonNameValidator = z.string()
    .min(6, 'Lesson names must be at least 6 characters')
    .max(50, 'Lesson names must be no more than 50 characters')
    .regex(/^[a-z][a-z0-9'_\s\-]+$/i, 'Lesson names should only have letters and spaces')

export const validateLessonName = (lessonName: string) => lessonNameValidator.parse(lessonName)

const newUnitValidator = z.object({
    plan: z.object({
        id: z.string().uuid(),
        name: lessonNameValidator.nullish(),
    }),
    user: z.object({
        id: z.string().uuid(),
    }),
    name: lessonNameValidator.nullish(),
    instrument: instrumentValidator.nullish(),
    frames: framesValidator,
})

export function validateNewLessonUnit(lessonUnit: Omit<LessonUnit, 'id' | 'created' | 'updated'>) {
    newUnitValidator.parse(lessonUnit)
}

// const storedUnitValidator = newUnitValidator.merge(z.object({
//     id: z.string().uuid(),
// }))

export interface LessonPlan {
    user: Pick<User, 'id'>
    id: string
    name?: string
    instrument?: Instrument
    created: Date
    updated: Date
}

const newLessonPlanValidator = z.object({
    user: z.object({
        id: z.string().uuid(),
    }),
    name: lessonNameValidator.nullish(),
    instrument: instrumentValidator.nullish(),
    frames: framesValidator,
})

export function validateNewLessonPlan(lessonPlan: Omit<LessonPlan, 'id' | 'created' | 'updated'>) {
    return newLessonPlanValidator.parse(lessonPlan)
}

// const storedPlanValidator = newPlanValidator.merge(z.object({
//     id: z.string().uuid(),
// }))
