<script lang="ts">
    interface TextFieldProps {
        helpText?: string
        label: string
        maxlength?: number
        name: string
        pattern?: string
        required?: boolean
        type?: 'text' | 'email' | 'password'
        value: string
    }

    let {label, maxlength, name, pattern, type = 'text', helpText, required}: TextFieldProps = $props()
    console.log(pattern)
</script>

<label>
    <span class="name">{label}</span>
    <input type={type} name={name} required={required} maxlength={maxlength} pattern={pattern}/>
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
    }

    .name {
        color: #000;
        font-size: 1.25rem;
        padding: 0 0 1rem 1rem;
    }

    input {
        color: #111;
        background: #fafafa;
        border: 1px solid #888;
        width: 24rem;
        height: 3rem;
        font-size: 1.25rem;
        padding-left: 1rem;
        box-sizing: border-box;
        border-radius: .25rem;
    }

    .help {
        font-size: .85rem;
        margin-top: .75rem;
        padding-left: 1rem;
    }
</style>
