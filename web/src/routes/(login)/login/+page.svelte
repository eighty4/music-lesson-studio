<script lang="ts">
    import {page} from '$app/stores'
    import {isValidEmail} from '$lib/data/UserTypes'

    let loginButtonEnabled = $state(false)
    let emailInput: HTMLInputElement

    function onInputKeyUp() {
        loginButtonEnabled = isValidEmail(emailInput.value)
    }

    // todo onblur validate and show error message
    // todo $page.form status shows error message
</script>

<h1>Login!</h1>

<form method="post">
    <label>
        Email
        <input type="email"
               name="email"
               required
               bind:this={emailInput}
               onkeyup={onInputKeyUp}
               value={$page.form?.email ?? ''}/>
    </label>
    <button type="submit" disabled={!loginButtonEnabled}>Send login email</button>
</form>
