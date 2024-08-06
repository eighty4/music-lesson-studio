// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
import type {UserContext} from '$lib/http/UserContext'

declare global {
    namespace App {
        // interface Error {}
        // interface PageData {}
        // interface PageState {}
        // interface Platform {}

        interface Locals {
            user: UserContext
        }
    }
    var mlsEditorSession: {
        apiHost: string
        planId?: string
        planName?: string
        unitId?: string
    }
    var serviceWorkerVersion: string | null
}

export {}
