<script lang="ts">
	import { LANGUAGE_MARKS } from './languageMarks';

	type Column = {
		/** Shown on the tab above the code, e.g. "Rust". */
		label: string;
		/** highlight.js language id, e.g. `rust`, `typescript`, `cpp`, `lean`. */
		language: string;
		code: string;
	};

	/** Two to four languages, side by side. */
	export let columns: Column[];
	/** Highlight one column as the point being made. */
	export let focus: string | null = null;

	// Four columns at 960px is ~220px each, so the type has to step down.
	const sizes: Record<number, string> = { 1: '0.5em', 2: '0.42em', 3: '0.36em', 4: '0.3em' };
	$: size = sizes[Math.min(columns.length, 4)] ?? '0.3em';
</script>

<div
	class="compare"
	style="--columns: {columns.length}; --code-size: {size}"
	role="group"
	aria-label="The same idea in {columns.map((c) => c.label).join(', ')}"
>
	{#each columns as column}
		<figure class="column" class:focused={focus === column.label}>
			<figcaption>
				<span class="name">{column.label}</span>
				{#if LANGUAGE_MARKS[column.language]}
					{@const mark = LANGUAGE_MARKS[column.language]}
					{#if mark.kind === 'path'}
						<svg class="mark" viewBox="0 0 24 24" role="img" aria-label={mark.label}>
							<path d={mark.d} fill="currentColor" />
						</svg>
					{:else}
						<span class="mark glyph" role="img" aria-label={mark.label}>{mark.glyph}</span>
					{/if}
				{/if}
			</figcaption>
			<pre><code
					data-trim
					data-noescape
					class="language-{column.language}">{column.code.trim()}</code></pre>
		</figure>
	{/each}
</div>

<style>
	.compare {
		display: grid;
		grid-template-columns: repeat(var(--columns), minmax(0, 1fr));
		gap: 0.5em;
		align-items: start;
		text-align: left;
	}
	.column {
		margin: 0;
		min-width: 0;
	}
	figcaption {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 0.5em;
		padding: 0.1em 0.5em;
		border: 1px solid var(--ctp-surface1);
		border-bottom: none;
		border-radius: 0.35em 0.35em 0 0;
		background: var(--ctp-mantle);
		color: var(--ctp-subtext0);
		font-family: system-ui, sans-serif;
		font-size: 0.38em;
		letter-spacing: 0.02em;
	}
	/* The mark sits in the corner of the column, identifying the language. */
	.mark {
		flex: none;
		width: 1.05em;
		height: 1.05em;
		opacity: 0.75;
	}
	.glyph {
		display: grid;
		place-items: center;
		font-size: 1.05em;
		line-height: 1;
	}
	.focused .mark {
		opacity: 1;
	}
	.focused figcaption {
		background: color-mix(in srgb, var(--ctp-mauve), var(--ctp-mantle) 72%);
		border-color: var(--ctp-mauve);
		color: var(--ctp-text);
	}

	.compare pre {
		width: 100%;
		margin: 0;
		border: 1px solid var(--ctp-surface1);
		border-radius: 0 0.35em 0.35em 0.35em;
		box-shadow: none;
		font-size: var(--code-size);
	}
	.focused pre {
		border-color: var(--ctp-mauve);
	}
	.compare :global(code) {
		max-height: 46vh;
		padding: 0.6em 0.7em;
		/* Long lines scroll rather than shrink the whole column. */
		overflow-x: auto;
		white-space: pre;
		word-wrap: normal;
	}
</style>
