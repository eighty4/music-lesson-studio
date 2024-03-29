<script lang="ts">
    import type {PageData} from './$types'

    interface DashboardPageProps {
        data: PageData
    }

    let {data}: DashboardPageProps = $props()
</script>

<h1>Dashboard!</h1>

{#if data.teacher.length === 0 && data.student.length === 0}
    <p>Nothing</p>
    <p><a href="/signup">Create a school</a></p>
    <p><a href="/ui">Demo the Studio UI</a></p>
{:else}
    <ul>
        {#each data.teacher as school}
            <li><a href="/school/{school.id}">{school.name}</a></li>
        {/each}
    </ul>
{/if}

<p><a href="/logout">Logout</a></p>
