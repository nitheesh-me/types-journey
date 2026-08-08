<script lang="ts">
	/**
	 * A decision slide's two options.
	 *
	 * The deck is navigated as a decision tree: Down takes the branch, Right
	 * skips to the next question. reveal only nests two levels deep, so the
	 * tree is mapped onto its grid, and the contract holds inside a branch too.
	 * Every question slide renders this so the mapping is visible rather than
	 * something the reader has to remember.
	 */
	export let down: string;
	export let right: string;
</script>

<div class="choice">
	<div class="option take">
		<span class="key" aria-hidden="true">↓</span>
		<span class="label">{down}</span>
		<span class="hint">press Down</span>
	</div>
	<div class="option skip">
		<span class="key" aria-hidden="true">→</span>
		<span class="label">{right}</span>
		<span class="hint">press Right</span>
	</div>
</div>

<style>
	.choice {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.8em;
		margin-top: 1.2em;
		text-align: left;
	}
	.option {
		display: grid;
		grid-template-columns: auto 1fr;
		grid-template-areas:
			'key label'
			'key hint';
		align-items: center;
		gap: 0 0.6em;
		padding: 0.6em 0.8em;
		border: 2px solid var(--ctp-surface1);
		border-radius: 0.5em;
		background: var(--ctp-mantle);
	}
	.take {
		border-color: var(--ctp-green);
	}
	.skip {
		border-color: var(--ctp-surface2);
	}
	.key {
		grid-area: key;
		font-size: 1.4em;
		line-height: 1;
	}
	.take .key {
		color: var(--ctp-green);
	}
	.skip .key {
		color: var(--ctp-overlay1);
	}
	.label {
		grid-area: label;
		font-size: 0.55em;
		line-height: 1.25;
		color: var(--ctp-text);
	}
	.hint {
		grid-area: hint;
		font-family: system-ui, sans-serif;
		font-size: 0.32em;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--ctp-overlay0);
	}
</style>
