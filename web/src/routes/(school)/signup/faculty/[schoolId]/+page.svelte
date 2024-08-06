<script lang="ts">
    import {page} from '$app/stores'
    import Card from '$lib/components/card.svelte'
    import MessagePrompt from '$lib/components/message_prompt.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import ButtonLink from '$lib/components/forms/button_link.svelte'
    import CheckboxField from '$lib/components/forms/checkbox_field.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let continueButtonEnabled = $state(true)
</script>

<main>
    <Card width="30rem">
        <h1>Add a faculty member</h1>
        {#if $page.url.searchParams.has('added')}
            <MessagePrompt type="success" message="Invite email sent to {$page.url.searchParams.get('added')}"/>
        {/if}
        <form method="post" onsubmit={() => continueButtonEnabled = false}>
            <div class="form-field">
                <TextField name="name" label="Name" required value={$page.form?.name ?? ''}/>
            </div>
            <div class="form-field">
                <TextField name="email" label="Email" required value={$page.form?.email ?? ''} type="email"/>
            </div>
            <div class="form-field">
                <CheckboxField name="admin"
                               checkedValue="true"
                               uncheckedValue="false"
                               label="Is the teacher an admin?"
                               description="Admin users are able to update school branding, course schedules and invite other faculty"/>
            </div>
            <div class="form-field">
                <Button disabled={!continueButtonEnabled}
                        text={$page.url.searchParams.has('added') ? 'Add another' : 'Send invite'}
                        type="submit"/>
                <div class="button-link">
                    <ButtonLink href="/signup/courses/{$page.params.schoolId}"
                                text={$page.url.searchParams.has('added') ? 'Continue' : 'Skip this step'}/>
                </div>
            </div>
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

    form {
        margin-top: 2rem;
    }

    .form-field + .form-field {
        margin-top: 2rem;
    }

    .button-link {
        display: inline-block;
        margin-left: 1rem;
    }
</style>
