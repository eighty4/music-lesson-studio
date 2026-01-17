<script lang="ts">
    import {page} from '$app/state'
    import AppHeader from '$lib/components/app_header.svelte'
    import PageCentered from '$lib/components/page_centered.svelte'

    const email = page.params.email
    const emailLink = resolveEmailLink(email)

    function resolveEmailLink(email?: string): string | undefined {
        if (email) {
            const domain = email.substring(email.indexOf('@') + 1)
            switch (domain) {
                case 'gmail.com':
                    return 'https://mail.google.com'
                case 'hotmail.com':
                case 'msn.com':
                case 'outlook.com':
                    return 'https://outlook.com'
            }
        }
    }
</script>

<PageCentered>
    <AppHeader/>
    <main>
        <h2>Email sent to <em>{page.params.email}</em></h2>

        <p>Check your email to continue logging in.</p>

        {#if emailLink}
            <p class="email-link"><a target="_blank" href={emailLink}>{emailLink}</a></p>
        {/if}
    </main>
</PageCentered>

<style>
    main {
        max-width: 26rem;
        margin: 20vh auto 0;
    }

    h2 {
        font-size: 1.5rem;
        letter-spacing: .015rem;
        margin-bottom: 4rem;
    }

    p {
        letter-spacing: .015rem;
    }

    p + p {
        margin-top: 2rem;
    }

    .email-link {
        letter-spacing: .04rem;
    }
</style>
