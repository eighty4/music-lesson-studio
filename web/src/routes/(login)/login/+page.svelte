<script lang="ts">
    import {page} from '$app/stores'
    import AppHeader from '$lib/components/app_header.svelte'
    import MessagePrompt from '$lib/components/message_prompt.svelte'
    import PageCentered from '$lib/components/page_centered.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let loginButtonEnabled = $state(true)
    let loginError = $page.url.search.indexOf('error') !== -1
</script>

<PageCentered>
    <AppHeader></AppHeader>
    <main>
        <h2>Sign in to your account</h2>
        {#if loginError}
            <div style="margin-top: 2rem">
                <MessagePrompt type="error" message="Your login failed. Please try again."/>
            </div>
        {/if}
        <form method="post" onsubmit={() => loginButtonEnabled = false}>
            <div class="form-field">
                <TextField name="email" label="What is your email?" type="email" required
                           value={$page.form?.email ?? ''}/>
                {#if $page.form?.invalidEmail}
                    <p style="color: #cc5060">Try again with a valid email.</p>
                {/if}
            </div>
            <Button disabled={!loginButtonEnabled} type="submit" text="Send login email"/>
        </form>
    </main>
</PageCentered>

<style>
    main {
        max-width: 26rem;
        margin: 20vh auto 0;
    }

    h2 {
        font-size: 1.5rem;
    }

    .form-field {
        margin: 4rem 0;
    }
</style>
