<script lang="ts">
    import type {Snippet} from 'svelte'

    interface CenteredProps {
        children: Snippet
    }

    let {children}: CenteredProps = $props()
</script>

<div>
    {@render children()}
</div>

<style>
    div {
        width: 80vw;
        margin-left: 10vw;
    }
</style>
