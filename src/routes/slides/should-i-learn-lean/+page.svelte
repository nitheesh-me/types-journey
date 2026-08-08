<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import CodeCompare from '$lib/slides/CodeCompare.svelte';
	import Choice from '$lib/slides/Choice.svelte';
	import Diagram from '$lib/slides/Diagram.svelte';
	import Note from '$lib/slides/Note.svelte';
	import { base } from '$app/paths';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Tour from '$handouts/should-i-learn-lean/tour.lean?raw';
	import NotesSource from './notes.md?raw';
	import * as cmp from './compare';

	const title = 'Should you learn Lean 4?';
	const t = parseSnippets(Tour);
	const note = noteLookup(NotesSource);

	const howToRead = `
flowchart LR
  Q1["A question"] -->|"Right: skip it"| Q2["The next question"]
  Q1 -->|"Down: take it"| L["The answer<br/>5 to 10 slides"]
  L -->|"Right: back out"| Q2
`;

	// One shared `caught` node: eight boxes in a row across 960px leaves the
	// labels too small to read from the back of a room.
	const nets = `
flowchart LR
  B["A bug you<br/>just wrote"] --> L{"Linter"}
  L -->|"style"| C["caught"]
  L -->|"else"| T{"Tests"}
  T -->|"a case you<br/>thought of"| C
  T -->|"else"| Y{"Type<br/>checker"}
  Y -->|"a case you<br/>forgot"| C
  Y -->|"else"| P{"Proof"}
  P -->|"the rest"| C
  P -->|"else"| S["ships"]
`;
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<!-- ══════════════ 0. Title and the contract ══════════════ -->
<section data-transition="zoom">
	<Section>
		<h2>{title}</h2>
		<p><small>A guide for people who have been shipping software for a while</small></p>
		<Choice down="Show me how this works" right="Skip ahead, first question" />
		<SlideNotes {...note('Should you learn Lean 4?')} />
	</Section>

	<Section>
		<h3>How to read this</h3>
		<p>This deck is a decision tree. Two keys, and they mean the same thing everywhere.</p>
		<Diagram source={howToRead} height="240px" />
		<ul class="tight">
			<li><b>Down</b> takes the branch you are being offered</li>
			<li><b>Right</b> skips it and moves to the next question</li>
		</ul>
		<SlideNotes {...note("How to read this")} />
	</Section>

	<Section>
		<h3>So you can leave early</h3>
		<p>
			Answer a couple of questions, read the branch that matches your situation, and stop. Nothing
			later depends on anything you skipped.
		</p>
	</Section>

</section>

<!-- ══════════════ 1. Catchable bugs ══════════════ -->
<section>
	<Section>
		<h3>Have you ever shipped a bug a computer could have caught?</h3>
		<p>Not a hard bug. An obvious one, in hindsight.</p>
		<Choice down="Yes, and it still stings" right="No, next question" />
		<SlideNotes {...note("Have you ever shipped a bug a computer could have caught?")} />
	</Section>

	<Section>
		<h3>Which ones were catchable</h3>
		<p>
			Every tool you already use is a net with a particular mesh. The question is what falls through
			each of them.
		</p>
	</Section>

	<Section>
		<h3>Four nets</h3>
		<Diagram source={nets} height="380px" />
		<SlideNotes {...note("Four nets")} />
	</Section>

	<Section>
		<h3>What each one stops</h3>
		<table class="grid">
			<thead>
				<tr><th>Net</th><th>Catches</th><th>Misses</th></tr>
			</thead>
			<tbody>
				<tr><td>Linter</td><td>Style, shadowing, unused things</td><td>Anything about meaning</td></tr>
				<tr><td>Tests</td><td>The cases you thought of</td><td>The cases you did not</td></tr>
				<tr><td>Type checker</td><td>Whole classes of case, whether or not you thought of them</td><td>Anything you did not put in a type</td></tr>
				<tr><td>Proof</td><td>Everything the statement covers</td><td>A statement that was wrong</td></tr>
			</tbody>
		</table>
	</Section>

	<Section>
		<h3>The interesting gap</h3>
		<p>
			Tests are limited by your imagination. A type checker is not: it works through the cases
			mechanically, including the ones you would never have listed.
		</p>
		<p class="fragment">That difference is most of the argument for the rest of this deck.</p>
		<SlideNotes {...note("The interesting gap")} />
	</Section>

	<Section>
		<h3>Where your current tools stop</h3>
		<p>
			If your language checks types at all, you already own the third net. The question is how fine
			its mesh is, and that varies enormously between languages that all call themselves typed.
		</p>
	</Section>

	<Section>
		<h3>Being honest about it</h3>
		<p>Plenty of bugs are none of these.</p>
		<ul>
			<li>The feature was not what the customer wanted</li>
			<li>It was fast enough locally and not in production</li>
			<li>Two things happened at once and you had not thought about that</li>
		</ul>
		<p class="fragment">No type system saves you from those. Do not let anyone tell you otherwise.</p>
		<SlideNotes {...note("Being honest about it")} />
	</Section>
