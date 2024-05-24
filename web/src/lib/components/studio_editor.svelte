<script lang="ts">
    import {dev} from '$app/environment'

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
</script>

<svelte:head>
    <base href={dev ? '/dev/ui/' : '/ui/'}>
    <style>
        html, body {
            height: 100%;
        }
    </style>
    <script>
        document.oncontextmenu = (e) => e.preventDefault()
    </script>
    <script src="flutter_bootstrap.js" async></script>
</svelte:head>
