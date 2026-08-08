<script lang="ts">
	import { onDestroy } from 'svelte';
	import { registerSprite, slideOf, unregister } from './decor';

	export let fragment: boolean = false;
	export let category: 'program' | 'math' | 'metaprog' | 'kernel' = 'math';
	/** Which bottom corner of the screen the character stands in. */
	export let side: 'left' | 'right' | null = null;

	const roles = {
		program: { role: 'programmer', side: 'left', alt: 'The programmer', accent: 'var(--color-functional)' },
		math: { role: 'mathematician', side: 'right', alt: 'The mathematician', accent: 'var(--color-theorem)' },
		metaprog: { role: 'metaprogrammer', side: 'left', alt: 'The metaprogrammer', accent: 'var(--color-metaprog)' },
		kernel: { role: 'kernel', side: 'right', alt: 'The kernel programmer', accent: 'var(--color-kernel)' }
	} as const;

	// Intrinsic width/height of each drawing. The suffix is the direction it
	// looks, and each character was drawn with its own orientation.
	const ratios: Record<string, number> = {
		'programmer-left': 280 / 380,
		'programmer-right': 279 / 378,
		'mathematician-left': 295 / 372,
		'mathematician-right': 333 / 374,
		'metaprogrammer-left': 368 / 389,
		'metaprogrammer-right': 383 / 383,
		'kernel-left': 398 / 376,
		'kernel-right': 409 / 373
	};

	let anchor: HTMLElement;
	let slide: Element | null = null;

	$: role = roles[category];
	$: stands = side ?? role.side;
	// Stand in a corner looking back in at the slide.
	$: facing = stands === 'left' ? 'right' : 'left';
	$: file = `${role.role}-${facing}`;

	// The layout draws the character; this slide only says which one.
	$: if (anchor) {
		slide = slideOf(anchor);
		if (slide) {
			registerSprite(slide, {
				file,
				ratio: ratios[file],
				side: stands,
				accent: role.accent,
				alt: role.alt
			});
		}
	}

	onDestroy(() => slide && unregister(slide));
</script>

<div class="note {category}" class:fragment>
	<slot />
	<span class="anchor" bind:this={anchor} aria-hidden="true"></span>
</div>

<style>
	.note {
		position: relative;
		border-radius: 25px;
		border: 5px solid var(--note-accent);
		background-color: color-mix(in srgb, var(--note-accent), var(--ctp-base) 86%);
		padding: 20px;
		font-size: 0.7em;
	}
	.program {
		--note-accent: var(--color-functional);
	}
	.math {
		--note-accent: var(--color-theorem);
	}
	.metaprog {
		--note-accent: var(--color-metaprog);
	}
	.kernel {
		--note-accent: var(--color-kernel);
	}
	.anchor {
		display: none;
	}
</style>
