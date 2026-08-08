<script lang="ts">
	// Shows one `--- snippet <key>` block lifted out of a handout file, so the
	// slide and the handout the audience is following can never drift apart.
	export let key: string;
	export let code: Record<string, string>;
	export let id: string | null = null;
	export let lines: string | null = null;
	export let language: string = 'lean';
	export let hasError: boolean = false;

	const edge_color = hasError ? 'var(--code-error)' : 'var(--code-plain)';
</script>

<pre data-id={id} style="--edge-color: {edge_color}">{#if key}<legend>{key}</legend>{/if}<code
		data-trim
		data-noescape
		data-auto-animate
		data-line-numbers={lines || null}
		class="language-{language}"
		style="white-space: pre-wrap">{code[key]}</code></pre>

<style>
	pre {
		border: 2px solid var(--edge-color);
	}
	legend {
		color: var(--edge-color);
		position: absolute;
		z-index: 2;
		border: 2px solid var(--edge-color);
		background-color: var(--ctp-base);
		left: 5%;
		top: -0.8em;
		padding-left: 5px;
		padding-right: 5px;
	}
</style>
