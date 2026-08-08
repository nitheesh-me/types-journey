<script lang="ts">
	import { currentSprite } from './decor';
	import SpriteFigure from './SpriteFigure.svelte';

	// Keying on the drawing means a change of character plays as a hand-off:
	// the old one flies out to its edge while the new one flies in from its own.
	$: key = $currentSprite ? `${$currentSprite.file}:${$currentSprite.side}` : 'none';
</script>

{#key key}
	{#if $currentSprite}
		<SpriteFigure decor={$currentSprite} />
	{/if}
{/key}
