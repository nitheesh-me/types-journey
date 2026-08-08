<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import Note from '$lib/slides/Note.svelte';
	import Markdown from '$lib/slides/Markdown.svelte';
	import { base } from '$app/paths';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/fp-polymorphism/handout.lean?raw';
	import NotesSource from './notes.md?raw';
	import FunctorNote from '$handouts/fp-polymorphism/functor.lean?raw';

	const title = 'Type Polymorphism, Classes and Instances';
	const snippets = parseSnippets(Handout);
	const note = noteLookup(NotesSource);

	// Kept as strings so Svelte does not read the TeX braces as expressions.
	const universeTower = String.raw`
		\[
			\mathsf{Type}
			= \mathsf{Type}\,0
			\in \mathsf{Type}\,1
			\in \mathsf{Type}\,2
			\in \cdots
		\]
	`;
	const functionUniverse = String.raw`A function type whose arguments are in $\Type(n)$ and $\Type(m)$, is in $\Type(1+\max(n,m))$`;

	const commonClasses = `
| Expression | Desugared |
|------------|-----------|
| \`x + y\`    | \`HAdd.hAdd x y\` |
| \`x - y\`    | \`HSub.hSub x y\` |
| \`x * y\`    | \`HMul.hMul x y\` |
| \`x / y\`    | \`HDiv.hDiv x y\` |
| \`x &&& y\`    | \`HAnd.hAnd x y\` |
| \`~~~ x\`    | \`Complement.complement x\` |
`;
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section data-transition="zoom">
	<h2>{title}</h2>
</section>

<section>
	<Section>
		<h2>Types</h2>
		<SlideNotes {...note('Types')} />
	</Section>

	<Section>
		<h3>Every expression has a Type</h3>
		<CodeSnippet lines="true" code={snippets} key="Type" />
		<Code lines="true" category="message">{`Nat
String
Nat → Nat`}</Code>
	</Section>

	<Section>
		<h3>Dependent Types</h3>
		<p><code>List Nat</code> is a type. <code>Nat</code> is a type. What is <code>List</code>?</p>
		<CodeSnippet lines="true" code={snippets} key="Dependent Type" />
		<Code lines="true" category="message">{`
Type
List.{u} (α : Type u) : Type u
List : Type u_1 → Type u_1
`}</Code>
		<p class="fragment">It is a function from a type to a type</p>
		<SlideNotes {...note('Dependent Types')} />
	</Section>

	<Section>
		<h3>Dependent Function Types</h3>
		<p>A function type is <b>dependent</b> when the image is parameterized over an argument</p>
		<CodeSnippet lines="true" code={snippets} key="Dependent Function Type" />
		<Code lines="true" category="message">{`
duplicate.{u_1} {α : Type u_1} (x : α) : List α
[1, 1]
`}</Code>
		<SlideNotes {...note('Dependent Function Types')} />
	</Section>

	<Section>
		<h3>Type Universes</h3>
		<p>Every type resides in a universe</p>
		{universeTower}
		<SlideNotes {...note('Type Universes')} />
	</Section>

	<Section>
		<h3>Type Universes</h3>
		<CodeSnippet lines="true" code={snippets} key="Type Universes" />
		<Note fragment category="program">
			Use the <code>example</code> command to check if the type of an expression matches expectation.
		</Note>
		<SlideNotes {...note('Type Universes')} />
	</Section>

	<Section>
		<h3>Dependent Structure Types</h3>
		<p>A structure or inductive can also take a parameter.</p>
		<CodeSnippet lines="true" code={snippets} key="Polymorphic Vec" />
		<Code category="message">{`
{ x := 1, y := 2 } : Vec2 Nat
`}</Code>
	</Section>

	<Section>
		<h3>Dependent Inductive Types</h3>
		<Code category="ref">{`
inductive Option (α) where
  /-- No value. -/
  | none : Option α
  /-- Some value of type \`α\`. -/
  | some (val : α) : Option α
`}</Code>
	</Section>

	<Section>
		<h3>The <code>List</code> Type</h3>
		<p>A list is either empty or a head and a tail.</p>
		<Code category="ref">{`
inductive List (α) where
  | nil : List α
  | cons (head : α) (tail : List α) : List α
`}</Code>
	</Section>

	<Section>
		<h3>Type of a Function</h3>
		<CodeSnippet lines="true" code={snippets} key="Type of Function" />
		<Code category="message">Type 5 → Type 4 : Type 6</Code>
		<p>{functionUniverse}</p>
		<aside class="notes">This is done to prevent paradoxes similar to Russell's paradox.</aside>
	</Section>

	<Section animate>
		<h3>Universe Polymorphism</h3>
		<CodeSnippet id="universe-polymorphism" code={snippets} key="Universe Polymorphism" />
		<Code id="message" category="ref">{`
duplicate'.{u} {α : Type u} (x : α) : List α
`}</Code>
		<p>When the universe level is not known, it can be polymorphized</p>
		<Note category="program">
			Use <code>universe</code> to define a type universe variable in the current section.
		</Note>
	</Section>

	<Section animate>
		<h3>Universe Polymorphism</h3>
		<Code id="universe-polymorphism">{`
def duplicate { α } (x : α) := [x, x]
#check duplicate
`}</Code>
		<Code id="message" category="ref">{`
duplicate.{u_1} {α : Type u} (x : α) : List α
`}</Code>
		<p>Type universe variables are automatically inserted.</p>
	</Section>

	<Section animate>
		<h3>Universe Polymorphism</h3>
		<Code category="ref">{`
def map.{u, v} {α : Type u} {β : Type v}
    (f : α → β) :
    List.{u} α → List.{v} β
  | [] => []
  | x :: xs => f x :: map f xs
`}</Code>
		<Note category="program">
			<code>set_option autoImplicit false</code> disallows the automatic generation of type variables.
		</Note>
	</Section>

	<Section>
		<h3>Either</h3>
		<CodeSnippet lines="true" code={snippets} key="Either" />
		<p>
			We can also define polymorphic inductive types with each parameter in a different universe
		</p>
		<Note category="program">
			Lean's version of the <code>Either</code> type is the <code>Except</code> type.
		</Note>
	</Section>

	<Section>
		<h3>Functions on Either</h3>
		<CodeSnippet lines="true" code={snippets} key="Function on Either" />
	</Section>
