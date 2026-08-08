<script lang="ts">
	import 'reveal.js/dist/reveal.css';
	import 'reveal.js/dist/theme/serif.css';
	import 'reveal.js/plugin/math/math.js';
	// Loaded after reveal's own theme so Catppuccin wins the colour rules.
	import '$lib/theme/reveal-catppuccin.css';
	import '$lib/theme/highlight-catppuccin.css';

	import { onMount, onDestroy } from 'svelte';
	import { annotateWhenReady } from '$lib/slides/annotate';
	import { lean } from '$lib/slides/lean';
	import FlavourPicker from '$lib/theme/FlavourPicker.svelte';
	import NotesToggle from '$lib/notes/NotesToggle.svelte';
	import NotesPanel from '$lib/notes/NotesPanel.svelte';
	import SlideSprite from '$lib/slides/SlideSprite.svelte';
	import { showFor } from '$lib/slides/decor';

	let deck: any = null;

	onMount(() => {
		(async () => {
			const [
				{ default: Reveal },
				{ default: RevealHighlight },
				{ default: RevealNotes },
				{ default: RevealMath },
				{ default: RevealMarkdown }
			] = await Promise.all([
				import('reveal.js'),
				import('reveal.js/plugin/highlight/highlight'),
				import('reveal.js/plugin/notes/notes'),
				import('reveal.js/plugin/math/math'),
				import('reveal.js/plugin/markdown/markdown.js')
			]);

			deck = new Reveal({
				transitionSpeed: 'fast',
				highlight: {
					beforeHighlight: (hljs: any) =>
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

			await deck.initialize();
			if (!deck) return;
			deck.on('slidetransitionend', (event: any) =>
				annotateWhenReady(event.currentSlide)
			);
			deck.on('slidechanged', (event: any) => showFor(event.currentSlide));
			annotateWhenReady(deck.getCurrentSlide());
			showFor(deck.getCurrentSlide());
		})();
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
