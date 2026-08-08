<script lang="ts">
	export let id: string | null = null;
	export let lines: string | null = null;
	export let language: string = 'lean';
	export let category: 'example' | 'message' | 'ref' | 'terminal' = 'example';

	const categories = {
		example: { edge_color: 'transparent', heading: '' },
		message: { edge_color: 'var(--code-message)', heading: 'Message' },
		ref: { edge_color: 'var(--code-ref)', heading: 'Reference' },
		terminal: { edge_color: 'var(--code-terminal)', heading: 'Terminal' }
	};
	const { edge_color, heading } = categories[category];
</script>

<pre
	data-id={id}
	class:bordered={edge_color != 'transparent'}
	style="--edge-color: {edge_color}"
>{#if heading}<legend>{heading}</legend>{/if}<code
		data-trim
		data-noescape
		data-auto-animate
		data-line-numbers={lines || null}
		class="language-{language}"
		style="white-space: pre-wrap"><slot /></code></pre>

<style>
	pre.bordered {
		border: 2px solid var(--edge-color);
	}
	legend {
		position: absolute;
		z-index: 2;
		border: 2px solid var(--edge-color);
		background-color: var(--ctp-base);
		color: var(--edge-color);
		left: 5%;
		top: -0.8em;
		padding-left: 5px;
		padding-right: 5px;
	}
</style>
