<script lang="ts">
    type PromptType = 'success' | 'error'

    interface MessagePromptProps {
        message: string
        type: PromptType
    }

    let {message, type}: MessagePromptProps = $props()

    const CONFIG: Record<PromptType, { color: string, svg: string }> = Object.freeze({
        error: {
            color: 'rgb(200, 40, 60)',
            svg: '/icons/material/error.svg',
        },
        success: {
            color: 'rgb(26, 160, 42)',
            svg: '/icons/material/task_alt.svg',
        },
    })

    let svgColor = $derived(CONFIG[type].color)
    let svgUrl = $derived(`url("${CONFIG[type].svg}")`)
</script>

<div class="prompt">
    <span class="icon" style="--mask-image-color: {svgColor}; --mask-image-url: {svgUrl}"></span>
    <p class="message">{message}</p>
</div>

<style>
    .prompt {
        display: flex;
        align-items: center;
    }

    .prompt .icon {
        mask: var(--mask-image-url) no-repeat 50%;
        width: 24px;
        aspect-ratio: 1/1;
        background: var(--mask-image-color);
    }

    .prompt .message {
        padding-left: .5rem;
    }
</style>