</section>

<!-- ══════════════ 2. Invariants in comments ══════════════ -->
<section>
	<Section>
		<h3>Does your code carry comments like "must not be empty"?</h3>
		<p>Or "caller must check first", or "only call this after init".</p>
		<Choice down="That is my code, yes" right="No, next question" />
		<SlideNotes {...note("Does your code carry comments like \"must not be empty\"?")} />
	</Section>

	<Section>
		<h3>Then the comment is doing the work</h3>
		<p>
			Something must be true for the function to be correct, and the only thing enforcing it is a
			sentence in English that nothing reads.
		</p>
	</Section>

	<Section>
		<h3>The usual shape of it</h3>
		<CodeCompare columns={cmp.inComment} focus="The shape" />
	</Section>

	<Section>
		<h3>Why the left one fails eventually</h3>
		<ul>
			<li>The comment is not checked, so it drifts from the code</li>
			<li>New callers never read it</li>
			<li>The failure surfaces far away from the cause</li>
		</ul>
	</Section>

	<Section>
		<h3>What the right one changed</h3>
		<p>
			It did not add a check. It changed the shape of the data so that the bad case cannot be
			built, and the function has nothing left to fail on.
		</p>
		<SlideNotes {...note("What the right one changed")} />
	</Section>

	<Section>
		<h3>The same thing in Lean</h3>
		<CodeSnippet code={t} key="No Empty Case" />
	</Section>

	<Section>
		<h3>Now the names</h3>
		<p>
			The thing that had to be true is an <b>invariant</b>. Moving it out of a comment and into the
			shape of the data is called making illegal states unrepresentable.
		</p>
		<p class="fragment">You have just met the central idea of the whole course.</p>
		<SlideNotes {...note("Now the names")} />
	</Section>

	<Section>
		<h3>When it does not work</h3>
		<p>
			Some invariants relate two fields, like a start time that must not be after an end time. You
			cannot enumerate your way out of that one; you have to change what you store.
		</p>
		<Note category="math">
			Lecture 01 works that example through properly. It is the honest limit of the technique.
		</Note>
		<SlideNotes {...note("When it does not work")} />
	</Section>
</section>

