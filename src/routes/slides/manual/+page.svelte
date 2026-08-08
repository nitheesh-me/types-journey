<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import Note from '$lib/slides/Note.svelte';
	import Annotation from '$lib/slides/Annotation.svelte';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/manual/handout.lean?raw';
	import NotesSource from './notes.md?raw';

	const title = 'Manual';
	const snippets = parseSnippets(Handout);
	const note = noteLookup(NotesSource);

	// Kept as a string so Svelte does not read the TeX braces as expressions.
	const inference = String.raw`
		\[
		\frac{\htmlId{context}{\Gamma} \vdash \htmlId{value}{X} : \htmlId{type}{T}}
			{\htmlId{inference}{\Gamma,x:X \vdash x : X }}
		\]
	`;
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section>
	<Section>
		<h2>{title}</h2>
		<SlideNotes {...note('Title')} />
	</Section>
</section>

<section>
	<Section>
		<h2>Code</h2>
		<SlideNotes {...note('Code')} />
	</Section>
	<Section>
		<p>This is an example</p>
		<Code category="example">#check 1 + 2 + 3</Code>
		<SlideNotes {...note('Example')} />
	</Section>
	<Section>
		<p>This is a message</p>
		<Code category="message">[0, 1, 2]</Code>
		<SlideNotes {...note('Message')} />
	</Section>
	<Section>
		<p>This is a reference</p>
		<Code category="ref">{`
class Functor (f : Type u → Type v) : Type (max (u+1) v) where
  /-- If \`f : α → β\` and \`x : F α\` then \`f <$> x : F β\`. -/
  map : {α β : Type u} → (α → β) → f α → f β
`}</Code>
		<SlideNotes {...note('Reference')} />
	</Section>
	<Section>
		<p>This is a terminal command</p>
		<Code category="terminal" language="sh">lake build</Code>
		<SlideNotes {...note('Terminal')} />
	</Section>
	<Section>
		<p>This is an excerpt from the handout. Follow along!</p>
		<CodeSnippet lines="true" code={snippets} key="Function" />
		<SlideNotes {...note('Snippet')} />
	</Section>
</section>

<section>
	<Section>
		<h2>Notes</h2>
		<SlideNotes {...note('Notes')} />
	</Section>
	<Section>
		<Note category="program">This is a program note.</Note>
		<SlideNotes {...note('Program note')} />
	</Section>
	<Section>
		<Note category="math">This is a math note.</Note>
		<SlideNotes {...note('Math note')} />
	</Section>
	<Section>
		<Note category="metaprog">This is a metaprogramming note.</Note>
		<SlideNotes {...note('Metaprog note')} />
	</Section>
	<Section>
		<Note category="kernel">This is a kernel note.</Note>
		<SlideNotes {...note('Kernel note')} />
	</Section>
</section>

<section>
	<h3 style="margin-bottom: 2em">Annotations</h3>
	{inference}
	<Annotation target="context" color="var(--ctp-green)" left>Context</Annotation>
	<Annotation target="value" color="var(--ctp-blue)" left>Value</Annotation>
	<Annotation target="type" color="var(--ctp-peach)" left={false}>Type</Annotation>
	<Annotation target="inference" color="var(--ctp-overlay1)" below left>
		Inference. This text is very long
	</Annotation>
	<SlideNotes {...note('Annotations')} />
</section>
