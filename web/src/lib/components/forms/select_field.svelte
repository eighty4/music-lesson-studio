<script lang="ts">
    interface TextFieldProps {
        helpText?: string
        label: string
        name: string
        required?: boolean
        options: Record<string, string>
    }

    let {label, name, helpText, required, options}: TextFieldProps = $props()
</script>

<label>
    <span class="name">{label}</span>
    <select name={name} required={required}>
        <option></option>
        {#each Object.entries(options) as [value, label]}
            <option value={value}>{label}</option>
        {/each}
    </select>
    {#if helpText}
        <span class="help">{helpText}</span>
    {:else}
        <span class="help">&nbsp;</span>
    {/if}
</label>

<style>
    label {
        display: flex;
        flex-direction: column;
        font-family: sans-serif;
    }

    .name {
        color: #000;
        font-size: 1.5rem;
        padding: 0 0 .35rem 1rem;
    }

    select {
        color: #111;
        background: #fafafa;
        border: 1px solid #888;
        width: 24rem;
        height: 3rem;
        font-size: 1.25rem;
        padding: 0 1rem;
        box-sizing: border-box;
        border-radius: .25rem;
    }

    .help {
        padding-left: 1rem;
    }
</style>
