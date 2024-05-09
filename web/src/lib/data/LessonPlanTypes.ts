export type Instrument = 'banjo' | 'guitar' | 'mandolin' | 'ukulele'

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

export interface LessonPlan {
    id: string
    userId: string
    name: string
    instrument: Instrument
    created: Date
    updated: Date
}

export interface LessonUnit {
    id: string
    name: string
    frames: Array<LessonFrame>
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
