<script lang="ts">
    import {page} from '$app/stores'
    import Card from '$lib/components/card.svelte'
    import Button from '$lib/components/forms/button.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    // todo onkeyup validate and enable/disable button
    // todo onblur validate and show error message
    // todo $page.form status shows error message

    let continueButtonEnabled = $state(true)
</script>

<main>
    <Card width="30rem">
        <h1>Create a school</h1>
        <form method="post" onsubmit={() => continueButtonEnabled = false}>
            <div class="form-field">
                <TextField name="name" label="Name" required value={$page.form?.name ?? ''}/>
            </div>
            <div class="form-field">
                <Button disabled={!continueButtonEnabled}
                        text="Continue"
                        type="submit"/>
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

    form {
        padding-top: 2rem;
    }

    .form-field + .form-field {
        margin-top: 2rem;
    }
</style>
