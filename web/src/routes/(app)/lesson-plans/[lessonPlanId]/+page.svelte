<script lang="ts">
    import type {PageData} from './$types'

    interface LessonPlanPageProps {
        data: PageData
    }

    let {data}: LessonPlanPageProps = $props()
</script>

<h3>Lesson units</h3>
{#each data.lessonUnits as lessonUnit}
    <p>
        <a href="/edit-lesson-plan/{lessonUnit.plan.id}/unit/{lessonUnit.id}">
            {lessonUnit.name ?? 'Unnamed'}
            {#if lessonUnit.instrument} - {lessonUnit.instrument}{/if}
            {lessonUnit.updated}
        </a>
    </p>
{/each}
