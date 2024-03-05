<script lang="ts">
    let loginButtonEnabled = $state(false)
    let emailInput: HTMLInputElement

    function onInputKeyUp() {
        loginButtonEnabled = /.+@.+/.test(emailInput.value)
    }
</script>

<h1>Login!</h1>

<form method="post">
    <label>
        Email
        <input type="email" name="email" bind:this={emailInput} onkeyup={onInputKeyUp}/>
    </label>
    <button type="submit" disabled={!loginButtonEnabled}>Send login email</button>
</form>
