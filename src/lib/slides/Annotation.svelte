<script lang="ts">
	// Labels a `\htmlId{target}{...}` group inside a KaTeX formula. The bracket
	// and arrow are drawn at runtime by `annotate.ts`, once the slide is shown
	// and KaTeX has laid the formula out.
	export let target: string;
	export let color: string = 'grey';
	export let left: boolean = true;
	export let below: boolean = false;
</script>

<div
	class="annotation"
	data-target={target}
	data-color={color}
	data-left={left || undefined}
	data-below={below || undefined}
>
	<slot />
</div>

<style>
	div.annotation {
		position: absolute;
		font-size: 0.6em;
	}
</style>
