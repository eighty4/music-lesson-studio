<script lang="ts">
    import Logo from '$lib/components/logo.svelte'

    interface HeaderProps {
        authenticated: boolean
    }

    const {authenticated}: HeaderProps = $props()
</script>

<header>
    <h1>
        <a href="/">
            <Logo size="2rem"/>
        </a>
        <a href="/">Music Lesson Studio</a>
    </h1>
    <nav></nav>
    <div class="actions">
        {#if authenticated}
            <form method="POST" action="/logout">
                <button class="logout button">Logout</button>
            </form>
        {:else}
            <a class="login button" href="/login">Sign in</a>
        {/if}
    </div>
</header>

<style>
    header {
        position: sticky;
        top: 0;
        height: 5rem;
        display: flex;
        justify-content: center;
        align-items: center;
        background: #f9f9f9;
        padding: 0 1.5rem;
    }

    h1 {
        font-weight: 700;
        font-size: 1.15rem;
    }

    nav {
        flex: 1;
    }

    .login {
        border: 1px solid #27ae60;
        background: #7eee93;
    }

    .logout {
        border: 1px solid #a397f1;
        background: #efadfd;
        cursor: pointer;
    }

    .button {
        border-radius: .5rem;
        color: #343;
        font-size: 1rem;
        padding: .25rem 1rem;
        text-decoration: none;
    }

</style>
