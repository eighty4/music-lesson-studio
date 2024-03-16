<script lang="ts">
    import type {PageData} from './$types'

    interface ClassesPageData {
        data: PageData
    }

    let {data}: ClassesPageData = $props()
</script>

<h1>Classes!</h1>

<p>{data.classes}!</p>
