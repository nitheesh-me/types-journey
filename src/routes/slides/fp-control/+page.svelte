<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import Note from '$lib/slides/Note.svelte';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/fp-control/handout.lean?raw';
	import NotesSource from './notes.md?raw';

	const title = 'Control Flow, Recursion, Structures, Inductives';
	const snippets = parseSnippets(Handout);
	const note = noteLookup(NotesSource);
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section data-transition="zoom">
	<h2>{title}</h2>
</section>

<section>
	<Section>
		<h2>Control Flow</h2>
		<SlideNotes {...note('Control Flow')} />
	</Section>

	<Section>
		<h3>If-Else</h3>
		<CodeSnippet lines="1|2-3|4-5|6" code={snippets} key="If" />
		<Code category="message">"small"</Code>
		<Note category="program">The else branch is mandatory.</Note>
		<SlideNotes {...note('If-Else')} />
	</Section>

	<Section>
		<h3>Match</h3>
		<CodeSnippet lines="1|2|3-5|6-7" code={snippets} key="Match" />
		<Code category="message">{`"big"
"small"`}</Code>
		<SlideNotes {...note('Match')} />
	</Section>

	<Section>
		<h3>Match (Syntactic Sugar)</h3>
		<CodeSnippet lines="1|2-4|5-6" code={snippets} key="Match-Sugar" />
		<Code category="message">{`"big"
"small"`}</Code>
		<Note category="program">Use <code>\-&gt;</code> to type the arrow symbol.</Note>
	</Section>

	<Section>
		<h3>For? While? Break?</h3>
		<p>Wait until later...</p>
	</Section>

	<Section>
		<h3>Comments</h3>
		<CodeSnippet lines="1|2-3|4" code={snippets} key="Comments" />
	</Section>
</section>

