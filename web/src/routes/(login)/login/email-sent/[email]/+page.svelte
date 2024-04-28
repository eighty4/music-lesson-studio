<script lang="ts">
    import {page} from '$app/stores'
</script>

<main>
    <h1>Login!</h1>

    <p>Email sent to <em>{$page.params.email}</em>.</p>

    <p>Check your email to continue logging in.</p>
</main>

<style>
    main {
        width: 80vw;
        margin-left: 10vw;
        margin-top: 10vh;
    }

    h1 {
        margin-bottom: 2rem;
    }

    p {
        margin: 1rem 0;
    }
</style>
