<script lang="ts">
	import 'reveal.js/dist/reveal.css';
	import 'reveal.js/dist/theme/serif.css';
	import 'reveal.js/plugin/math/math.js';
	// Loaded after reveal's own theme so Catppuccin wins the colour rules.
	import '$lib/theme/reveal-catppuccin.css';
	import '$lib/theme/highlight-catppuccin.css';

	import Reveal            from 'reveal.js';
	import RevealHighlight   from 'reveal.js/plugin/highlight/highlight';
	import RevealNotes       from 'reveal.js/plugin/notes/notes';
	import RevealMath        from 'reveal.js/plugin/math/math';
	import RevealMarkdown    from 'reveal.js/plugin/markdown/markdown.js';
	import { onMount, onDestroy } from 'svelte';
	import { annotateWhenReady } from '$lib/slides/annotate';
	import { lean } from '$lib/slides/lean';
	import FlavourPicker from '$lib/theme/FlavourPicker.svelte';
	import NotesToggle from '$lib/notes/NotesToggle.svelte';
	import NotesPanel from '$lib/notes/NotesPanel.svelte';
	import SlideSprite from '$lib/slides/SlideSprite.svelte';
	import { showFor } from '$lib/slides/decor';

	let deck: ReturnType<typeof Reveal> | null = null;

	onMount(() => {
		deck = new Reveal({
			transitionSpeed: 'fast',
			highlight: {
				beforeHighlight: (hljs: { registerLanguage: (name: string, def: unknown) => void }) =>
					hljs.registerLanguage('lean', lean),
			},
			katex: {
				// `\htmlId` — which the annotations hang off — needs `trust`.
				trust: true,
				strict: false,
				macros: {
					'\\Prop':   '\\mathsf{Prop}',
					'\\Type':   '\\mathsf{Type}',
					'\\Sort':   '\\mathsf{Sort}',
					'\\True':   '\\mathsf{True}',
					'\\False':  '\\mathsf{False}',
					'\\Nat':    '\\mathbb{N}',
					'\\Int':    '\\mathbb{Z}',
					'\\Reduce': '\\triangleright',
				},
			},
			plugins: [
				RevealMarkdown,
				RevealHighlight,
				RevealMath.KaTeX,
				RevealNotes,
			],
		});
		// Annotations measure laid-out KaTeX output, so they can only be drawn
		// once the slide they live on is on screen and its formulas are typeset.
		deck.initialize().then(() => {
			if (!deck) return;
			deck.on('slidetransitionend', (event: { currentSlide: Element }) =>
				annotateWhenReady(event.currentSlide)
			);
			// The character and the notes panel are drawn outside the deck, so
			// they have to be told which slide is on screen.
			deck.on('slidechanged', (event: { currentSlide: Element }) => showFor(event.currentSlide));
			annotateWhenReady(deck.getCurrentSlide());
			showFor(deck.getCurrentSlide());
		});
	});

	onDestroy(() => {
		if (deck) {
			try {
				deck.destroy();
			} catch (e) {
				console.error('Failed to destroy Reveal deck:', e);
			}
			deck = null;
		}
		if (typeof document !== 'undefined') {
			document.documentElement.classList.remove('reveal-full-page');
			document.body.classList.remove('reveal-viewport');
		}
	});
</script>

<div class="reveal">
	<div class="slides">
		<slot />
	</div>
</div>

<SlideSprite />
<NotesPanel />
<FlavourPicker floating />
<NotesToggle />
