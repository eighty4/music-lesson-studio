<script lang="ts">
    interface ButtonProps {
        href: string
        text: string
    }

    let {href, text}: ButtonProps = $props()
</script>

<a href={href}>{text}</a>

<style>
    a {
        height: 4rem;
        min-width: 10rem;
        padding-left: 1rem;
        padding-right: 2rem;
        color: #222;
        border: none;
        box-sizing: border-box;
        text-align: left;
        cursor: pointer;
        font-size: 1rem;
        text-decoration: none;
    }

    a:hover {
        text-decoration: underline;
    }
</style>
