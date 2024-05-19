export type Instrument = 'banjo' | 'guitar' | 'mandolin' | 'ukulele'

export function isValidFrameData(frameData: Array<LessonFrame> | undefined | null): boolean {
    if (frameData === null || typeof frameData === 'undefined') {
        return true
    }
    return Array.isArray(frameData)
}

export function isValidInstrument(instrument: string | undefined | null): boolean {
    if (instrument === null || typeof instrument === 'undefined') {
        return true
    }
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

export interface LessonPlan {
    id: string
    userId: string
    name?: string
    instrument?: Instrument
    created: Date
    updated: Date
}

export interface LessonUnit {
    id: string
    planId: string
    userId: string
    name?: string
    instrument?: Instrument
    frames?: Array<LessonFrame>
    created: Date
    updated: Date
}

export interface LessonFrame {
    entities: Array<FrameEntity>
}

export type FrameEntityType = 'measure' | 'chord'

export interface FrameEntity {
    type: FrameEntityType
    rect: {
        x: number
        y: number
        h: number
        w: number
    }
}
