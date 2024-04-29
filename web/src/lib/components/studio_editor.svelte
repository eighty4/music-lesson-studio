<script>
    import {dev} from '$app/environment'
    const baseHref = dev ? '/dev/ui/' : '/ui/'
</script>

<svelte:head>
    <base href={baseHref}>
    <style>
        html, body {
            height: 100%;
        }
    </style>
    <script type="module">
        import './flutter.js'

        _flutter.loader.loadEntrypoint({
            serviceWorker: {
                serviceWorkerVersion: '427770547',
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
