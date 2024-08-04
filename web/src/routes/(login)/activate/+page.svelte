<script lang="ts">
    import {page} from '$app/stores'
    import Card from '$lib/components/card.svelte'
    import MessagePrompt from '$lib/components/message_prompt.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let buttonEnabled = $state(true)
    const onSubmit = () => buttonEnabled = false
</script>

<main>
    <Card>
        {#if $page.form?.success}
            <h1>Device activated!</h1>
            <p>Enjoy the MLS experience on your TV.</p>
        {:else}
            <h1>Device activation</h1>
            {#if $page.form?.error}
                <MessagePrompt type="error" message={$page.form?.error}/>
            {/if}
            <form method="post" onsubmit={onSubmit}>
                <div class="form-field">
                    <TextField name="token" label="Device token" required value=""/>
                </div>
                <Button disabled={!buttonEnabled} type="submit" text="Send device token"/>
            </form>
        {/if}
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
