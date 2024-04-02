<script>
    import {page} from '$app/stores'
</script>

<h1>Create a lesson plan</h1>

<form method="post">
    <label>
        Name
        <input type="text" name="name" required value={$page.form?.name ?? ''}/>
    </label>
    <label>
        Instrument
        <select name="instrument" required>
            <option></option>
            <option value="banjo" selected={$page.form?.instrument === 'banjo'}>Banjo</option>
            <option value="guitar" selected={$page.form?.instrument === 'guitar'}>Guitar</option>
            <option value="ukulele" selected={$page.form?.instrument === 'ukulele'}>Ukulele</option>
        </select>
    </label>
    <button type="submit">Continue</button>
</form>
