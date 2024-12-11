<script lang="ts">
    import Logo from '$lib/components/logo.svelte'
</script>

<header>
    <h1>
        <a href="/">
            <Logo/>
        </a>
        <a href="/">
            Music Lesson Studio
        </a>
    </h1>
</header>

<style>
    header {
        padding: 2rem 0;
    }

    header a {
        color: currentColor;
        text-decoration: none;
    }

    header a:hover {
        text-decoration: underline;
    }

    h1 {
        font-size: 1.75rem;
    }
</style>
