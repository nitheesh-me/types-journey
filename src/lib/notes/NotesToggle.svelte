<script lang="ts">
	import { onMount } from 'svelte';
	import { notesOpen } from './store';

	// `?` is reveal's own help overlay, so the shortcut is `i` for info.
	onMount(() => {
		const onKey = (event: KeyboardEvent) => {
			// Not every keydown target is an element — a synthetic event on
			// `window` has none, and `closest` would throw.
			const target = event.target instanceof Element ? event.target : null;
			if (target?.closest('input, textarea, [contenteditable]')) return;
			if (event.key === 'i' && !event.metaKey && !event.ctrlKey && !event.altKey) {
				notesOpen.update((open) => !open);
			}
		};
		window.addEventListener('keydown', onKey);
		return () => window.removeEventListener('keydown', onKey);
	});
</script>

<button
	class="notes-toggle"
	class:open={$notesOpen}
	aria-pressed={$notesOpen}
	title="Slide notes (i)"
	aria-label="Slide notes"
	on:click={() => notesOpen.update((open) => !open)}
>
	?
</button>

<style>
	.notes-toggle {
		position: fixed;
		top: 0.75rem;
		right: 0.75rem;
		z-index: 70;
		width: 2rem;
		height: 2rem;
		border: 1px solid var(--app-line);
		border-radius: 999px;
		background: var(--app-panel);
		color: var(--app-muted);
		font: 600 1rem/1 system-ui, sans-serif;
		cursor: pointer;
		opacity: 0.45;
		transition:
			right 0.22s ease,
			opacity 0.15s ease,
			color 0.15s ease;
	}
	.notes-toggle:hover,
	.notes-toggle:focus-visible {
		opacity: 1;
		color: var(--app-fg);
		border-color: var(--app-accent);
	}
	.notes-toggle.open {
		/* Step aside so the button does not sit on the open panel's header. */
		right: calc(min(26rem, 92vw) + 0.75rem);
		opacity: 1;
		color: var(--ctp-base);
		background: var(--app-accent);
		border-color: var(--app-accent);
	}
</style>