</section>

<section>
	<Section>
		<h2>Inductive Families</h2>
		<SlideNotes {...note('Inductive Families')} />
	</Section>

	<Section>
		<h3>Recursor of <code>Option</code></h3>
		<Code lines="2|3|4|5-6" category="ref">{`
Option.casesOn.{u_1, u}
  {α : Type u} -- Parameter
  {motive : Option α → Sort u_1} -- Motive
  (t : Option α) -- Major
  (none : motive none) -- Minor of \`.none\`
  (some : (val : α) → motive (some val)) -- Minor of \`.some\`
  : motive t
`}</Code>
	</Section>

	<Section>
		<h3>Inductive Families</h3>
		<p>
			An <b>inductive family</b> takes <i>index</i> arguments and may refer to itself by a different
			index. This polymorphic array encodes the length in its type signature.
		</p>
		<CodeSnippet code={snippets} key="FixedArray" />
		<SlideNotes {...note('Inductive Families')} />
	</Section>

	<Section>
		<h3>Inductive Families</h3>
		<p>
			An <b>inductive family</b> takes <i>index</i> arguments and may refer to itself by a different
			index
		</p>
		<CodeSnippet lines="true" code={snippets} key="Even-Odd List" />
		<SlideNotes {...note('Inductive Families')} />
	</Section>

	<Section>
		<h3>Recursor of Inductive Families</h3>
		<Code lines="2|3|4-5|6|7" category="ref">{`
FixedArray.rec.{u_1, u}
  {α : Type u}
  {motive : (a : Nat) → FixedArray α a → Sort u_1}
  (nil : motive 0 FixedArray.nil)
  (cons : {n : Nat} → (a : α) → (a_1 : FixedArray α n) → motive n a_1 → motive (n + 1) (FixedArray.cons a a_1))
  {a : Nat}
  (t : FixedArray α a) : motive a t
`}</Code>
	</Section>

	<Section>
		<h3>Matching on Inductive Families</h3>
		<CodeSnippet code={snippets} key="FixedArray sum" />
	</Section>

	<Section>
		<h3>Recursor of <code>EvenOddList</code></h3>
		<Code category="ref">{`
EvenOddList.rec.{u_1, u} {α : Type u} {motive : (a : Bool) → EvenOddList α a → Sort u_1}
  (nil : motive true EvenOddList.nil)
  (cons :
    {isEven : Bool} →
      (a : α) → (a_1 : EvenOddList α isEven) → motive isEven a_1 → motive (!isEven) (EvenOddList.cons a a_1))
  {a : Bool} (t : EvenOddList α a) : motive a t
`}</Code>
	</Section>

	<Section animate>
		<h3>Parameters vs. Indices</h3>
		<p>Parameters must be fixed in recursive references to the same type</p>
		<CodeSnippet hasError code={snippets} key="Invalid Recursive Parameter" />
	</Section>

	<Section animate>
		<h3>Parameters vs. Indices</h3>
		<p>Parameters must be fixed in recursive references to the same type</p>
		<CodeSnippet code={snippets} key="Type as Index" />
	</Section>

	<Section>
		<h3>Recursor of <code>EvenOddList</code></h3>
		<Code lines="2|3-6|7|8" category="ref">{`
EvenOddList.rec.{u_1, u} {α : Type u}
  {motive : (a : Bool) → EvenOddList α a → Sort u_1}
  -- minors
  (nil : motive true EvenOddList.nil)
  (cons : {isEven : Bool} →
      (a : α) → (a_1 : EvenOddList α isEven) → motive isEven a_1 → motive (!isEven) (EvenOddList.cons a a_1))
  {a : Bool} -- Indices
  (t : EvenOddList α a) -- Major
  : motive a t
`}</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Type Classes and Instances</h2>
		<SlideNotes {...note('Type Classes and Instances')} />
	</Section>

	<Section>
		<h3>Function Overloading</h3>
		<p>Can we define a function like this?</p>
		<Code>{`
def contracat { u } (a b : u) := ??
#eval contracat "abc" "123" -- "abc321"
#eval contracat [1, 2] [3, 4] -- [1, 2, 4, 3]
#eval contracat 12 34 -- 1243
`}</Code>
	</Section>

	<Section>
		<h3>Attempt at a Type Class</h3>
		<CodeSnippet lines="true" code={snippets} key="Type Class Attempt" />
		<Code category="message">"abc321"</Code>
	</Section>

	<Section>
		<h3>Type Class</h3>
		<p>Lean's type class works in the same way!</p>
		<CodeSnippet lines="true" code={snippets} key="Type Class" />
		<Code category="message">{`
"123cba"
instContracatString : Contracat String
`}</Code>
	</Section>

	<Section>
		<h3>Type Class</h3>
		<p>We can define a <code>Contracat</code> instance for strings</p>
		<CodeSnippet lines="true" code={snippets} key="Contracat of String" />
		<Code category="message">{`
[1, 2, 4, 3]
`}</Code>
	</Section>

	<Section>
		<h3>Inheritance of Type Class</h3>
		<p>One type class can inherit another</p>
		<CodeSnippet lines="true" code={snippets} key="Duplicate" />
		<Code category="message">8</Code>
		<Note category="program">Use the <code>∘</code> operator to chain two functions.</Note>
	</Section>

	<Section animate>
		<h3><code>BEq</code></h3>
		<p>The <code>BEq</code> type class defines Boolean equality</p>
		<CodeSnippet lines="true" code={snippets} key="Point BEq" />
	</Section>

	<Section animate>
		<h3><code>BEq</code></h3>
		<CodeSnippet lines="true" code={snippets} key="Vec2 BEq" />
		<Note category="program">
			Use the <code>deriving</code> keyword to create an automatically generated instance.
		</Note>
	</Section>

	<Section>
		<h3><code>Add</code></h3>
		<CodeSnippet lines="true" code={snippets} key="Vec2 Add" />
		<Code category="message">{`
{ x := 8, y := 10 }
`}</Code>
	</Section>

	<Section>
		<h3>Common Type Classes</h3>
		<Markdown>{commonClasses}</Markdown>
	</Section>

	<Section>
		<h3>Deriving</h3>
		<p>Automatic derivations exist for the following type classes</p>
		<ul>
			<li><code>BEq</code>: Boolean equality</li>
			<li><code>DecidableEq</code>: Decidable equality</li>
			<li><code>Hashable</code>: Hashing</li>
			<li><code>Inhabited</code>: Default value exists</li>
			<li><code>Nonempty</code>: A value is non-empty but not constructible</li>
			<li><code>Ord</code>: Ordering</li>
			<li><code>Repr</code>: Representation as text</li>
			<li><code>SizeOf</code></li>
			<li><code>TypeName</code>: Dynamic type</li>
		</ul>
	</Section>

	<Section>
		<h3>Class Abbreviation</h3>
		<p>Use <code>class abbrev</code> to generate an automatic instance</p>
		<CodeSnippet code={snippets} key="Class Abbreviation" />
		is equivalent to
		<CodeSnippet code={snippets} key="Class Abbreviation Desugared" />
	</Section>

	<Section>
		<h3>Multiple Instances</h3>
		<CodeSnippet lines="true" code={snippets} key="Monoid" />
		<Code category="message">25</Code>
	</Section>

	<Section>
		<h3>Instance Arguments</h3>
		<p>Functions can take "Instance Implicit" arguments?</p>
		<CodeSnippet lines="true" code={snippets} key="Functions on Monoid" />
		<Code category="message">{`
25
10
25
`}</Code>
		<Note category="program">The <code>@</code> prefix makes a function's arguments explicit.</Note>
	</Section>

	<Section>
		<h3>Instance Search</h3>
		<p>How does Lean decide which instance to use?</p>
		<ul>
			<li>Local instances are preferred to global instances</li>
			<li>An instance can be selected only if its parameters can be instantiated</li>
			<li>Priorities are used as tiebreaker</li>
		</ul>
		<SlideNotes {...note('Instance Search')} />
	</Section>

	<Section>
		<h3><code>outParam</code></h3>
		<p>
			<code>outParam</code> tells Lean to infer <code>?γ</code> automatically based on the first
			<code>HMul</code> typeclass instance it finds for <code>?α</code> and <code>?β</code>.
		</p>
		<Code category="ref">{`
class HMul (α : Type u) (β : Type v) (γ : outParam (Type w)) where
  hMul : α → β → γ
infixl:70 " * "   => HMul.hMul
`}</Code>
		<SlideNotes {...note('outParam')} />
	</Section>
