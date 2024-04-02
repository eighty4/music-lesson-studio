<script lang="ts">
    import {page} from '$app/stores'

    let continueButtonEnabled = $state(true)

    function onFormSubmit() {
        continueButtonEnabled = false
    }
</script>

<main>
    <h1>Add a faculty member</h1>
    {#if $page.url.searchParams.has('added')}
        <p>Invite email sent to {$page.url.searchParams.get('added')}</p>
    {/if}
    <form method="post" onsubmit={onFormSubmit}>
        <div>
            <label for="name">Name</label>
            <input id="name" type="text" name="name" required value={$page.form?.name ?? ''}/>
        </div>
        <div>
            <label for="email">Email</label>
            <input id="email" type="email" name="email" value={$page.form?.email ?? ''}/>
        </div>
        <div>
            <label for="admin">Admin</label>
            <input id="admin" type="checkbox" name="admin" checked={$page.form?.admin}/>
        </div>
        <button type="submit" disabled={!continueButtonEnabled}>
            {#if $page.url.searchParams.has('added')}
                Invite another
            {:else}
                Send invite
            {/if}
        </button>
    </form>
    <a href="/signup/courses/{$page.params.schoolId}">
        {#if $page.url.searchParams.has('added')}
            Continue
        {:else}
            Skip this step
        {/if}
    </a>
</main>

<style>
    main {
        width: 80vw;
        margin-left: 10vw;
        margin-top: 10vh;
    }
</style>