<!-- ══════════════ 3. Forgotten cases ══════════════ -->
<section>
	<Section>
		<h3>When a thing can be one of several, does your language make you handle all of them?</h3>
		<p>A payment is a card, a transfer, or account credit. What happens if you forget one?</p>
		<Choice down="Show me the difference" right="No, next question" />
		<SlideNotes {...note("When a thing can be one of several, does your language make you handle all of them?")} />
	</Section>

	<Section>
		<h3>The same forgotten case, four ways</h3>
		<CodeCompare columns={cmp.exhaustive} focus="Rust" />
	</Section>

	<Section>
		<h3>Two of those shipped a bug</h3>
		<p>
			The first two compile and run. They return the wrong answer quietly, which is the worst kind
			of wrong.
		</p>
		<SlideNotes {...note("Two of those shipped a bug")} />
	</Section>

	<Section>
		<h3>What the last one did</h3>
		<p>
			It did not find a bug by being clever. It knew there were three possibilities, saw two
			answers, and refused.
		</p>
	</Section>

	<Section>
		<h3>In Lean</h3>
		<CodeSnippet code={t} key="Every Case Answered" />
	</Section>

	<Section>
		<h3>And when a fourth appears</h3>
		<CodeSnippet code={t} key="Adding A Case" />
		<p>Every place that has to decide what a voucher means stops compiling until you decide.</p>
	</Section>

	<Section>
		<h3>Now the names</h3>
		<p>
			Each possibility is a <b>case</b>. Being made to answer all of them is exhaustive pattern
			matching, and it is the single most useful thing in this deck.
		</p>
		<SlideNotes {...note("Now the names#2")} />
	</Section>

	<Section>
		<h3>Does your language do this?</h3>
		<table class="grid">
			<thead><tr><th>Yes, mostly</th><th>No, or only if you ask</th></tr></thead>
			<tbody>
				<tr>
					<td>Rust, Swift, Kotlin, TypeScript, Scala, OCaml, Haskell, Java 21+</td>
					<td>Go, Python, Ruby, C, C++, JavaScript, older Java</td>
				</tr>
			</tbody>
		</table>
		<p class="fragment">
			If you are in the left column, you already have the most valuable half of this and may not
			need Lean at all.
		</p>
		<SlideNotes {...note("Does your language do this?")} />
	</Section>
</section>

<!-- ══════════════ 4. Fighting the compiler ══════════════ -->
<section>
	<Section>
		<h3>Have you ever fought the compiler and thought it was paperwork?</h3>
		<p>Argued with it, added a cast to shut it up, and moved on.</p>
		<Choice down="Frequently" right="No, next question" />
		<SlideNotes {...note("Have you ever fought the compiler and thought it was paperwork?")} />
	</Section>

	<Section>
		<h3>It was trying to hand you a list</h3>
		<p>
			Almost every time a type checker refuses, it is because it knows about a situation you have
			not said what to do about.
		</p>
	</Section>

	<Section>
		<h3>What the argument is usually about</h3>
		<ul>
			<li>A value that might not be there, and you have not said what happens if it is not</li>
			<li>A case you did not answer</li>
			<li>Two things you are treating as the same thing that are not</li>
		</ul>
		<p class="fragment">Those are all the same complaint: you owe it a decision.</p>
	</Section>

	<Section>
		<h3>The reframe</h3>
		<p class="big">Not an adversary. A to-do list you did not write.</p>
		<SlideNotes {...note("The reframe")} />
	</Section>

	<Section>
		<h3>When the complaint is fair</h3>
		<p>Sometimes it really is paperwork, and it is worth knowing when you are right:</p>
		<ul>
			<li>The error message describes the symptom and not the cause</li>
			<li>You have to restate things the checker could have worked out</li>
			<li>There is an escape hatch everyone uses, so the guarantee is fiction</li>
		</ul>
		<SlideNotes {...note("When the complaint is fair")} />
	</Section>

	<Section>
		<h3>What a good one feels like</h3>
		<p>
			You change something, and it tells you the six places that now need a decision. You make six
			decisions. It goes quiet. That is the whole loop.
		</p>
	</Section>

	<Section>
		<h3>Why this matters more than any feature</h3>
		<p>
			If you keep the adversary model, no type system will ever be worth its cost to you. If you
			take the to-do list model, a better one starts to look like a better colleague.
		</p>
		<Note category="program">
			Lecture 01 makes this precise: a type system relates the places you produce values to the
			places you consume them, and carries the obligations along.
		</Note>
	</Section>
</section>

