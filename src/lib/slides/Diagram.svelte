<script lang="ts">
	import { renderMermaid } from '$lib/diagram/mermaid';
	import { flavour } from '$lib/theme/flavour';

	/** Mermaid source. */
	export let source: string;
	/** Auto-animate id, so a diagram can be built up across slides. */
	export let id: string | null = null;
	/**
	 * Height cap, in the slide's own design pixels (reveal lays out at
	 * 960x700 and scales the whole deck, so `vh` here would not track the
	 * slide at all).
	 */
	export let height: string = '420px';

	let svg = '';
	let error = '';

	// Re-rendered on flavour change so the diagram re-themes with the deck.
	$: void $flavour,
		renderMermaid(source).then((result) => {
			if (result.ok) {
				svg = result.svg;
				error = '';
			} else {
				svg = '';
				error = result.message;
			}
		});
</script>

<figure class="diagram" data-id={id} style="--diagram-height: {height}">
	{#if error}
		<pre class="diagram-error">{error}</pre>
	{:else}
		{@html svg}
	{/if}
</figure>

<style>
	.diagram {
		margin: 0 auto;
		max-height: var(--diagram-height);
	}
	/*
	 * Mermaid writes an inline `max-width` from its own measurement, which on a
	 * 960px slide leaves the diagram small enough that the labels are unreadable.
	 * Let it fill the slide instead; being SVG, the text scales with it.
	 */
	.diagram :global(svg) {
		width: 100%;
		max-width: 100% !important;
		max-height: var(--diagram-height);
		height: auto;
	}
	/* Mermaid sizes its own text; keep it clear of reveal's 40px base. */
	.diagram :global(.nodeLabel),
	.diagram :global(.edgeLabel),
	.diagram :global(.cluster-label) {
		font-size: 15px;
		line-height: 1.35;
	}
	.diagram-error {
		padding: 0.6em 0.8em;
		border-radius: 0.4em;
		background: color-mix(in srgb, var(--ctp-red), var(--ctp-crust) 80%);
		color: var(--ctp-red);
		font-size: 0.45em;
		text-align: left;
		white-space: pre-wrap;
	}
</style>
