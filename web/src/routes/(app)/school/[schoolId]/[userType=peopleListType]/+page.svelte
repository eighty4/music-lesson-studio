<script lang="ts">
    import type {PageData} from './$types'

    interface PeopleLookupProps {
        data: PageData
    }

    let {data}: PeopleLookupProps = $props()
</script>

{#if data.faculty}
    <h2>Teachers</h2>
    {#each data.faculty as person}
        <div class="teacher">
            <span class="name">{person.name}</span>
            <span class="email">{person.email}</span>
            <span class="role">{person.admin ? 'teacher+' : 'teacher'}</span>
        </div>
    {/each}
{/if}
{#if data.students}
    <h2>Students</h2>
    {#each data.students as person}
        <div>
            <span>{person.name}</span>
            <span>{person.email}</span>
        </div>
    {/each}
{/if}
