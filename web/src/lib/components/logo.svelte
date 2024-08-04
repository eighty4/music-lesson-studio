<script lang="ts">
    interface LogoProps {
        size?: string
    }

    let {size = '2.5rem'}: LogoProps = $props()
</script>

<img alt="Music Lesson Studio logo" src="/Logo.svg" style={`--logo-size: ${size}`}/>

<style>
    img {
        width: var(--logo-size);
        vertical-align: middle;
        margin-right: 1rem;
    }
</style>
