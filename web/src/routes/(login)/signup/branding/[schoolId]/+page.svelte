<script lang="ts">
    // todo image upload (browser file selection interface, drag n drop, text input url)
    // todo constraints for filesize and content type
    // todo poc/eval libraries for selecting prominent colors
    // todo poc/eval for generating complimentary theme palettes from seed colors
    // todo color picker ui for tweaking generating colors
    // todo save theme data in music_lesson_studio.schools
    // todo redirect to /signup/faculty/{id}

    import {page} from '$app/stores'
    import {acceptedMimeTypes, uploadImageFile} from './uploadImage'

    let continueButtonEnabled: boolean = $state(false)
    let dragEnterCounter: number = $state(0)
    let fileInput: HTMLInputElement
    let previewBase64: string | null = $state(null)
    let previewAltText: string | null = $state(null)
    let imageFile: File | null = $state(null)
    let imageValidExtension: string = $state('')
    let imageValidFileSize: boolean = $state(false)

    function onDropFile(e: DragEvent) {
        e.preventDefault()
        dragEnterCounter--
        if (e.dataTransfer && e.dataTransfer.files.length) {
            const files = e.dataTransfer.files
            if (files.length === 1) {
                onSelectedFile(files[0])
            } else {
                alert('throw new TooManyFiles()')
            }
        }
    }

    function onFileInputLinkClick(e: Event) {
        e.preventDefault()
        fileInput.click()
    }

    // function onImgUrlLinkClick(e: Event) {
    //     e.preventDefault()
    //     alert('throw new UnsupportedOperationException()')
    // }

    function onFileInputChange() {
        if (fileInput.files) {
            onSelectedFile(fileInput.files[0])
        }
    }

    function onSelectedFile(file: File) {
        console.log(file)
        if (acceptedMimeTypes.includes(file.type)) {
            imageValidExtension = file.name.substring(file.name.lastIndexOf('.') + 1)
            imageValidFileSize = file.size < 500000
            const fileReader = new FileReader()
            fileReader.onload = () => {
                continueButtonEnabled = true
                imageFile = file
                previewAltText = `Preview '${file.name}'`
                previewBase64 = fileReader.result as string
            }
            fileReader.readAsDataURL(file)
        } else {
            alert('boo')
        }
    }

    function onFormButtonClick(e: Event) {
    }

    async function onFormSubmit(e: Event) {
        e.preventDefault()
        if (imageFile) {
            continueButtonEnabled = false
            await uploadImageFile($page.params.schoolId, imageFile, console.log)
            // todo
        }
    }
</script>

<main>
    <h1>Customize your school's branding</h1>
    <div class="img-select">
        <div class="file-drop"
             class:drag-hovering={!!dragEnterCounter}
             aria-hidden="true"
             ondrop={onDropFile}
             ondragover={(e) => e.preventDefault()}
             ondragenter={() => dragEnterCounter++}
             ondragleave={() => dragEnterCounter--}>
            <p>Drop your school logo here.</p>
        </div>
        <a class="activate-file-input-link" href={null} onclick={onFileInputLinkClick}>
            Select an image from your computer
        </a>
        <!--        <span>🔗 <a class="activate-img-url-link" href={null} onclick={onImgUrlLinkClick}>Import an image from a url</a></span>-->
        <input bind:this={fileInput}
               onchange={onFileInputChange}
               type="file"
               accept="image/jpeg,image/png,image/webp"
               style="display: none"/>
    </div>
    <div class="img-preview">
        {#if previewBase64}
            <img alt={previewAltText} src={previewBase64} style="width: 100%; height: 100%;"/>
            <div class="image-validations">
                <p style="color: green;">supported .{imageValidExtension} file</p>
                {#if imageValidFileSize}
                    <p style="color: green;">image smaller than 500kb</p>
                {:else}
                    <p style="color: red;">file must be smaller than 500kb</p>
                {/if}
            </div>
        {/if}
    </div>
    <div class="buttons">
        <form method="post" onsubmit={onFormSubmit}>
            <input type="hidden" name=""/>
            <button type="submit" disabled={!continueButtonEnabled} onclick={onFormButtonClick}>Continue</button>
        </form>
    </div>
</main>

<style>
    main {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        grid-template-rows: 5rem 1fr 5rem;
        grid-column-gap: 2rem;
        grid-row-gap: 2rem;
        padding: 2rem;
    }

    h1 {
        grid-area: 1 / 1 / 2 / 3;
    }

    .img-select {
        grid-area: 2 / 1 / 3 / 2;
    }

    .img-preview {
        grid-area: 2 / 2 / 3 / 3;
    }

    .buttons {
        grid-area: -1 / 1 / -2 / 3;
    }

    .img-select, .img-preview {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    /*.activate-img-url-link, */
    .activate-file-input-link {
        color: #0d419d;
        cursor: pointer;
        text-decoration: underline;
    }

    .file-drop {
        width: 100%;
        border: .2rem dashed rgb(255 150 0);
        background: rgba(27 31 36 / 10%);
        padding: 3rem;
        box-sizing: border-box;
        text-align: center;
        transition: all .1s ease-in-out;
    }

    .file-drop.drag-hovering {
        background: #7ee787;
        border-color: #2da44e;
    }
</style>