</section>

<section>
	<Section>
		<h2>Other Type Classes</h2>
		<SlideNotes {...note('Other Type Classes')} />
	</Section>

	<Section>
		<h3><code>OfNat</code></h3>
		<p>Represent any type by a natural number</p>
		<CodeSnippet lines="true" code={snippets} key="OfNat" />
		<Code category="message">{`
{ x := 5, y := 0 }
`}</Code>
	</Section>

	<Section>
		<h3>Coercions</h3>
		<p>The <code>Coe</code> type allows implicit conversion</p>
		<Code category="ref">{`
class Coe (α : Type) (β : Type) where
  coe : α → β
`}</Code>
		<CodeSnippet lines="true" code={snippets} key="Coercion" />
		<Code category="message">2</Code>
		<Note category="program">Lean will automatically chain coercions from smaller coercions.</Note>
		<aside class="notes">
			It is common to use the same symbol for equivalent values in different contextes.
		</aside>
		<SlideNotes {...note('Coercions')} />
	</Section>

	<Section>
		<h3>Inhabited</h3>
		<p>The type class <code>Inhabited</code> represents a type having a default value.</p>
		<Code category="ref">{`
class Inhabited (α : Sort u) where
  default : α
`}</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Implement a complex integer type with <code>Int</code>, and equip it with the four arithmetic
			operations.
		</p>
	</Section>
