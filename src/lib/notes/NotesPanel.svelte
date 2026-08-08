<script lang="ts">
	import { notesOpen, notesTab } from './store';
	import { renderNotes } from './markdown';
	import { currentNotes } from '$lib/slides/decor';
	import { flavour } from '$lib/theme/flavour';

	// Both tabs are rendered whenever the slide (or flavour) changes, and the
	// inactive one is only hidden. Nothing is torn down on a tab switch, so
	// switching back cannot land on an empty panel.
	let notesHtml = '';
	let presenterHtml = '';

	$: source = $currentNotes;
	$: void $flavour,
		renderNotes(source?.notes).then((html) => {
			if (source === $currentNotes) notesHtml = html;
		});
	$: void $flavour,
		renderNotes(source?.presenter).then((html) => {
			if (source === $currentNotes) presenterHtml = html;
		});

	$: hasNotes = Boolean(source?.notes?.trim());
	$: hasPresenter = Boolean(source?.presenter?.trim());
</script>

<aside class="notes-panel" class:open={$notesOpen} aria-hidden={!$notesOpen}>
	<header>
		<div class="tabs" role="tablist">
			<button
				role="tab"
				aria-selected={$notesTab === 'notes'}
				class:active={$notesTab === 'notes'}
				on:click={() => notesTab.set('notes')}
			>
				Notes
			</button>
			<button
				role="tab"
				aria-selected={$notesTab === 'presenter'}
				class:active={$notesTab === 'presenter'}
				on:click={() => notesTab.set('presenter')}
			>
				Presenter
			</button>
		</div>
		<button class="close" title="Close notes" on:click={() => notesOpen.set(false)}>×</button>
	</header>

	<div class="body">
		<div class="tab" hidden={$notesTab !== 'notes'}>
			{#if hasNotes}
				{@html notesHtml}
			{:else}
				<p class="empty">No notes for this slide.</p>
			{/if}
		</div>
		<div class="tab" hidden={$notesTab !== 'presenter'}>
			{#if hasPresenter}
				{@html presenterHtml}
			{:else}
				<p class="empty">No presenter notes for this slide.</p>
			{/if}
		</div>
	</div>
</aside>

<style>
	/*
	 * Anchored to the viewport, not to reveal's scaled .slides box — a panel
	 * inside that box only slides out of the deck and stays visible beside it.
	 */
	.notes-panel {
		position: fixed;
		top: 0;
		right: 0;
		bottom: 0;
		z-index: 50;
		display: flex;
		flex-direction: column;
		width: min(26rem, 92vw);
		border-left: 1px solid var(--ctp-surface1);
		background: var(--ctp-mantle);
		color: var(--ctp-text);
		font-family: system-ui, sans-serif;
		font-size: 0.85rem;
		text-align: left;
		transform: translateX(100%);
		visibility: hidden;
		transition:
			transform 0.22s ease,
			visibility 0s linear 0.22s;
	}
	.notes-panel.open {
		transform: none;
		visibility: visible;
		box-shadow: -0.5rem 0 1.5rem rgb(0 0 0 / 0.22);
		transition:
			transform 0.22s ease,
			visibility 0s;
	}

	header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 0.5rem;
		padding: 0.6rem 0.8rem;
		border-bottom: 1px solid var(--ctp-surface0);
	}
	.tabs {
		display: flex;
		gap: 0.3rem;
	}
	.tabs button {
		padding: 0.25rem 0.7rem;
		border: 1px solid var(--ctp-surface1);
		border-radius: 0.4rem;
		background: transparent;
		color: var(--ctp-subtext0);
		font: inherit;
		cursor: pointer;
	}
	.tabs button:hover {
		color: var(--ctp-text);
	}
	.tabs button.active {
		background: var(--ctp-surface0);
		border-color: var(--ctp-mauve);
		color: var(--ctp-text);
	}
	.close {
		border: none;
		background: transparent;
		color: var(--ctp-subtext0);
		font-size: 1.4rem;
		line-height: 1;
		cursor: pointer;
	}
	.close:hover {
		color: var(--ctp-text);
	}

	.body {
		flex: 1;
		overflow-y: auto;
		padding: 0.9rem 1rem 2rem;
		line-height: 1.55;
	}
	.tab[hidden] {
		display: none;
	}
	.empty {
		color: var(--ctp-overlay0);
		font-style: italic;
	}

	/* Markdown output. */
	.body :global(h1),
	.body :global(h2),
	.body :global(h3) {
		margin: 1.1em 0 0.4em;
		color: var(--ctp-lavender);
		font-size: 1.15em;
		line-height: 1.3;
	}
	.body :global(.tab > :first-child) {
		margin-top: 0;
	}
	.body :global(p),
	.body :global(ul),
	.body :global(ol) {
		margin: 0 0 0.8em;
	}
	.body :global(ul),
	.body :global(ol) {
		padding-left: 1.2em;
	}
	.body :global(li) {
		margin-bottom: 0.25em;
	}
	.body :global(a) {
		color: var(--ctp-blue);
	}
	.body :global(strong) {
		color: var(--ctp-text);
	}
	.body :global(code) {
		padding: 0.1em 0.3em;
		border-radius: 0.3em;
		background: var(--ctp-surface0);
		color: var(--ctp-maroon);
		font-size: 0.92em;
	}
	.body :global(pre) {
		margin: 0 0 0.9em;
		padding: 0.7em 0.9em;
		overflow-x: auto;
		border-radius: 0.4em;
		background: var(--ctp-crust);
		font-size: 0.9em;
		line-height: 1.45;
	}
	.body :global(pre code) {
		padding: 0;
		background: none;
		color: var(--ctp-text);
	}
	.body :global(blockquote) {
		margin: 0 0 0.9em;
		padding: 0.1em 0.9em;
		border-left: 3px solid var(--ctp-mauve);
		color: var(--ctp-subtext1);
	}
	.body :global(table) {
		width: 100%;
		margin-bottom: 0.9em;
		border-collapse: collapse;
	}
	.body :global(th),
	.body :global(td) {
		padding: 0.3em 0.5em;
		border-bottom: 1px solid var(--ctp-surface0);
		text-align: left;
	}
	.body :global(hr) {
		border: none;
		border-top: 1px solid var(--ctp-surface0);
		margin: 1.2em 0;
	}
	.body :global(figure.diagram) {
		margin: 0 0 1em;
		text-align: center;
	}
	.body :global(figure.diagram svg) {
		max-width: 100%;
		height: auto;
	}
	.body :global(pre.diagram-error) {
		background: color-mix(in srgb, var(--ctp-red), var(--ctp-crust) 80%);
		color: var(--ctp-red);
		white-space: pre-wrap;
	}
</style>
