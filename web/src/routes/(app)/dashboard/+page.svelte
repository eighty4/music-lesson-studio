<script lang="ts">
    import type {PageData} from './$types'

    interface DashboardPageProps {
        data: PageData
    }

    let {data}: DashboardPageProps = $props()
</script>

<h1>Dashboard!</h1>

<p><a href="/logout">Logout</a></p>
<p><a href="/signup">Create a school program</a></p>
<p><a href="/lesson-plans">View lesson plans</a></p>
<p><a href="/lesson-plans/new">Create a lesson plan</a></p>
<p><a href="/ui">Demo the Studio UI</a></p>

{#if data.teacher.length > 0}
    <h3>Schools as teacher</h3>
    <ul>
        {#each data.teacher as school}
            <li><a href="/school/{school.id}">{school.name}</a></li>
        {/each}
    </ul>
{/if}
