import {randomString} from '$lib/data/generate'
import type LoginQueries from '$lib/data/LoginQueries'

interface ActivationEventSourceObserver {
    onConnect(): void

    onClose(): void
}

type ActivationEventType = 'initiated' | 'activated'

class ActivationEventSource implements UnderlyingSource {
    private controller: ReadableStreamController<any> | undefined

    constructor(private readonly observer: ActivationEventSourceObserver) {
    }

    start(controller: ReadableStreamController<any>) {
        this.controller = controller
        this.observer.onConnect()
    }

    send(event: ActivationEventType, data: string) {
        this.controller!.enqueue(`event: ${event}\ndata: ${data}\n\n` as any)
    }

    cancel() {
        this.observer.onClose()
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
            return true
        } else {
            return false
        }
    }
}
