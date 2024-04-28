<script lang="ts">
    import type {Snippet} from 'svelte'

    interface CardProps {
        children: Snippet
        width?: string
    }

    let {children, width = '26rem'}: CardProps = $props()
</script>

<div style="--card-width: {width}">
    {@render children()}
</div>

<style>
    div {
        padding: 1.5rem;
        width: var(--card-width);
    }
</style>
