<script lang="ts">
	import { base } from '$app/paths';
	import { fly } from 'svelte/transition';
	import { cubicOut } from 'svelte/easing';
	import type { SpriteDecor } from './decor';

	/**
	 * One character. The parent keys on the decor, so this instance's props
	 * never change — which is what makes the *out* transition fly toward the
	 * edge this character came from rather than the next one's.
	 */
	export let decor: SpriteDecor;

	// Far enough to clear the widest drawing at 25vh on a tall screen.
	const TRAVEL = 520;

	const reduced =
		typeof window !== 'undefined' &&
		window.matchMedia('(prefers-reduced-motion: reduce)').matches;

	$: x = decor.side === 'left' ? -TRAVEL : TRAVEL;
</script>

<span
	class="sprite {decor.side}"
	role="img"
	aria-label={decor.alt}
	style="--sprite-src: url('{base}/sprite/{decor.file}.png');
	       --sprite-ratio: {decor.ratio};
	       --sprite-accent: {decor.accent}"
	in:fly|global={{ x, duration: reduced ? 0 : 460, easing: cubicOut }}
	out:fly|global={{ x, duration: reduced ? 0 : 320, easing: cubicOut }}
></span>

<style>
	/*
	 * Pencil line art whose shading lives in the alpha channel, painted as a
	 * mask so one drawing re-inks itself for whichever flavour is active.
	 * Rendered by the deck layout, outside reveal's transformed .slides box,
	 * so it is anchored to the viewport corner and never shifts on layout.
	 */
	.sprite {
		position: fixed;
		bottom: 0;
		z-index: 20;
		display: block;
		height: 25vh;
		aspect-ratio: var(--sprite-ratio);
		opacity: 0.9;
		pointer-events: none;
		background-color: color-mix(in srgb, var(--sprite-accent), var(--ctp-text) 45%);
		-webkit-mask-image: var(--sprite-src);
		mask-image: var(--sprite-src);
		-webkit-mask-repeat: no-repeat;
		mask-repeat: no-repeat;
		-webkit-mask-position: bottom center;
		mask-position: bottom center;
		-webkit-mask-size: contain;
		mask-size: contain;
	}
	.sprite.left {
		left: 0.5rem;
	}
	.sprite.right {
		right: 0.5rem;
	}

	/* The characters only make sense on a full-size slide. */
	:global(.reveal.overview) .sprite,
	:global(.reveal-print) .sprite {
		display: none;
	}
</style>
