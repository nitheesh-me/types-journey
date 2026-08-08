<script lang="ts">
	import { flavour, FLAVOURS, FLAVOUR_LABELS, type FlavourChoice } from './flavour';

	/** `floating` parks the picker in a corner, for use over a slide deck. */
	export let floating: boolean = false;

	const options: { value: FlavourChoice; label: string }[] = [
		{ value: null, label: 'Auto' },
		...FLAVOURS.map((f) => ({ value: f as FlavourChoice, label: FLAVOUR_LABELS[f] }))
	];

	// Swatches are literal so each button previews its own flavour, not the
	// one currently applied.
	const swatches: Record<string, string[]> = {
		auto: ['#eff1f5', '#1e1e2e'],
		latte: ['#eff1f5', '#8839ef', '#40a02b'],
		frappe: ['#303446', '#ca9ee6', '#a6d189'],
		macchiato: ['#24273a', '#c6a0f6', '#a6da95'],
		mocha: ['#1e1e2e', '#cba6f7', '#a6e3a1'],
		contrast: ['#000000', '#ffffff', '#ffe14d']
	};
</script>

<div class="picker" class:floating role="group" aria-label="Colour flavour">
	{#each options as option}
		<button
			type="button"
			class:active={$flavour === option.value}
			aria-pressed={$flavour === option.value}
			title={option.label}
			on:click={() => flavour.set(option.value)}
		>
			<span class="swatch" aria-hidden="true">
				{#each swatches[option.value ?? 'auto'] as colour}
					<i style="background: {colour}"></i>
				{/each}
			</span>
			<span class="label">{option.label}</span>
		</button>
	{/each}
</div>

<style>
	.picker {
		display: flex;
		flex-wrap: wrap;
		gap: 0.3rem;
		font-family: system-ui, sans-serif;
		font-size: 0.75rem;
	}
	.picker.floating {
		/* Top-left: the notes button owns the top-right corner, reveal's
		   controls the bottom-right, and the characters the bottom corners. */
		position: fixed;
		left: 0.75rem;
		top: 0.75rem;
		z-index: 60;
		padding: 0.3rem;
		border: 1px solid var(--app-line);
		border-radius: 0.5rem;
		background: var(--app-panel);
		opacity: 0.35;
		transition: opacity 0.15s ease;
	}
	.picker.floating:hover,
	.picker.floating:focus-within {
		opacity: 1;
	}
	button {
		display: flex;
		align-items: center;
		gap: 0.35rem;
		padding: 0.25rem 0.45rem;
		border: 1px solid var(--app-line);
		border-radius: 0.4rem;
		background: var(--app-bg);
		color: var(--app-muted);
		font: inherit;
		cursor: pointer;
	}
	button:hover {
		color: var(--app-fg);
		border-color: var(--app-accent);
	}
	button.active {
		color: var(--app-fg);
		border-color: var(--app-accent);
		box-shadow: inset 0 0 0 1px var(--app-accent);
	}
	.swatch {
		display: inline-flex;
		border-radius: 999px;
		overflow: hidden;
		border: 1px solid var(--app-line);
	}
	.swatch i {
		display: block;
		width: 0.5rem;
		height: 0.75rem;
	}
	.floating .label {
		display: none;
	}
	.floating:hover .label,
	.floating:focus-within .label {
		display: inline;
	}
</style>
