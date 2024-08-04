<script lang="ts">
    import '@fontsource/montserrat/latin-400.css'
    import type {Snippet} from 'svelte'

    let {children}: {children: Snippet} = $props()
</script>

{@render children()}

<style>
    :global(html, body) {
        height: fit-content;
    }

    :global(body) {
        font-family: Montserrat, sans-serif;
    }

    :global(*) {
        margin: 0;
        padding: 0;
    }
</style>