<section>
	<Section>
		<h2>Function Calls</h2>
		<SlideNotes {...note('Function Calls')} />
	</Section>

	<Section>
		<h3>Default Argument</h3>
		<p>Functions can have default arguments.</p>
		<CodeSnippet code={snippets} key="Default Argument" />
		<Code category="message">{`625
20`}</Code>
	</Section>

	<Section>
		<h3>Named Arguments</h3>
		<p>Provide arguments by name out-of-order</p>
		<CodeSnippet code={snippets} key="Named Argument" />
		<Code category="message">12</Code>
	</Section>

	<Section>
		<h3>Implicit Arguments</h3>
		<p>Some Lean functions take implicit arguments, represented by curly brackets.</p>
		<Code>#check List.map</Code>
		<Code category="message" lines="true">{`
List.map.{u, v} {α : Type u} {β : Type v} (f : α → β) : List α → List β
`}</Code>
	</Section>

	<Section>
		<h3>Namespaces</h3>
		<p>
			If <code>x</code> has type <code>X</code>, <code>x.f</code> is syntactic sugar for
			<code>X.f x</code>
		</p>
		<CodeSnippet lines="true" code={snippets} key="Namespace" />
		<Code category="message" lines="true">{`String.intercalate (s : String) : List String → String
"Apple, Orange"`}</Code>
		<Note category="program">
			In <code>x.f</code>, <code>x</code> will match with the first argument of
			<code>X.f</code> with type <code>X</code>.
		</Note>
	</Section>

	<Section>
		<h3><code>protected</code></h3>
		<p><code>protected</code> functions do not interact with <code>open</code></p>
		<Code category="ref">protected def Nat.add (x y : Nat) := ...</Code>
		<Code>{`open Nat
#eval add 1 5 -- Not permitted`}</Code>
	</Section>

	<Section>
		<h3>Sections</h3>
		<p>
			<code>section</code>...<code>end</code> pairs limit the effect of option changes, open
			declarations, and variable declarations
		</p>
		<CodeSnippet code={snippets} key="Section" />
	</Section>

	<Section>
		<h3>Currying</h3>
		<CodeSnippet code={snippets} key="Currying Types" />
		<Code category="message" lines="true">{`f : Nat → Nat → Nat
f 5 : Nat → Nat
f 1 2 : Nat`}</Code>
		<SlideNotes {...note('Currying')} />
	</Section>

	<Section>
		<h3>Currying</h3>
		<CodeSnippet code={snippets} key="Currying" />
		<p>A function of type <code>A → B → C</code> is really just <code>A → (B → C)</code>.</p>
		<SlideNotes {...note('Currying')} />
	</Section>

	<Section>
		<h3>Currying</h3>
		<CodeSnippet code={snippets} key="Point-Free" />
		<Code category="message">[3]</Code>
		<SlideNotes {...note('Currying')} />
	</Section>

	<Section>
		<h3>Fold</h3>
		<CodeSnippet lines="1|2|3|4" code={snippets} key="Fold" />
		<Code category="message" lines="true">{`" tic toc tic2 toc2"`}</Code>
		<Note category="program">
			Folds are an idiomatic way to implement "loops" in functional programming.
		</Note>
		<SlideNotes {...note('Fold')} />
	</Section>

	<Section>
		<h3>Other alternatives to loops</h3>
		<Code>{`#check List.map
#check List.foldl
#check List.filter
#check List.filterMap
#check List.flatten`}</Code>
	</Section>

	<Section>
		<h3>Recursion</h3>
		<CodeSnippet code={snippets} key="Recursion" />
		<Code>#eval rec1 5 -- 11</Code>
		<SlideNotes {...note('Recursion')} />
	</Section>

	<Section>
		<h3>Recursion</h3>
		<p>Use <code>partial</code> when Lean fails to prove termination</p>
		<CodeSnippet code={snippets} key="Partial" />
		<Code>#eval rec2 5 -- 32</Code>
		<SlideNotes {...note('Recursion#2')} />
	</Section>

	<Section>
		<h3>Mutual Recursion</h3>
		<p>Mutual recursion can only occur within <code>mutual</code> blocks!</p>
		<CodeSnippet lines="1,12|2-11" code={snippets} key="Mutual Recursion" />
		<Code>#eval f 5 -- 1</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Additional Conveniences</h2>
		<SlideNotes {...note('Additional Conveniences')} />
	</Section>

	<Section>
		<h3>Let Expression</h3>
		<CodeSnippet code={snippets} key="Let" />
		<Code category="message">{`6
41`}</Code>
	</Section>

	<Section>
		<h3><code>let rec</code></h3>
		<p>Recursion inside a function</p>
		<CodeSnippet code={snippets} key="Let-Rec" />
		<Code>#eval rect 15 -- 227</Code>
	</Section>

	<Section>
		<h3>Sub-functions</h3>
		<CodeSnippet code={snippets} key="Sub-functions" />
		<Code category="message">40</Code>
	</Section>

	<Section>
		<h3>Tuples</h3>
		<CodeSnippet code={snippets} key="Tuple" />
		<Code category="message">15</Code>
	</Section>

	<Section>
		<h3>The Unit Type</h3>
		<p>The unit type carries no information and is equivalent to an empty tuple.</p>
		<CodeSnippet code={snippets} key="Thunk" />
		<Code category="message">15</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Generate this string using <code>String.intercalate</code>, <code>List.foldl</code>, and
			<code>List.range</code>
		</p>
		<Code>{`"
  *
 ***
*****
  *
  *
"`}</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Structures</h2>
		<SlideNotes {...note('Structures')} />
	</Section>

	<Section>
		<h3>Product Type</h3>
		<p>
			If $A$ and $B$ are two sets, their <i>Cartesian product</i> consists of pairs of elements from
			$a$ and $b$
		</p>
		<p>{'$$ |A \\times B| = |A| \\cdot |B|$$'}</p>
	</Section>

	<Section>
		<h3>Structure</h3>
		<p>This is a <i>product type</i></p>
		<CodeSnippet code={snippets} key="Structure" />
		<Code>{`#check Point.mk
#check Point.x`}</Code>
		<Code category="message">{`Point.mk (x y : Nat) : Point
Point.x (self : Point) : Nat`}</Code>
	</Section>

	<Section>
		<h3>Abbreviation</h3>
		<CodeSnippet code={snippets} key="Structure Literal" />
		<aside class="notes">This does not change the existing point. It creates a new point.</aside>
		<Note category="program">Use <code>\&lt;</code> to type <code>⟨</code>.</Note>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>Create a function which sorts the elements of a point</p>
		<Code>{`
def f (p : Point) := ...
#eval f { x := 2, y := 1 }
`}</Code>
		<Code category="message">{`
{ x := 1, y := 2 }
`}</Code>
	</Section>

	<Section>
		<h3>Pattern Matching</h3>
		<CodeSnippet code={snippets} key="Pattern Matching" />
	</Section>

	<Section>
		<h3>Pattern Matching</h3>
		<CodeSnippet code={snippets} key="Pattern Matching'" />
		<Note category="program">
			<code>@</code> refers to the undestructed structure in pattern matching.
		</Note>
	</Section>

	<Section>
		<h3>Structure Inheritance</h3>
		<p>A structure can derive from another using <code>extends</code></p>
		<CodeSnippet code={snippets} key="Extends" />
		<Code category="message">Point3.mk (toPoint : Point) (z : Nat) : Point3</Code>
		<Note category="program">
			Diamond inheritance and field overriding are both allowed. Duplicate field names will be
			deduplicated.
		</Note>
	</Section>

	<Section>
		<h3>Constructor Renaming</h3>
		<CodeSnippet code={snippets} key="Constructor Renaming" />
		<Code category="message">Complex.from2d (re im : Int) : Complex</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Inductive</h2>
		<SlideNotes {...note('Inductive')} />
	</Section>

	<Section>
		<h3>Sum Type</h3>
		<p>
			If $A$ and $B$ are two disjoint sets, their <i>disjoint union</i> consists of either elements
			from $a$ or elements from $b$
		</p>
		<p>{'$$ |A \\sqcup B| = |A| + |B|$$'}</p>
	</Section>

	<Section>
		<h3>Inductive</h3>
		<p>This is a <i>sum type</i></p>
		<CodeSnippet code={snippets} key="Weekday" />
		<Code>{`#check f .tuesday
#check f (.thursday 5)`}</Code>
		<SlideNotes {...note('Inductive')} />
	</Section>

	<Section>
		<h3>Nested Match</h3>
		<CodeSnippet code={snippets} key="Match-Nested" />
	</Section>

	<Section>
		<h3>Recursive Inductive</h3>
		<CodeSnippet code={snippets} key="FakeNat" />
		<Code>#eval toNat (.succ (.succ .zero))</Code>
		<Note category="program">
			Inductive types can be mutually inductive in a <code>mutual</code> block.
		</Note>
	</Section>

	<Section>
		<h3>Strict Positivity</h3>
		<p>
			Recursive inductives must occur in <a
				href="https://lean-lang.org/doc/reference/latest////The-Type-System/Inductive-Types/#strict-positivity"
				>strictly positive</a
			> positions. This excludes function arguments
		</p>
		<CodeSnippet hasError code={snippets} key="Strict Positivity" />
		<Code category="message">
			(kernel) arg #1 of 'Bad.bad' has a non positive occurrence of the datatypes being declared
		</Code>
		<Note category="math">
			This restriction ensures Lean's type system remains self-consistent. For more details on why
			they exist, see the computation/termination lecture.
		</Note>
		<SlideNotes {...note('Strict Positivity')} />
	</Section>

	<Section>
		<h3>Tree</h3>
		<CodeSnippet code={snippets} key="Tree" />
		<Code>#eval sumTree (.branch 5 (.leaf 2) (.leaf 0))</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Define an infix traversal function. Hint: <code>x :: xs</code> adds an element to the front of
			a list. <code>xs ++ ys</code> concatenates two lists.
		</p>
		<Code>{`inductive Tree where
  | leaf (x : Nat)
  | branch (x : Nat) (left right : Tree)
def infixTraverse : Tree → List Nat
  ...`}</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Recursors</h2>
		<SlideNotes {...note('Recursors')} />
	</Section>

	<Section animate>
		<h3>Recursor</h3>
		<p>
			Under the hood, <code>if</code> and <code>match</code> expressions are implemented with
			automatically-generated recursors. Automatically generated recursors are suffixed with
			<code>.rec</code>, <code>.recOn</code>, or <code>.casesOn</code>
		</p>
		<Code category="ref">{`inductive Bool where
  | false
  | true`}</Code>
		which has the recursor type
		<Code category="ref">{`
Bool.rec.{u} {motive : Bool → Sort u}
  (false : motive false)
  (true : motive true)
  (t : Bool) : motive t
`}</Code>
	</Section>

	<Section animate>
		<h3>Recursor</h3>
		<CodeSnippet lines="1|2" code={snippets} key="Bool.casesOn" />
		<Code lines="1|2" category="message">{`1
2`}</Code>
		<Note category="program">
			Multiple recursors can exist for the same type, and you can even define your own recursor. Some
			recursors are not evaluable like <code>Bool.rec</code>.
		</Note>
	</Section>

	<Section animate>
		<h3>Recursor</h3>
		<p>
			The branches of a recursor are called <b>minor premises</b>. The value being destructed is
			called the <b>major premise</b>.
		</p>
		<Code category="ref" lines="2-3|4">{`
Bool.rec.{u} {motive : Bool → Sort u}
  (false : motive false)
  (true : motive true)
  (t : Bool)
	: motive t
`}</Code>
	</Section>

	<Section>
		<h3>The Motive</h3>
		<p>
			The recursor is a <i>dependent type function</i>. Its result type is dependent on the
			<i>motive</i> argument.
		</p>
		<CodeSnippet lines="true" code={snippets} key="Dependent type motive" />
		<Note category="program">What is the type of this expression?</Note>
		<SlideNotes {...note('The Motive')} />
	</Section>

	<Section>
		<h3>Implementation of Match</h3>
		<CodeSnippet code={snippets} key="Match Implementation" />
		<Code category="message">{`
def f.match_1.{u_1} : (motive : Weekday → Sort u_1) →
  (x : Weekday) →
    (Unit → motive Weekday.monday) →
      (Unit → motive Weekday.tuesday) →
        (Unit → motive Weekday.wednesday) → ((color : Nat) → motive (Weekday.thursday color)) → motive x :=
fun motive x h_1 h_2 h_3 h_4 => Weekday.casesOn x (h_1 ()) (h_2 ()) (h_3 ()) fun color => h_4 color
`}</Code>
	</Section>

	<Section>
		<h3>Recursor of Structures</h3>
		<Code category="ref">{`
Point.rec.{u}
  {motive : Point → Sort u}
  (mk : (x y : Nat) → motive { x := x, y := y })
  (t : Point)
  : motive t
`}</Code>
		<Note category="program">Lean views structures as inductives of only one case.</Note>
	</Section>

	<Section>
		<h3>Recursor of <code>Nat</code></h3>
		<Code category="ref">{`
Nat.rec.{u} {motive : Nat → Sort u}
  (zero : motive Nat.zero)
  (succ : (n : Nat) → motive n → motive n.succ)
  (t : Nat)
  : motive t
`}</Code>
		<Note category="program">
			There is currently a bug in Lean's compiler that prevents code generation of recursive
			recursors. In these cases, use the <code>match</code> syntax.
		</Note>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>What is the difference between <code>Nat.rec</code> and <code>Nat.casesOn</code>?</p>
	</Section>

	<Section>
		<h3>Example: Triangle Numbers</h3>
		<CodeSnippet code={snippets} key="Triangle" />
		<Code category="message">10</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>What does the recursor look like for an inductive type with no cases?</p>
	</Section>

	<Section>
		<h3>Conclusion</h3>
		<p>
			<code>if</code> and <code>match</code> expressions are not elementary, but are constructed out of
			recursors. Recursors do not exist in compiled code.
		</p>
		<SlideNotes {...note('Conclusion')} />
	</Section>
</section>
