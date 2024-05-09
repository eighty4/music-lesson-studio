<script lang="ts">
    import {dev} from '$app/environment'
    import {PUBLIC_STUDIO_FSWV as serviceWorkerVersion} from '$env/static/public'

    interface StudioEditorProps {
        planId?: string
        planName?: string
        unitId?: string
    }

    let {planId, planName, unitId}: StudioEditorProps = $props()

    globalThis.mlsEditorSession = Object.freeze({
        apiHost: document.location.host,
        planId,
        planName,
        unitId,
    })
    globalThis.serviceWorkerVersion = dev ? null : serviceWorkerVersion
</script>

<svelte:head>
    <base href={dev ? '/dev/ui/' : '/ui/'}>
    <style>
        html, body {
            height: 100%;
        }
    </style>
    <script type="module">
        import './flutter.js'

        _flutter.loader.loadEntrypoint({
            serviceWorker: {
                serviceWorkerVersion,
            },
            onEntrypointLoaded: function (engineInitializer) {
                document.oncontextmenu = (e) => e.preventDefault()
                engineInitializer.initializeEngine().then(function (appRunner) {
                    appRunner.runApp()
                })
            },
        })
    </script>
</svelte:head>