<!-- ══════════════ 5. Cost of being wrong ══════════════ -->
<section>
	<Section>
		<h3>Is being wrong expensive where you work?</h3>
		<p>Money, safety, or a headline. Not just an apologetic changelog entry.</p>
		<Choice down="Yes, expensive" right="No, next question" />
		<SlideNotes {...note("Is being wrong expensive where you work?")} />
	</Section>

	<Section>
		<h3>Then some of this is already justified</h3>
		<p>
			The cost of getting it wrong is what decides how much effort is worth spending, and the
			answer differs by two orders of magnitude between one team and another.
		</p>
	</Section>

	<Section>
		<h3>Where it demonstrably pays</h3>
		<ul>
			<li>Money that moves: ledgers, settlement, pricing</li>
			<li>Cryptography and anything implementing a protocol</li>
			<li>Compilers, interpreters, query planners</li>
			<li>Distributed protocols, consensus, replication</li>
			<li>Safety-critical: avionics, automotive, medical</li>
			<li>Access control and infrastructure configuration</li>
		</ul>
	</Section>

	<Section>
		<h3>People actually do this</h3>
		<ul>
			<li><b>AWS</b> formalised its Cedar authorization language in Lean</li>
			<li><b>CompCert</b>, a verified C compiler, in Coq</li>
			<li><b>seL4</b>, a verified microkernel, in Isabelle</li>
			<li><b>Fiat-Crypto</b> generates verified field arithmetic used in BoringSSL</li>
			<li><b>AlphaProof</b> used Lean as its checking substrate</li>
		</ul>
		<p class="fragment">Note how few of these verify a whole system.</p>
		<SlideNotes {...note("People actually do this")} />
	</Section>

	<Section>
		<h3>What gets verified in practice</h3>
		<p>
			Not the product. A specification, a protocol, a policy engine, a compiler pass: something with
			a crisp contract and a high cost of being wrong.
		</p>
	</Section>

	<Section>
		<h3>Three tiers of effort</h3>
		<table class="grid">
			<thead><tr><th>Tier</th><th>Effort</th><th>Buys you</th></tr></thead>
			<tbody>
				<tr><td>Better shapes for your data</td><td>Days</td><td>Whole classes of bug become unrepresentable</td></tr>
				<tr><td>Invariants the checker enforces</td><td>Weeks</td><td>The rules hold by construction</td></tr>
				<tr><td>Proofs about behaviour</td><td>Months</td><td>A guarantee over every input</td></tr>
			</tbody>
		</table>
	</Section>

	<Section>
		<h3>Where the curve bends</h3>
		<p>
			The first tier is nearly free and most teams never finish it. The third is expensive and
			almost nobody needs it everywhere. Most of the value is in the first two.
		</p>
		<SlideNotes {...note("Where the curve bends")} />
	</Section>

	<Section>
		<h3>If being wrong is cheap</h3>
		<p>
			Then say so, and spend your effort elsewhere. A prototype that will be thrown away in six
			weeks does not need a proof, and pretending otherwise is how this field earned its
			reputation.
		</p>
		<SlideNotes {...note("If being wrong is cheap")} />
	</Section>
</section>

<!-- ══════════════ 6. Tests ══════════════ -->
<section>
	<Section>
		<h3>Do you write tests, and do you trust them?</h3>
		<p>Both halves of that question matter.</p>
		<Choice down="Yes, and not entirely" right="No, next question" />
		<SlideNotes {...note("Do you write tests, and do you trust them?")} />
	</Section>

	<Section>
		<h3>What a green test suite means</h3>
		<p class="big">No counterexample was found among the cases we tried.</p>
		<p>That is a genuinely useful thing to know. It is not the same as "this is correct".</p>
		<SlideNotes {...note("What a green test suite means")} />
	</Section>

	<Section>
		<h3>Sampling, versus stating it once</h3>
		<CodeCompare columns={cmp.testVsProof} focus="A proof" />
	</Section>

	<Section>
		<h3>The difference in one line</h3>
		<p>
			The test checks a hundred lists. The proof covers every list, of every element type, including
			the ones nobody will ever construct.
		</p>
	</Section>

	<Section>
		<h3>What it does not give you</h3>
		<p>
			If the property you stated is the wrong property, you now have a carefully verified wrong
			program. The error just moved somewhere small and explicit.
		</p>
		<Note category="math">
			Which is still progress. A wrong sentence you can review beats a wrong assumption you cannot
			see.
		</Note>
		<SlideNotes {...note("What it does not give you")} />
	</Section>

	<Section>
		<h3>What changes day to day</h3>
		<ul>
			<li>Fewer tests, because the boring cases stop being possible</li>
			<li>More time deciding what should be true, which is the hard part anyway</li>
			<li>Refactoring stops being frightening</li>
		</ul>
	</Section>

	<Section>
		<h3>What you keep testing regardless</h3>
		<p>
			Anything touching the outside world, anything about performance, and anything where the
			specification is "it looks right". Proofs do not replace a test suite; they shrink it.
		</p>
		<SlideNotes {...note("What you keep testing regardless")} />
	</Section>
