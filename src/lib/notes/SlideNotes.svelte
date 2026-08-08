<script lang="ts">
	import { onDestroy } from 'svelte';
	import { registerNotes, slideOf, unregister } from '$lib/slides/decor';

	/** Markdown shown under "Notes" — the written-out explanation. */
	export let notes: string = '';
	/** Markdown shown under "Presenter" — what you would say out loud. */
	export let presenter: string = '';

	let anchor: HTMLElement;
	let slide: Element | null = null;

	// The deck layout draws the panel; a slide only supplies its content.
	$: if (anchor) {
		slide = slideOf(anchor);
		if (slide) registerNotes(slide, { notes, presenter });
	}

	onDestroy(() => slide && unregister(slide));
</script>

<span class="notes-anchor" bind:this={anchor} aria-hidden="true"></span>

<style>
	.notes-anchor {
		display: none;
	}
</style>
