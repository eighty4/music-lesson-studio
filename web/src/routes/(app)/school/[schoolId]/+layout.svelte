<script lang="ts">
    import {page} from '$app/stores'
    import type {LayoutData} from './$types'
    import type {Snippet} from 'svelte'

    interface LayoutProps {
        children: Snippet
        data: LayoutData
    }

    let {children, data}: LayoutProps = $props()
    let schoolId = $page.params.schoolId

    function isCurrentPage(pathSuffix: string): boolean {
        return $page.url.pathname.endsWith(pathSuffix)
    }
</script>

<div id="app-layout">
    <header>
        <!-- todo school logo -->
        <h1>{data.schoolName}</h1>
        <div class="space" aria-hidden="true"></div>
        <!-- todo user profile picture and user menu -->
        <a href="/logout">Logout</a>
    </header>
    <nav>
        <div class="nav-section">
            <div class="nav-header">Classes</div>
            <a class="nav-item" class:current={isCurrentPage('/classes')} href="/school/{schoolId}/classes">
                Courses
            </a>
            <a class="nav-item" class:current={isCurrentPage('/lessons')} href="/school/{schoolId}/lessons">
                Lesson plans
            </a>
        </div>
        <div class="nav-section">
            <div class="nav-header">People</div>
            <a class="nav-item" class:current={isCurrentPage('/teachers')} href="/school/{schoolId}/teachers">
                Teachers
            </a>
            <a class="nav-item" class:current={isCurrentPage('/students')} href="/school/{schoolId}/students">
                Students
            </a>
        </div>
        <div class="nav-section">
            <div class="nav-header">Admin</div>
            <a class="nav-item" class:current={isCurrentPage('/customize')} href="/school/{schoolId}/customize">
                Customize school
            </a>
        </div>
    </nav>
    <main>
        {@render children()}
    </main>
</div>

<style>
    .space {
        flex: 1;
    }

    #app-layout {
        --layout-background-color: rgb(250, 250, 250);
        --layout-border-color: #9dc1ed;
        --edge-padding: 2rem;
        --header-height: 5rem;
        --header-background-color: #cde1fd;
        --nav-background: rgb(245, 245, 245);
        --nav-width: 20vw;
        --nav-min-width: 12rem;
        --nav-max-width: 18rem;
        --nav-header-color: #456;
        --nav-item-background-color-active: rgb(240, 240, 240);
        --nav-item-border-color-active: rgb(200, 200, 200);
        --nav-item-color: #345;
        --nav-item-color-active: #222;
        flex: 1;
        display: grid;
        grid-template-rows: var(--header-height) 1fr min-content;
        grid-template-columns: clamp(var(--nav-min-width), var(--nav-width), var(--nav-max-width)) 1fr;
        grid-column-gap: 0;
        grid-row-gap: 0;
        min-height: 100vh;
        background: var(--layout-background-color);
    }

    header {
        position: sticky;
        top: 0;
        grid-area: 1 / 1 / 2 / 3;
        height: var(--header-height);
        box-sizing: border-box;
        border-bottom: 1px solid var(--layout-border-color);
        background: var(--header-background-color);
        display: flex;
        align-items: center;
        padding: 0 var(--edge-padding);
        z-index: 2;
    }

    h1 {
        font-size: 1.7rem;
        font-weight: bold;
    }

    nav {
        position: fixed;
        top: 0;
        left: 0;
        height: 100%;
        width: var(--nav-width);
        min-width: var(--nav-min-width);
        max-width: var(--nav-max-width);
        box-sizing: border-box;
        border-right: 1px solid var(--layout-border-color);
        padding: calc(var(--header-height) + var(--edge-padding)) var(--edge-padding);
        background: var(--nav-background);
    }

    .nav-section + .nav-section {
        margin-top: 1rem;
    }

    .nav-header {
        color: var(--nav-header-color);
        font-weight: 600;
        font-size: .9rem;
        margin-bottom: .75rem;
    }

    .nav-item {
        color: var(--nav-item-color);
        display: block;
        text-decoration: none;
        padding: .25rem .25rem .25rem .5rem;
        border: 1px solid transparent;
        border-radius: 5px;
        transition: all .2s ease-in-out;
    }

    .nav-item + .nav-item {
        margin-top: .25rem;
    }

    .nav-item.current, .nav-item:hover {
        color: var(--nav-item-color-active);
        padding: .5rem 1.5rem;
        border: 1px solid var(--nav-item-border-color-active);
        background: var(--nav-item-background-color-active);
    }

    .nav-item.current {
        cursor: default;
        border-right: 5px solid orangered;
        border-radius: 5px 0 0 5px
    }

    main {
        grid-area: 2 / 2 / 3 / 3;
        box-sizing: border-box;
        padding: var(--edge-padding);
        min-height: calc(100% - var(--header-height));
    }
</style>
