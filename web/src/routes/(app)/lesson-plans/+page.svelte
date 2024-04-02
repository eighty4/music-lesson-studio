<script lang="ts">
    import type {PageData} from './$types'

    interface LessonPlansPageProps {
        data: PageData
    }
    let {data}: LessonPlansPageProps = $props()
</script>

<h1>Lesson plans</h1>

{#if data.lessonPlans.length === 0}
    <p>Ya got nothin'.</p>
    <p><a href="/lesson-plans/new">Make a new lesson plan.</a></p>
{:else}
    <p><a href="/lesson-plans/new">Make a new lesson plan.</a></p>
    {#each data.lessonPlans as lessonPlan}
        <p><a href="/lesson-plans/{lessonPlan.id}">{lessonPlan.name} - {lessonPlan.instrument}</a></p>
    {/each}
{/if}
