<script>
    import {page} from '$app/stores'

    // todo onkeyup validate and enable/disable button
    // todo onblur validate and show error message
    // todo $page.form status shows error message
</script>

<h1>Create a school</h1>

<form method="post">
    <label>
        Name
        <input type="text" name="name" required value={$page.form?.name ?? ''}/>
    </label>
    <button type="submit">Continue</button>
</form>
