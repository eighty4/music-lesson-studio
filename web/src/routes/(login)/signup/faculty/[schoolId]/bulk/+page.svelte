<script lang="ts">
    // todo data entry for names and emails of teachers and admins
    // todo save to music_lesson_studio.teachers
    // todo send invite email to each teacher
    // todo redirect to /signup/classes/{id}

    import {afterNavigate} from '$app/navigation'

    const faculty: Array<boolean> = $state([true])
    let continueButtonEnabled = $state(true)
    let formElem: HTMLFormElement

    afterNavigate(() => formElem.reset())

    function onInputChange(e: Event) {
        const input = e.target as HTMLInputElement
        const i = getIndex(input)
        if (i === faculty.length - 1) {
            faculty.push(false)
        }
        updateInputsRequired(getIndex(e.target as HTMLInputElement))
    }

    function onInputBlur(e: Event) {
        updateInputsRequired(getIndex(e.target as HTMLInputElement))
    }

    function getIndex(input: HTMLInputElement): number {
        return parseInt(input.getAttribute('data-i')!, 10)
    }

    function updateInputsRequired(i: number) {
        faculty[i] = inputsHaveData(i)
    }

    function inputsHaveData(i: number): boolean {
        for (const input of formElem.querySelectorAll(`input[data-i="${i}"]`) as NodeListOf<HTMLInputElement>) {
            if (input.type === 'checkbox' && input.checked) {
                return true
            }
            if (input.type !== 'checkbox' && input.value.length) {
                return true
            }
        }
        return false
    }

    function onFormSubmit() {
        continueButtonEnabled = false
    }
</script>

<main>
    <h1>Add faculty members</h1>

    <div class="heading">
        <span>Name</span>
        <span>Email</span>
        <span>Admin</span>
    </div>

    <form method="post" bind:this={formElem} onsubmit={onFormSubmit}>
        {#each faculty as required, i}
            <div class="person">
                <input data-i={i}
                       type="text"
                       required={required}
                       name={`faculty[${i}][name]`}
                       onchange={onInputChange}
                       onblur={onInputBlur}/>
                <input data-i={i}
                       type="email"
                       required={required}
                       name={`faculty[${i}][email]`}
                       onchange={onInputChange}
                       onblur={onInputBlur}/>
                <input type="hidden"
                       name={`faculty[${i}][admin]`}
                       value="false"/>
                <input data-i={i}
                       type="checkbox"
                       name={`faculty[${i}][admin]`}
                       value="true"
                       onchange={onInputChange}
                       onblur={onInputBlur}/>
            </div>
        {/each}
        <button type="submit" disabled={!continueButtonEnabled}>Continue</button>
    </form>
</main>

<style>
    main {
        width: 80vw;
        margin-left: 10vw;
        margin-top: 10vh;
    }

    .heading {
        display: flex;
    }

    .heading span {
        flex: 1;
    }

    .person {
        display: flex;
    }

    .person input {
        flex: 1;
    }
</style>
