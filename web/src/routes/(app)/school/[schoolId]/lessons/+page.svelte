<script lang="ts">
    import type {PageData} from './$types'

    interface LessonsPageProps {
        data: PageData
    }

    let {data}: LessonsPageProps = $props()
</script>

<h2>Lessons plans</h2>

<p>{data.lessonPlans}</p>
