<script lang="ts">
	import '$lib/theme/catppuccin.css';
	import { onMount } from 'svelte';
	import { initFlavour } from '$lib/theme/flavour';

	// Keeps <html data-flavour> in step with the stored choice.
	onMount(initFlavour);
</script>

<slot />

<style>
	:global(html) {
		background: var(--app-bg);
	}
	:global(body) {
		margin: 0;
		background: var(--app-bg);
		color: var(--app-fg);
	}
	:global(html:not(.reveal-full-page)),
	:global(body:not(.reveal-viewport)) {
		overflow-y: auto;
	}
	:global(a) {
		color: var(--app-link);
	}
	:global(::selection) {
		background: var(--ctp-surface2);
		color: var(--ctp-text);
	}
</style>
