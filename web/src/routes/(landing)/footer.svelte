<footer>
    <p class="title"><img class="logo" alt="Music Lesson Studio logo" src="/Logo.svg"/> Music Lesson Studio</p>
    <div class="divider"></div>
    <div class="acceptance-speech">
        <p class="gratitude">
            Made with
            <svg class="heart" viewBox="0 0 24 24">
                <path d="M12 4.435c-1.989-5.399-12-4.597-12 3.568 0 4.068 3.06 9.481 12 14.997 8.94-5.516 12-10.929 12-14.997 0-8.118-10-8.999-12-3.568z"/>
            </svg>
            and open-source technologies.
        </p>
        <p class="gratitude">
            Thank you <a href="https://flutter.dev/">Flutter</a>,
            <a href="https://www.postgresql.org/">PostgreSQL</a>
            and <a href="https://kit.svelte.dev/">SvelteKit</a> developers.
        </p>
    </div>
</footer>

<style>
    footer {
        border-top: 1px solid #f1f1f1;
        background: #f9f9f9;
        color: #111;
    }

    .title {
        max-width: 1280px;
        width: 80%;
        margin: 0 auto;
        font-size: 1.5rem;
        padding: 5rem;
    }

    .logo {
        width: 2.5rem;
        vertical-align: middle;
        margin-right: 1rem;
    }

    .acceptance-speech {
        padding: 10rem;
    }

    .gratitude {
        text-align: center;
        letter-spacing: .01rem;
    }

    .gratitude a {
        color: #27ae60;
    }

    .gratitude + .gratitude {
        margin-top: 1rem;
    }

    .heart {
        display: inline-block;
        width: 1.7rem;
        fill: #f55d5c;
        vertical-align: middle;
    }

    .divider {
        max-width: 1280px;
        width: 80%;
        margin: 0 auto;
        height: 1px;
        background: #eee;
    }
</style>
