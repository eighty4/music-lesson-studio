import {describe, expect, it} from 'vitest'
import {type ChordChartData, type FrameEntity, type MeasureChartData, validateFrameEntity} from './LessonPlanTypes'
import {ZodError} from 'zod'

describe('LessonPlanTypes', () => {
    describe('isValidFrameEntity', () => {
        describe('rect', () => {
            it.each([null, false, true, '', -1, 2, null, undefined])('bad rect %i', (v) => {
                for (const k of ['x', 'y', 'w', 'h']) {
                    const rect: any = {x: 1, y: 1, w: 1, h: 1}
                    rect[k] = v
                    const entity: FrameEntity<ChordChartData> = {
                        type: 'chord',
                        rect,
                        data: {
                            chord: 'a',
                            instrument: 'banjo',
                        },
                    } as FrameEntity<ChordChartData>
                    expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
                }
            })
        })
        describe('chord', () => {
            it('bad rect', () => {
                const entity: FrameEntity<ChordChartData> = {
                    type: 'chord',
                    rect: {},
                    data: {
                        chord: 'a',
                        instrument: 'banjo',
                    },
                } as FrameEntity<ChordChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it('bad instrument', () => {
                const entity: FrameEntity<ChordChartData> = {
                    type: 'chord',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        chord: 'a',
                        instrument: 'keytar',
                    },
                } as unknown as FrameEntity<ChordChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it('bad chord', () => {
                const entity: FrameEntity<ChordChartData> = {
                    type: 'chord',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        chord: 'h',
                        instrument: 'banjo',
                    },
                } as unknown as FrameEntity<ChordChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it('valid entity', () => {
                const entity: FrameEntity<ChordChartData> = {
                    type: 'chord',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        chord: 'a',
                        instrument: 'banjo',
                    },
                }
                validateFrameEntity(entity)
            })
        })
        describe('measure', () => {
            it('bad rect', () => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {},
                    data: {
                        instrument: 'banjo',
                        notes: [],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it('bad instrument', () => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'keytar',
                        notes: [],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it.each([true, false, 0, 25, ''])('bad fret %i', (f) => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'banjo',
                        notes: [{f, s: 1, t: 1}],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it.each([1, ''])('bad melody %i', (m) => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'banjo',
                        notes: [{m, s: 1, t: 1}],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it.each([null, undefined, false, true, 0, 7, ''])('bad string %i', (s) => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'banjo',
                        notes: [{s, t: 1}],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it.each([null, undefined, false, true, 0, 17, ''])('bad timing %i', (t) => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'banjo',
                        notes: [{s: 1, t}],
                    },
                } as unknown as FrameEntity<MeasureChartData>
                expect(() => validateFrameEntity(entity)).toThrowError(ZodError)
            })
            it('valid entity', () => {
                const entity: FrameEntity<MeasureChartData> = {
                    type: 'measure',
                    rect: {x: 1, y: 1, w: 1, h: 1},
                    data: {
                        instrument: 'banjo',
                        notes: [{
                            f: 1,
                            s: 1,
                            t: 1,
                            m: true,
                        }],
                    },
                }
                validateFrameEntity(entity)
            })
        })
    })
})
