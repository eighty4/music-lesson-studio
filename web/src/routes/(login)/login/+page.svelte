<script lang="ts">
    import {page} from '$app/stores'
    import Card from '$lib/components/card.svelte'
    import MessagePrompt from '$lib/components/message_prompt.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let loginButtonEnabled = $state(true)
    let loginError = $page.url.search.indexOf('error') !== -1
</script>

<main>
    <Card>
        <h1>Login!</h1>
        {#if loginError}
            <MessagePrompt type="error" message="Your login failed. Please try again."/>
        {/if}
        <form method="post" onsubmit={() => loginButtonEnabled = false}>
            <div class="form-field">
                <TextField name="email" label="Email" type="email" required value={$page.form?.email ?? ''}/>
            </div>
            <Button disabled={!loginButtonEnabled} type="submit" text="Send login email"/>
        </form>
    </Card>
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

    .form-field {
        margin: 2rem 0;
    }
</style>
