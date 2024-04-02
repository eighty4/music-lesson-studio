<script lang="ts">
    import {page} from '$app/stores'
    import type {PageData} from './$types'

    interface LessonPlanPageProps {
        data: PageData
    }

    let {data}: LessonPlanPageProps = $props()
</script>

<h1>{data.name}</h1>
<p>{data.instrument}</p>

<h3>Lesson units</h3>
<p><a href="/lesson-plans/{$page.params.lessonPlanId}/add-unit">Add lesson unit</a></p>
<p>todo: load lesson units</p>

<h3>Classes</h3>
<p>todo: show current and past classes using lesson plan</p>
