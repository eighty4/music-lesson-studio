<script lang="ts">
    interface ButtonProps {
        disabled: boolean
        text: string
        type?: 'submit'
    }

    let {disabled, text, type}: ButtonProps = $props()
</script>

<button>{text}</button>

<style>
    button {
        height: 4rem;
        min-width: 10rem;
        padding-left: 1rem;
        padding-right: 2rem;
        background: #222;
        color: #eee;
        border: none;
        box-sizing: border-box;
        text-align: left;
        cursor: pointer;
        font-size: 1rem;
    }
</style>
