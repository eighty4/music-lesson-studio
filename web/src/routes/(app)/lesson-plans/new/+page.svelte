<script lang="ts">
    import {page} from '$app/stores'
    import Button from '$lib/components/forms/button.svelte'
    import Card from '$lib/components/card.svelte'
    import SelectField from '$lib/components/forms/select_field.svelte'
    import TextField from '$lib/components/forms/text_field.svelte'

    let continueButtonEnabled: boolean = $state(false)

    const instrumentOptions: Record<string, string> = {
        'banjo': 'Banjo',
        'guitar': 'Guitar',
        'ukulele': 'Ukulele',
    }
</script>

<main>
    <Card width="30rem">
        <h1>Create a lesson plan</h1>
        <form method="post" onsubmit={() => continueButtonEnabled = false}>
            <div class="form-field">
                <TextField name="name" label="Name" required value={$page.form?.name ?? ''}/>
            </div>
            <div class="form-field">
                <SelectField name="instrument" label="Instrument" options={instrumentOptions}/>
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
