<script lang="ts">
    interface ButtonProps {
        disabled: boolean
        text: string
        type?: 'submit'
    }

    let {disabled, text, type}: ButtonProps = $props()
</script>

<button type={type} disabled={disabled}>
    {text}
</button>

<style>
    button {
        min-width: 10rem;
        padding: 1rem;
        background: #7eee93;
        color: #343;
        border: 1px solid #27ae60;
        border-radius: .5rem;
        box-sizing: border-box;
        text-align: left;
        cursor: pointer;
        font-size: 1rem;
    }
</style>
