<script lang="ts">
    import type {LayoutData} from './$types'

    export let data: LayoutData
</script>

<header>
    <div class="school-header">
        <h1>{data.schoolName}</h1>
    </div>
    <nav>
        <div>
            <a href="/classes">Classes</a>
        </div>
        <div>
            <a href="/lessons">Lessons</a>
        </div>
        <div>
            <a href="/logout">Logout</a>
        </div>
    </nav>
</header>

<slot/>

<style>
    header {
        position: sticky;
        top: 0;
        left: 0;
        right: 0;
    }
</style>
