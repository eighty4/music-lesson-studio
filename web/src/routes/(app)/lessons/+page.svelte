<script lang="ts">
    import type {PageData} from './$types'

    export let data: PageData
</script>

<h1>Lessons!</h1>

<p>{data.lessonPlans}!</p>
