<script lang="ts">
	import { base } from '$app/paths';
	import FlavourPicker from '$lib/theme/FlavourPicker.svelte';
	import type { PageData } from './$types';

	export let data: PageData;
	const { metadata, decks } = data;
</script>

<svelte:head>
	<title>{metadata.title}</title>
</svelte:head>

<main>
	<header>
		<h1>{metadata.title}</h1>
		<FlavourPicker />
	</header>

	{#each decks as deck}
		<article>
			<h2>
				{#if deck.lecture}<span class="lecture">Lecture {deck.lecture}</span>{/if}
				<a href="{base}/slides/{deck.slug}">{deck.title}</a>
			</h2>
			<p class="description">{deck.description}</p>

			<dl>
				{#if deck.handouts?.length}
					<dt>Handouts</dt>
					<dd>
						{#each deck.handouts as file, i}
							{#if i > 0}<span aria-hidden="true"> · </span>{/if}<a
								href="{base}/handout/{deck.slug}/{file}">{file}</a
							>
						{/each}
					</dd>
				{/if}
				{#if deck.assignment}
					<dt>Exercises</dt>
					<dd><a href="{base}/assignment/{deck.assignment}">{deck.assignment}</a></dd>
				{/if}
			</dl>

			{#if deck.source}
				<p class="source">
					Adapted from <a href={deck.source.url}>{deck.source.name}</a>, used under
					<a href={deck.source.licenseUrl}>{deck.source.license}</a>. Illustrations are original.
				</p>
			{/if}
		</article>
	{/each}
</main>

<style>
	main {
		max-width: 52rem;
		margin: 2rem auto 4rem;
		padding: 0 1rem;
		font-family: var(--serif);
		line-height: 1.5;
		color: var(--app-fg);
	}
	header {
		display: flex;
		flex-wrap: wrap;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		margin-bottom: 1.5rem;
	}
	h1 {
		margin: 0;
		color: var(--ctp-mauve);
	}
	article {
		padding: 1rem 0;
		border-top: 1px solid var(--app-line);
	}
	article h2 a {
		color: var(--ctp-lavender);
		text-decoration: none;
	}
	article h2 a:hover {
		text-decoration: underline;
	}
	article h2 {
		font-size: 1.2rem;
		margin: 0 0 0.25rem;
	}
	.lecture {
		display: inline-block;
		margin-right: 0.5rem;
		padding: 0.05rem 0.4rem;
		border: 1px solid var(--app-line);
		border-radius: 0.2rem;
		background: var(--app-panel);
		font-family: system-ui, sans-serif;
		font-size: 0.7rem;
		color: var(--app-muted);
		vertical-align: 0.15em;
	}
	.description {
		margin: 0 0 0.5rem;
	}
	dl {
		display: grid;
		grid-template-columns: max-content 1fr;
		gap: 0.15rem 0.75rem;
		margin: 0;
		font-size: 0.9rem;
	}
	dt {
		color: var(--app-muted);
	}
	dd {
		margin: 0;
	}
	.source {
		margin: 0.6rem 0 0;
		font-size: 0.85em;
		color: var(--app-muted);
	}
</style>
