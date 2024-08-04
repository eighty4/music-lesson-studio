<script lang="ts">
    import {page} from '$app/stores'
    import AppHeader from '$lib/components/app_header.svelte'
    import MessagePrompt from '$lib/components/message_prompt.svelte'
    import PageCentered from '$lib/components/page_centered.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let buttonEnabled = $state(true)
    const onSubmit = () => buttonEnabled = false
</script>

<PageCentered>
    <AppHeader></AppHeader>
    <main>
        {#if $page.form?.success}
            <!-- todo device model -->
            <h2>Device activated!</h2>
            <p>Enjoy the MLS experience on your TV.</p>
        {:else}
            <h2>Activate the MLS app on your television</h2>
            {#if $page.form?.error}
                <MessagePrompt type="error" message={$page.form?.error}/>
            {/if}
            <form method="post" onsubmit={onSubmit}>
                <div class="form-field">
                    <TextField name="token" label="What is your device token?" required value="" pattern={'[a-z0-9]{6}'} helpText="The 6 character token from the TV app"/>
                </div>
                <Button disabled={!buttonEnabled} type="submit" text="Send device token"/>
            </form>
        {/if}
    </main>
</PageCentered>

<style>
    main {
        width: 80vw;
        margin-left: 10vw;
        margin-top: 10vh;
    }

    h2 {
        margin-bottom: 2rem;
    }

    .form-field {
        margin: 2rem 0;
    }
</style>
