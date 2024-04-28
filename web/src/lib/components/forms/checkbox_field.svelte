<script lang="ts">
    interface CheckboxFieldProps {
        label: string
        description?: string
        name: string
        checkedValue: string
        uncheckedValue: string
    }

    let {
        label,
        name,
        description,
        checkedValue,
        uncheckedValue,
    }: CheckboxFieldProps = $props()
</script>

<label>
    <span class="input-column">
        <input type="checkbox" name={name} value={checkedValue}>
        <input type="hidden" name={name} value={uncheckedValue}>
    </span>
    <span class="description-column">
        <span class="label">{label}</span>
        {#if description}
            <span class="description">{description}</span>
        {/if}
    </span>
</label>

<style>
    label {
        position: relative;
        display: flex;
        font-family: sans-serif;
    }

    .input-column input {
        margin: 0 1rem;
        height: 1.5rem;
        width: 1.5rem;
    }

    .description-column {
        flex: 1;
        display: flex;
        flex-direction: column;
    }

    .description-column span {
        display: block;
    }

    .description-column .label {
        font-size: 1.25rem;
    }

    .description-column .description {
        color: rgb(90, 90, 90);
        margin-top: .35rem;
    }
</style>
