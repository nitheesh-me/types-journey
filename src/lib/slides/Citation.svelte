<script lang="ts">
	/** A work being cited: paper, book, or chapter. */
	export let field: string = '';
	export let title: string;
	export let authors: string = '';
	export let venue: string = '';
	/** One short line worth quoting. */
	export let quote: string = '';
	export let href: string = '';
	/** Cover image, only where the licence allows redistribution. */
	export let cover: string = '';
	export let coverCredit: string = '';
</script>

<figure class="citation" class:with-cover={cover}>
	{#if cover}
		<img class="cover" src={cover} alt="Cover of {title}" />
	{/if}
	<figcaption>
		{#if field}<p class="field">{field}</p>{/if}
		<p class="title">{title}</p>
		{#if authors}<p class="authors">{authors}</p>{/if}
		{#if venue}<p class="venue">{venue}</p>{/if}
		{#if quote}<blockquote>{quote}</blockquote>{/if}
		{#if href}<p class="link"><a {href}>{href.replace(/^https?:\/\//, '')}</a></p>{/if}
		{#if coverCredit}<p class="credit">{coverCredit}</p>{/if}
	</figcaption>
</figure>

<style>
	.citation {
		display: grid;
		grid-template-columns: 1fr;
		gap: 1em;
		margin: 0;
		padding: 0.8em 1em;
		border: 1px solid var(--ctp-surface1);
		border-left: 4px solid var(--ctp-mauve);
		border-radius: 0.4em;
		background: var(--ctp-mantle);
		text-align: left;
	}
	.with-cover {
		grid-template-columns: auto 1fr;
		align-items: start;
	}
	.cover {
		width: 6em;
		border-radius: 0.2em;
		box-shadow: 0 0.1em 0.6em rgb(0 0 0 / 0.25);
	}
	figcaption {
		min-width: 0;
	}
	p {
		margin: 0 0 0.2em;
	}
	.field {
		color: var(--ctp-mauve);
		font-family: system-ui, sans-serif;
		font-size: 0.32em;
		letter-spacing: 0.12em;
		text-transform: uppercase;
	}
	.title {
		color: var(--ctp-text);
		font-size: 0.62em;
		line-height: 1.25;
	}
	.authors {
		color: var(--ctp-subtext0);
		font-size: 0.44em;
	}
	.venue {
		color: var(--ctp-overlay1);
		font-size: 0.4em;
	}
	blockquote {
		margin: 0.5em 0 0.3em;
		padding: 0 0 0 0.7em;
		border-left: 2px solid var(--ctp-surface2);
		background: none;
		box-shadow: none;
		color: var(--ctp-subtext1);
		font-size: 0.42em;
		font-style: italic;
		line-height: 1.4;
	}
	.link a {
		font-family: system-ui, sans-serif;
		font-size: 0.36em;
	}
	.credit {
		margin-top: 0.4em;
		color: var(--ctp-overlay0);
		font-size: 0.3em;
	}
</style>
