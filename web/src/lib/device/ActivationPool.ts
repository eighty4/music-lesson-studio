import {randomString} from '$lib/data/generate'
import type LoginQueries from '$lib/data/LoginQueries'

interface ActivationEventSourceObserver {
    onConnect(): void

    onClose(): void
}

type ActivationEventType = 'initiated' | 'activated'

class ActivationEventSource implements UnderlyingSource {
    private controller: ReadableStreamController<any> | undefined
    private closed: boolean = false

    constructor(private readonly observer: ActivationEventSourceObserver) {
    }

    cancel() {
        if (!this.closed) {
            this.#close()
        }
    }

    close() {
        if (!this.closed) {
            this.#close()
        }
    }

    #close() {
        this.closed = true
        this.controller?.close()
        this.observer?.onClose()
    }

    send(event: ActivationEventType, data: string) {
        this.controller!.enqueue(`event: ${event}\ndata: ${data}\n\n` as any)
    }

    start(controller: ReadableStreamController<any>) {
        this.controller = controller
        this.observer.onConnect()
    }
}

export default class ActivationPool {
    private readonly connections: Record<string, ActivationEventSource> = {}

    constructor(private readonly loginQueries: LoginQueries) {
    }

    async addConnection(): Promise<ReadableStream> {
        const deviceToken = randomString(6)
        await this.loginQueries.saveDeviceToken(deviceToken)
        return new ReadableStream(this.connections[deviceToken] = new ActivationEventSource({
            onConnect: () => this.connections[deviceToken]?.send('initiated', deviceToken),
            onClose: () => delete this.connections[deviceToken],
        }))
    }

    activate(deviceToken: string, authToken: string) {
        const conn = this.connections[deviceToken]
        if (!!conn) {
            conn.send('activated', authToken)
            conn.close()
            return true
        } else {
            return false
        }
    }
}