</section>

<section>
	<Section>
		<h2>Functor</h2>
		<SlideNotes {...note('Functor')} />
	</Section>

	<Section>
		<h3>Functor</h3>
		<Code category="ref">{`
class Functor (f : Type u → Type v) : Type (max (u+1) v) where
  /-- If \`f : α → β\` and \`x : F α\` then \`f <$> x : F β\`. -/
  map : {α β : Type u} → (α → β) → f α → f β
`}</Code>
		<Note category="program">
			You can also write <code>Functor.map</code> as <code>&lt;$&gt;</code>.
		</Note>
		<SlideNotes {...note('Functor')} />
	</Section>

	<Section>
		<h3>Supplementary: <code>functor.lean</code></h3>
		<p>
			<a href="{base}/handout/fp-polymorphism/functor.lean">functor.lean</a> works out why
			<code>Functor</code> lives in <code>max (u+1) v</code>.
		</p>
		<Code>{FunctorNote}</Code>
		<SlideNotes {...note('Supplementary: functor.lean')} />
	</Section>

	<Section>
		<h3>Pair</h3>
		<CodeSnippet lines="true" code={snippets} key="Pair" />
	</Section>

	<Section>
		<h3>Pair as a Functor</h3>
		<CodeSnippet lines="true" code={snippets} key="Pair Functor" />
	</Section>

	<Section>
		<h3>Functor Laws</h3>
		<ul>
			<li><b>Identity</b>: <code>map id m = m</code></li>
			<li><b>Associativity</b>: <code>map f (map g m) = map (f ∘ g) m</code></li>
		</ul>
		<SlideNotes {...note('Functor Laws')} />
	</Section>

	<Section>
		<h3>Unlawful Functor</h3>
		<CodeSnippet lines="true" code={snippets} key="Unlawful Functor" />
		<SlideNotes {...note('Unlawful Functor')} />
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>Define <code>List</code> as a <code>Functor</code> and check that the functor is lawful.</p>
	</Section>
</section>
