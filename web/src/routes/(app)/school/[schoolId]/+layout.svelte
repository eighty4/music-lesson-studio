<script lang="ts">
    import {page} from '$app/stores'
    import type {LayoutData} from './$types'

    interface LayoutProps {
        data: LayoutData
    }

    let {data}: LayoutProps = $props()
    let schoolId = $page.params.schoolId
</script>

<div id="app-layout">
    <header>
        <div class="school-header">
            <h1>{data.schoolName}</h1>
        </div>
    </header>

    <nav>
        <div>
            <div>Classes</div>
            <div><a href="/school/{schoolId}/classes">Courses</a></div>
            <div><a href="/school/{schoolId}/lessons">Lesson plans</a></div>
        </div>
        <div>
            <div>People</div>
            <div><a href="/school/{schoolId}/teachers">Teachers</a></div>
            <div><a href="/school/{schoolId}/students">Students</a></div>
        </div>
        <div>
            <div><a href="/school/{schoolId}/customize">Customize school</a></div>
        </div>
    </nav>

    <main>
        <slot/>
    </main>
</div>

<style>

</style>