</section>

<!-- ══════════════ 7. A taste ══════════════ -->
<section>
	<Section>
		<h3>Want to see what it actually looks like?</h3>
		<p>Five small pieces of real code, no prior exposure assumed.</p>
		<Choice down="Show me" right="No, next question" />
		<SlideNotes {...note("Want to see what it actually looks like?")} />
	</Section>

	<Section>
		<h3>One: a value that cannot be built wrong</h3>
		<CodeSnippet code={t} key="No Empty Case" />
		<p>No empty case exists, so no function over it needs a failure branch.</p>
	</Section>

	<Section>
		<h3>Two: every case answered</h3>
		<CodeSnippet code={t} key="Every Case Answered" />
	</Section>

	<Section>
		<h3>Three: a size the checker knows</h3>
		<CodeSnippet lines="true" code={t} key="Length In The Type" />
	</Section>

	<Section>
		<h3>Which replaces a check you would have written</h3>
		<CodeCompare columns={cmp.lengthKnown} focus="Known already" />
	</Section>

	<Section>
		<h3>Now the name</h3>
		<p>
			A type with a value in it, like <code>Vector String 3</code>, is called a
			<b>dependent type</b>. That is the thing Lean has and your language mostly does not.
		</p>
		<p class="fragment">You have now seen it, so the term is describing something rather than announcing it.</p>
		<SlideNotes {...note("Now the name")} />
	</Section>

	<Section>
		<h3>Four: a property, settled</h3>
		<CodeSnippet code={t} key="A Property" />
		<p>Two lines, and it holds for every list of every type, forever.</p>
	</Section>

	<Section>
		<h3>Five: and it still runs</h3>
		<CodeSnippet code={t} key="It Runs" />
		<Code category="terminal" language="sh">$ lean --run tour.lean</Code>
	</Section>

	<Section>
		<h3>What just happened</h3>
		<ul>
			<li>A failure case disappeared instead of being handled</li>
			<li>A forgotten case became a compile error</li>
			<li>A runtime check became a compile-time fact</li>
			<li>A property became a two-line proof</li>
			<li>All of it is still an ordinary program</li>
		</ul>
		<SlideNotes {...note("What just happened")} />
	</Section>
</section>

<!-- ══════════════ 8. The maths ══════════════ -->
<section>
	<Section>
		<h3>Worried the maths will be over your head?</h3>
		<p>Most people considering this are, and nobody says it out loud.</p>
		<Choice down="Yes, frankly" right="No, next question" />
		<SlideNotes {...note("Worried the maths will be over your head?")} />
	</Section>

	<Section>
		<h3>The honest answer</h3>
		<p class="big">To start, you need almost none.</p>
		<SlideNotes {...note("The honest answer")} />
	</Section>

	<Section>
		<h3>What you actually need</h3>
		<ul>
			<li>Comfort reading a precise definition, which you already have from code</li>
			<li>Induction, which is recursion you already write, viewed from the other end</li>
			<li>Willingness to be wrong in front of a machine that is never impressed</li>
		</ul>
	</Section>

	<Section>
		<h3>Two different things get called "the maths"</h3>
		<table class="grid">
			<thead><tr><th>The maths <i>of</i> Lean</th><th>The maths <i>in</i> Lean</th></tr></thead>
			<tbody>
				<tr>
					<td>How the checker works underneath</td>
					<td>Group theory, analysis, topology</td>
				</tr>
				<tr>
					<td>Worth knowing eventually, not first</td>
					<td>Completely optional, and irrelevant to most engineers</td>
				</tr>
			</tbody>
		</table>
		<SlideNotes {...note("Two different things get called \"the maths\"")} />
	</Section>

	<Section>
		<h3>Mathlib is not the point</h3>
		<p>
			Lean has an enormous mathematics library. If you are verifying a payments system you will
			never open it, and that is fine.
		</p>
	</Section>

	<Section>
		<h3>What the rest of this series assumes</h3>
		<p>
			Lectures 01 to 05 assume you can program and are willing to read carefully. Where they need
			an idea from logic, they build it.
		</p>
	</Section>

	<Section>
		<h3>Where it does get hard</h3>
		<p>
			Proving substantial theorems needs mathematical maturity, and pretending otherwise wastes
			your time. But you can go a very long way using types to model your domain and never write a
			difficult proof.
		</p>
		<SlideNotes {...note("Where it does get hard")} />
	</Section>
