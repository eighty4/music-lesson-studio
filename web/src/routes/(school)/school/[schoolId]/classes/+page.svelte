<script lang="ts">
    import type {PageData} from './$types'

    interface ClassesPageData {
        data: PageData
    }

    let {data}: ClassesPageData = $props()
</script>

<h2>Courses</h2>

<p>{data.classes}</p>
