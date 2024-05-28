<script lang="ts">
    import type {PageData} from './$types'

    interface LessonPlansPageProps {
        data: PageData
    }

    let {data}: LessonPlansPageProps = $props()
</script>

<h1>Lesson plans</h1>

{#if !data.lessonPlans.length}
    <p>Ya got nothin'.</p>
{/if}

<p><a href="/create-lesson-plan">Make a new lesson plan.</a></p>

{#if data.lessonPlans.length}
    {#each data.lessonPlans as lessonPlan}
        <p>
            <a href="/lesson-plans/{lessonPlan.id}">
                {lessonPlan.name ?? 'Unnamed'}
                {#if lessonPlan.instrument} - {lessonPlan.instrument}{/if}
                {lessonPlan.updated}
            </a>
        </p>
    {/each}
{/if}
