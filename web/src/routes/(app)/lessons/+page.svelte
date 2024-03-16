<script lang="ts">
    import type {PageData} from './$types'

    interface LessonsPageProps {
        data: PageData
    }

    let {data}: LessonsPageProps = $props()
</script>

<h1>Lessons!</h1>

<p>{data.lessonPlans}!</p>
