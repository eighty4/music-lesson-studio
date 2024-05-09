<script lang="ts">
    import {page} from '$app/stores'
    import StudioEditor from '$lib/components/studio_editor.svelte'
</script>

<StudioEditor planId={$page.params.planId}/>
