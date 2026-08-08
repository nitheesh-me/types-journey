import type { PageLoad } from './$types';

export type Attribution = {
	name: string;
	url: string;
	license: string;
	licenseUrl: string;
};

export type Deck = {
	/** Route segment under `/slides/`. */
	slug: string;
	title: string;
	description: string;
	/** Course lecture number, for decks that are one. */
	lecture?: string;
	/** Handout file names under `/handout/<slug>/`. */
	handouts?: string[];
	/** Exercise file name under `/assignment/`. */
	assignment?: string;
	/** Set when the deck is adapted from someone else's material. */
	source?: Attribution;
};

const cs99 = (path: string, name: string): Attribution => ({
	name,
	url: `https://web.stanford.edu/class/cs99/${path}`,
	license: 'CC BY-NC-SA 4.0',
	licenseUrl: 'https://creativecommons.org/licenses/by-nc-sa/4.0/'
});

const decks: Deck[] = [
	{
		slug: 'manual',
		title: 'Manual',
		description:
			'Reference deck for the slide components: code blocks, handout snippets, notes, and formula annotations.',
		handouts: ['handout.lean'],
		source: cs99('lecture/manual/', 'Stanford CS99 — lecture/manual')
	},
	{
		slug: 'should-i-learn-lean',
		lecture: '00',
		title: 'Should you learn Lean 4?',
		description:
			'A decision guide for engineers who have shipped software for a decade or two and have never been taught type theory. Navigated as a decision tree: Down takes a branch, Right skips it.',
		handouts: ['tour.lean']
	},
	{
		slug: 'introduction',
		lecture: '01',
		title: 'Types, and why Lean',
		description:
			'Why static typing came back, what a type is, and the argument that a type system is a machine for propagating obligations, ending in Lean with a CSV parser.',
		handouts: ['handout.lean', 'collections.lean', 'io.lean', 'csv.lean']
	},
	{
		slug: 'fp-control',
		lecture: '02',
		title: 'Control Flow, Recursion, Structures, Inductives',
		description:
			'If and match, function calls and currying, let bindings, structures, inductives, and the recursors underneath them.',
		handouts: ['handout.lean'],
		assignment: 'a02.lean',
		source: cs99('lecture/fp-control/', 'Stanford CS99 — Lecture 02')
	},
	{
		slug: 'fp-polymorphism',
		lecture: '03',
		title: 'Type Polymorphism, Classes and Instances',
		description:
			'Dependent types and universes, inductive families, type classes and instance search, and functors.',
		handouts: ['handout.lean', 'functor.lean'],
		assignment: 'a03.lean',
		source: cs99('lecture/fp-polymorphism/', 'Stanford CS99 — Lecture 03')
	},
	{
		slug: 'fp-monad',
		lecture: '04',
		title: 'Monads: Impurity and Fallibility',
		description:
			'Functor, Pure and Bind; do-notation; the Reader, State and Identity monads; loops; and monad transformers.',
		handouts: ['handout.lean', 'monad.lean'],
		assignment: 'a04.lean',
		source: cs99('lecture/fp-monad/', 'Stanford CS99 — Lecture 04')
	},
	{
		slug: 'fp-io',
		lecture: '05',
		title: 'IO, Exceptions, Concurrency',
		description:
			'The IO monad, exception handling, tasks, references and mutexes, channels, and setting up a Lake project.',
		handouts: [
			'handout.lean',
			'stdio.lean',
			'tasks.lean',
			'ref-race.lean',
			'ref-sync.lean',
			'cancel.lean',
			'channel.lean'
		],
		assignment: 'a05.lean',
		source: cs99('lecture/fp-io/', 'Stanford CS99 — Lecture 05')
	}
];

export const load: PageLoad = async (_) => {
	return {
		metadata: {
			title: 'LEAN Tutorial Material'
		},
		decks
	};
};
