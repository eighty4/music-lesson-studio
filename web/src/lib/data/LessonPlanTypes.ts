import type {User} from '$lib/data/UserTypes'

export type Instrument = 'banjo' | 'guitar' | 'mandolin' | 'ukulele'

export type Chord = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g'

export interface LessonPlan {
    user: Pick<User, 'id'>
    id: string
    name?: string
    instrument?: Instrument
    created: Date
    updated: Date
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

export interface LessonFrame {
    entities: Array<FrameEntity<any>>
}

export type FrameEntityType = 'measure' | 'chord'

export interface FrameEntity<T> {
    type: FrameEntityType
    rect: EntityRect
    data: T
}

export interface EntityRect {
    x: number
    y: number
    h: number
    w: number
}

export interface ChordChartData {
    chord: Chord
    instrument: Instrument
}

export interface MeasureChartData {
    instrument: Instrument
    notes: Array<Note>
}

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

// todo validation fns throw validation messages

export function isValidFrameData(frameData: Array<LessonFrame> | undefined | null): boolean {
    if (frameData === null || typeof frameData === 'undefined') {
        return true
    }
    return Array.isArray(frameData) && frameData.every(isValidLessonFrame)
}

export function isValidFrameEntity(entity: FrameEntity<any>): boolean {
    if (!isValidEntityRect(entity.rect)) {
        return false
    }
    switch (entity.type) {
        case 'chord':
            return isValidChordChartEntity(entity)
        case 'measure':
            return isValidMeasureChartEntity(entity)
        default:
            return false
    }
}

export function isValidOptionalInstrument(instrument: string | undefined | null): boolean {
    return instrument === null || typeof instrument === 'undefined' || isValidInstrument(instrument)
}

export function isValidInstrument(instrument: string): boolean {
    switch (instrument) {
        case 'banjo':
        case 'guitar':
        case 'mandolin':
        case 'ukulele':
            return true
        default:
            return false
    }
}

export function isValidLessonName(lessonName: string | undefined | null): boolean {
    if (lessonName === null || typeof lessonName === 'undefined') {
        return true
    }
    return lessonName.length > 3
}

function isValidEntityRect(rect: EntityRect): boolean {
    return Object.keys(rect).length === 4 && [rect.x, rect.y, rect.w, rect.h].every((v) => {
        return isNumber(v) && v >= 0 && v <= 1
    })
}

function isNumber(v: any): boolean {
    return typeof v === 'number'
}

function isValidChord(chord: Chord): boolean {
    switch (chord) {
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
        case 'g':
            return true
        default:
            return false
    }
}

function isValidChordChartEntity(entity: FrameEntity<ChordChartData>): boolean {
    return isValidChord(entity.data.chord) && isValidInstrument(entity.data.instrument)
}

function isValidMeasureChartEntity(entity: FrameEntity<MeasureChartData>): boolean {
    if (!isValidInstrument(entity.data.instrument)) {
        return false
    }
    return entity.data.notes.every((note) => isValidNote(entity.data.instrument, note))
}

export function isValidLessonFrame(frame: LessonFrame): boolean {
    return frame.entities.every((entity) => isValidFrameEntity(entity))
}

function isValidNote(instrument: Instrument, note: Note): boolean {
    if (!isNumber(note.s) || !isNumber(note.t)) {
        return false
    }
    if (!(typeof note.m === 'undefined' || note.m === null || note.m === true || note.m === false)) {
        return false
    }
    if (!(typeof note.f === 'undefined' || note.f === null || isNumber(note.f))) {
        return false
    }
    // todo cap fret by instrument
    if (note.f! < 1 || note.f! > 24) {
        return false
    }
    if (note.s < 1 || note.s > stringCount(instrument)) {
        return false
    }
    if (note.t < 1 || note.t > 16) {
        return false
    }
    return true
}

function stringCount(instrument: Instrument): number {
    switch (instrument) {
        case 'banjo':
            return 5
        case 'guitar':
            return 6
        default:
            throw new Error()
    }
}