</section>

<!-- ══════════════ 9. Time ══════════════ -->
<section>
	<Section>
		<h3>How much time have you got?</h3>
		<p>Be realistic. This is the question that decides whether you actually do it.</p>
		<Choice down="Give me a plan" right="No, next question" />
		<SlideNotes {...note("How much time have you got?")} />
	</Section>

	<Section>
		<h3>Twenty minutes</h3>
		<p>
			Open the web editor, no install. Paste the examples from the handout and change them until
			they break. You are looking for one moment where the checker tells you something you did not
			know.
		</p>
		<Code category="terminal" language="sh">https://live.lean-lang.org</Code>
	</Section>

	<Section>
		<h3>A weekend</h3>
		<p>
			Install the toolchain and work through the first chapters of <i>Functional Programming in
			Lean</i>. Write something small and useless. Do not read about proofs yet.
		</p>
	</Section>

	<Section>
		<h3>A month</h3>
		<p>
			Model a real domain from your job in types, with no proofs. Then take one invariant you
			currently maintain by convention and make it unrepresentable.
		</p>
		<p class="fragment">This is the point where most of the value arrives.</p>
		<SlideNotes {...note("A month")} />
	</Section>

	<Section>
		<h3>A year</h3>
		<p>
			Verify a component with a crisp contract: a parser, a policy evaluator, a state machine. Now
			the proofs are worth it, because the specification is worth writing down.
		</p>
	</Section>

	<Section>
		<h3>What to skip</h3>
		<ul>
			<li>The category theory. You do not need it and it will not help yet</li>
			<li>Mathlib, unless you are doing mathematics</li>
			<li>Arguments about which proof assistant is best</li>
		</ul>
	</Section>

	<Section>
		<h3>Stuck, or just slow?</h3>
		<p>
			Slow feels like typing carefully. Stuck feels like guessing. If you are guessing at what the
			checker wants for more than an hour, ask on the Zulip; the answer is usually one sentence.
		</p>
	</Section>

	<Section>
		<h3>If you have to convince a team</h3>
		<ul>
			<li>Do not propose a rewrite. You will lose, and you should</li>
			<li>Verify the specification, not the system</li>
			<li>Pick one component with a contract people already argue about</li>
			<li>Keep it out of the build critical path until it has earned its place</li>
		</ul>
		<SlideNotes {...note("If you have to convince a team")} />
	</Section>

	<Section>
		<h3>What to measure</h3>
		<p>
			Not lines proved. Count the bugs found in the <i>specification</i> while writing it down,
			because that is where the surprises are, and it is the number that convinces sceptics.
		</p>
		<SlideNotes {...note("What to measure")} />
	</Section>
</section>

