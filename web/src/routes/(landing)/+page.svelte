<script>
    import Header from './header.svelte'
    import Footer from './footer.svelte'
</script>

<Header></Header>

<div class="content">
    <div class="feature">
        <h1>Home!</h1>
        <p>This app is great. Features. And users. Make money. Make music. Make money. Make music.</p>
        <p><a href="/dashboard">Dashboard</a></p>
        <p><a href="/signup">Create a school program</a></p>
        <p><a href="/lesson-plans">View lesson plans</a></p>
        <p><a href="/create-lesson-plan">Create a lesson plan</a></p>
        <p><a href="/studio">Demo the Studio UI</a></p>
    </div>

    <div class="feature">
        <h2>Design lesson plans</h2>
    </div>

    <div class="feature">
        <h2>Theme the experience for your school's personal branding</h2>
    </div>

    <div class="feature">
        <h2>Schedule classes</h2>
    </div>
</div>

<Footer></Footer>

<style>
    .feature {
        min-height: 40rem;
        display: flex;
        flex-direction: column;
        justify-content: center;
        width: 1280px;
        max-width: 80vw;
        margin: 0 auto;
    }
</style>
