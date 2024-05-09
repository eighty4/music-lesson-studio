// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
declare global {
    namespace App {
        // interface Error {}
        // interface Locals {}
        // interface PageData {}
        // interface PageState {}
        // interface Platform {}
    }
    var mlsEditorSession: {
        apiHost: string
        planId?: string
        planName?: string
        unitId?: string
    };
    var serviceWorkerVersion: string | null;
}

export {};