<!-- ══════════════ 10. The case against ══════════════ -->
<section>
	<Section>
		<h3>Still not convinced?</h3>
		<p>Good. Here is the argument against, made properly.</p>
		<Choice down="Make the case against" right="No, take me to the end" />
		<SlideNotes {...note("Still not convinced?")} />
	</Section>

	<Section>
		<h3>The ecosystem is small</h3>
		<p>
			There is no library for your cloud provider, your database driver, or your message queue. You
			will write bindings, or you will keep Lean at the edge of your system.
		</p>
	</Section>

	<Section>
		<h3>The bus factor is you</h3>
		<p>
			You will be the only person on the team who can change the verified component. That is a real
			operational risk and it is fair for your manager to raise it.
		</p>
	</Section>

	<Section>
		<h3>Proofs are maintained, not finished</h3>
		<p>
			Change the code and the proof breaks. Sometimes it breaks for a good reason, and sometimes
			because you renamed a field. That is ongoing work forever.
		</p>
	</Section>

	<Section>
		<h3>Your bugs may not be these bugs</h3>
		<p>
			If your incidents are timeouts, capacity, race conditions and misunderstood requirements, a
			better type system addresses roughly none of them.
		</p>
		<SlideNotes {...note("Your bugs may not be these bugs")} />
	</Section>

	<Section>
		<h3>The toolchain moves</h3>
		<p>
			Lean 4 is young and its standard library still changes. Some code in this very course needed
			updating between releases, and that will happen to you.
		</p>
	</Section>

	<Section>
		<h3>If your types already do the job</h3>
		<p>
			If you write Rust with real sum types, exhaustive matching and few escape hatches, you have
			most of the practical benefit already. Learning Lean would teach you why it works, which is
			worth something, but maybe not this quarter.
		</p>
		<SlideNotes {...note("If your types already do the job")} />
	</Section>

	<Section>
		<h3>Who should walk away</h3>
		<ul>
			<li>Anyone whose deadline is this month</li>
			<li>Anyone hoping it will fix a process problem</li>
			<li>Anyone who wants it to replace testing rather than shrink it</li>
		</ul>
	</Section>

	<Section>
		<h3>What to learn instead</h3>
		<table class="grid">
			<thead><tr><th>If you want</th><th>Learn</th></tr></thead>
			<tbody>
				<tr><td>Most of the benefit, at work, on Monday</td><td>Rust, or your language's sum types used properly</td></tr>
				<tr><td>Confidence without proofs</td><td>Property-based testing</td></tr>
				<tr><td>To check a distributed design</td><td>TLA+</td></tr>
				<tr><td>To check a data model</td><td>Alloy</td></tr>
			</tbody>
		</table>
		<SlideNotes {...note("What to learn instead")} />
	</Section>
</section>

<!-- ══════════════ 11. Where next ══════════════ -->
<section>
	<Section>
		<h3>Where to go next</h3>
		<p>If any branch landed, the series continues from here.</p>
	</Section>

	<Section>
		<h3>The lectures</h3>
		<ul class="tight">
			<li><b>01</b> Types, and why Lean. The argument in full, with the ideas named</li>
			<li><b>02</b> Control flow, recursion, structures, inductives</li>
			<li><b>03</b> Type polymorphism, classes and instances</li>
			<li><b>04</b> Monads: impurity and fallibility</li>
			<li><b>05</b> IO, exceptions, concurrency</li>
		</ul>
	</Section>

	<Section>
		<h3>Outside this series</h3>
		<ul class="tight">
			<li><i>Functional Programming in Lean</i>, the book to actually start with</li>
			<li><i>Theorem Proving in Lean 4</i>, once you want proofs</li>
			<li>The Lean Zulip, where questions get answered quickly and kindly</li>
			<li><a href="{base}/handout/should-i-learn-lean/tour.lean">tour.lean</a>, everything you saw here, runnable</li>
		</ul>
	</Section>

	<Section>
		<h3>If you remember one thing</h3>
		<p class="big">
			A type system keeps track of the cases you have to handle.
		</p>
		<p>Everything else, including all of Lean, is that idea taken seriously.</p>
		<SlideNotes {...note("If you remember one thing")} />
	</Section>
</section>

<style>
	.big {
		font-size: 1.1em;
		line-height: 1.35;
	}
	.tight {
		font-size: 0.78em;
	}
	.grid {
		font-size: 0.48em;
	}
	.grid th {
		color: var(--ctp-lavender);
	}
</style>
