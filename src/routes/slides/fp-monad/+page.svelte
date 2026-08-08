<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import Note from '$lib/slides/Note.svelte';
	import { base } from '$app/paths';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/fp-monad/handout.lean?raw';
	import NotesSource from './notes.md?raw';
	import Construction from '$handouts/fp-monad/monad.lean?raw';

	const title = 'Monads: Impurity and Fallibility';
	const snippets = parseSnippets(Handout);
	const note = noteLookup(NotesSource);
	const construction = parseSnippets(Construction);
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section data-transition="zoom">
	<h2>{title}</h2>
	<aside class="notes">
		This lecture will be a review for Haskell users out there, but if you have not seen them, the
		contents in this lecture will be a bit counterintuitive.
	</aside>
</section>

<section>
	<Section>
		<h2>Functors and Monads</h2>
		<SlideNotes {...note('Functors and Monads')} />
	</Section>

	<Section>
		<h3>Fallibility Problem</h3>
		<Code>{`def echo (s : String) : Option String :=
  match s.get? 0 with
  | .some x => s ++ x.toString
  | .none => .none`}</Code>
		<p>A function may need to fail, corresponding to returning a sum type.</p>
		<SlideNotes {...note('Fallibility Problem')} />
	</Section>

	<Section>
		<h3>Impurity Problem</h3>
		<Code>{`def ping : ?? =
  IO.println "Output"`}</Code>
		<p>
			A function may need to interact with the world or modify a state variable, corresponding to
			returning a product type.
		</p>
		<SlideNotes {...note('Impurity Problem')} />
	</Section>

	<Section>
		<h3>Revisiting the Option Type</h3>
		<Code category="ref">{`
inductive Option (α) where
  | none : Option α
  | some (val : α) : Option α

def Option.map (f : α → β) : Option α → Option β
  | some x => some (f x)
  | none   => none
def Option.bind : Option α → (α → Option β) → Option β
  | none,   _ => none
  | some a, f => f a
`}</Code>
	</Section>

	<Section>
		<h3>Option Functions</h3>
		<CodeSnippet lines="true" code={snippets} key="Option Functions" />
	</Section>

	<Section>
		<h3>Functor</h3>
		<Code category="ref">{`
class Functor (f : Type u → Type v) : Type (max (u+1) v) where
  /-- If \`f : α → β\` and \`x : F α\` then \`f <$> x : F β\`. -/
  map : {α β : Type u} → (α → β) → f α → f β
`}</Code>
		<SlideNotes {...note('Functor')} />
	</Section>

	<Section>
		<h3>Functor Laws</h3>
		<ul>
			<li><b>Identity</b>: <code>map id m = m</code></li>
			<li><b>Associativity</b>: <code>map f (map g m) = map (f ∘ g) m</code></li>
		</ul>
	</Section>

	<Section>
		<h3>Pure</h3>
		<Code category="ref">{`
class Pure (f : Type u → Type v) where
  pure {α : Type u} : α → f α
`}</Code>
		<p><code>Pure</code> abstracts the idea of encapsulating a type</p>
		<SlideNotes {...note('Pure')} />
	</Section>

	<Section>
		<h3>Bind</h3>
		<Code category="ref">{`
class Bind (m : Type u → Type v) where
  /-- If \`x : m α\` and \`f : α → m β\`, then \`x >>= f : m β\` represents the
  result of executing \`x\` to get a value of type \`α\` and then passing it to \`f\`. -/
  bind : {α β : Type u} → m α → (α → m β) → m β
`}</Code>
		<Note category="program">
			You can also write <code>Bind.bind</code> as <code>&gt;&gt;=</code>.
		</Note>
		<SlideNotes {...note('Bind')} />
	</Section>

	<Section>
		<h3>Monad</h3>
		<Code category="ref">{`
class Monad (m : Type u → Type v) extends
    Functor m, Pure m, Bind m : Type (max (u+1) v) where
  map      f x := bind x (Function.comp pure f)
`}</Code>
		<SlideNotes {...note('Monad')} />
	</Section>

	<Section>
		<h3>Monad Laws</h3>
		<ul>
			<li><b>Left Identity</b>: <code>bind (pure x) f = f x</code></li>
			<li><b>Right Identity</b>: <code>bind m pure = m</code></li>
			<li>
				<b>Associativity</b>: <code>bind (bind m g) h = bind m (bind (pure ∘ g) h)</code>
			</li>
		</ul>
		<SlideNotes {...note('Monad Laws')} />
	</Section>

	<Section animate>
		<h3>A Stateful Monad</h3>
		<CodeSnippet code={snippets} key="StateNatM" />
		<SlideNotes {...note('A Stateful Monad')} />
	</Section>

	<Section animate>
		<h3>A Stateful Monad</h3>
		<CodeSnippet code={snippets} key="Stateful computation" />
		<Note category="program">The bind operator is associative to the right.</Note>
		<SlideNotes {...note('A Stateful Monad')} />
	</Section>

	<Section>
		<h3>Supplementary: <code>monad.lean</code></h3>
		<p>
			<a href="{base}/handout/fp-monad/monad.lean">monad.lean</a> builds a monad from scratch:
			a state-passing function, then <code>seq</code>, <code>bind</code>, and <code>pure</code>,
			until the instance falls out.
		</p>
		<CodeSnippet code={construction} key="StateF Monad" />
		<SlideNotes {...note('Supplementary: monad.lean')} />
	</Section>

	<Section>
		<h3>Exercise</h3>
		<ul>
			<li>Prove that a monad is a functor</li>
			<li>Prove <code>StateNatM</code> is a monad</li>
			<li>
				Can you define <code>List</code> as an instance of <code>Functor</code> or
				<code>Monad</code>?
			</li>
		</ul>
	</Section>
</section>

<section>
	<Section>
		<h2>Common Monads</h2>
		<SlideNotes {...note('Common Monads')} />
	</Section>

	<Section>
		<h3>Options</h3>
		<p>The <code>Option</code> type is a monad</p>
		<Code category="ref">{`instance : Monad Option where
  pure := Option.some
  bind := Option.bind`}</Code>
	</Section>

	<Section animate id="do">
		<h3>The <code>do</code> Notation</h3>
		<p>Writing binds is tedious! <code>do</code> is much easier.</p>
		<CodeSnippet code={snippets} key="do-notation" />
		<Note category="program">
			In a <code>do</code> block, you can also write <code>Pure.pure</code> as <code>return</code>.
		</Note>
		<SlideNotes {...note('The do Notation')} />
	</Section>

	<Section animate id="do">
		<h3>The <code>do</code> Notation</h3>
		<p>Under the hood, this is implemented with <code>bind</code></p>
		<CodeSnippet code={snippets} key="Implementation of do" />
		<Code category="message">{`def mystery : String → Option String :=
  fun s => Bind.bind (s.get? 0) fun first => pure first.toString`}</Code>
		<Note category="program">
			The option <code>pp.notation</code> controls the printing of syntactic sugars.
		</Note>
		<SlideNotes {...note('The do Notation')} />
	</Section>

	<Section>
		<h3>Early Return</h3>
		<CodeSnippet code={snippets} key="Early Return" />
		<Code category="message">{`some 6
some 10`}</Code>
		<p>If not specified, the default <code>else</code> branch is <code>pure ()</code></p>
		<SlideNotes {...note('Early Return')} />
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Design a monad which allows early return by failing with an error message (this is usually
			called an exception).
		</p>
		<Code>{`def compute (x : Nat) : ExceptionM Nat := do
  if x == 0 then
		.fail "cannot divide by 0"
  let y := 15 / x
  return y
#eval (compute 0).run`}</Code>
	</Section>

	<Section>
		<h3>The Identity Monad</h3>
		<Code category="ref">{`def Id (type : Type u) : Type u := type

instance : Monad Id where
  pure x := x
  bind x f := f x
  map f x := f x`}</Code>
	</Section>

	<Section>
		<h3>The <code>ReaderM</code> Monad</h3>
		<p><code>ReaderM</code> carries around an immutable state</p>
		<CodeSnippet code={snippets} key="Reader" />
		<Code category="message">"ab"</Code>
		<Note category="program">
			Use the notation <code>f x|&gt;.g</code> to access the member on a function result. This is
			called <b>pipeline syntax</b>.
		</Note>
		<SlideNotes {...note('The ReaderM Monad')} />
	</Section>

	<Section>
		<h3><code>withReader</code></h3>
		<p>Substitute in a different reader using <code>withReader</code></p>
		<CodeSnippet code={snippets} key="withReader" />
		<Code category="message">5</Code>
	</Section>

	<Section>
		<h3>The <code>StateM</code> Monad</h3>
		<p>This is useful when a computation carries around a state.</p>
		<CodeSnippet code={snippets} key="Linear Congruential" />
		<Code category="message">(7, 17)</Code>
		<SlideNotes {...note('The StateM Monad')} />
	</Section>

	<Section>
		<h3>Implementation of <code>ReaderM</code> and <code>StateM</code></h3>
		<Code category="ref">{`
def ReaderM.{u} (ρ α : Type u) := ρ → α
def StateM.{u} (σ α : Type u) := σ → (α, σ)
`}</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>Check that <code>State</code> and <code>Reader</code> conform to monadic laws.</p>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Define a <code>RecorderM</code> monad and a <code>print</code> function such that it collects
			the outputs of the print.
		</p>
		<Code>{`def talk : RecorderM Unit := do
  .print "hi"
  .print "terminal"
#eval talk.run -- ["hi", "terminal"]`}</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Loops</h2>
		<SlideNotes {...note('Loops')} />
	</Section>

	<Section>
		<h3><code>for</code>-loops</h3>
		<CodeSnippet code={snippets} key="Accumulation" />
		<Code category="message">10</Code>
		<Note category="program"><code>let mut</code> declares a mutable variable.</Note>
	</Section>

	<Section>
		<h3><code>for</code>-loops</h3>
		<Code category="ref">{`
inductive ForInStep (α : Type u) where
  -- Breaks/Returns from the loop
  | done  : α → ForInStep α
  -- Continues to the next iteration
  | yield : α → ForInStep α
class ForIn (m : Type u₁ → Type u₂) (ρ : Type u) (α : outParam (Type v)) where
  forIn {β} [Monad m] (x : ρ) (b : β) (f : α → β → m (ForInStep β)) : m β
`}</Code>
		<p><code>β</code> represents the state carried over to the next iteration</p>
	</Section>

	<Section>
		<h3><code>repeat</code>-loops</h3>
		<p>Creates an infinite loop.</p>
		<Code category="ref">{`
inductive Loop where
  | mk
partial def Loop.forIn {β : Type u} {m : Type u → Type v} [Monad m] (_ : Loop) (init : β) (f : Unit → β → m (ForInStep β)) : m β :=
  let rec @[specialize] loop (b : β) : m β := do
    match ← f () b with
      | ForInStep.done b  => pure b
      | ForInStep.yield b => loop b
  loop init
instance : ForIn m Loop Unit where
  forIn := Loop.forIn
`}</Code>
	</Section>

	<Section>
		<h3><code>while</code> loops</h3>
		<p><code>while</code> is just <code>repeat</code> with a <code>break</code></p>
		<CodeSnippet code={snippets} key="Triangle" />
		<Code category="message">15</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Monad Transformers</h2>
		<aside class="notes">What if you want to use multiple monads?</aside>
		<SlideNotes {...note('Monad Transformers')} />
	</Section>

	<Section>
		<h3><code>ReaderT</code></h3>
		<p><code>ReaderT</code> allows you to use a reader monad on top of another monad.</p>
		<CodeSnippet code={snippets} key="ReaderT" />
	</Section>

	<Section>
		<h3><code>StateT</code></h3>
		<p>Like <code>ReaderT</code>, but for a state</p>
		<CodeSnippet code={snippets} key="StateT" />
	</Section>

	<Section>
		<h3>Monad Lifting</h3>
		<p>Executing a monad inside another monad</p>
		<Code category="ref">{`
class MonadLift (m : semiOutParam (Type u → Type v)) (n : Type u → Type w) where
  /-- Lifts a value from monad \`m\` into monad \`n\`. -/
  monadLift : {α : Type u} → m α → n α
`}</Code>
		<SlideNotes {...note('Monad Lifting')} />
	</Section>

	<Section>
		<h3>Monad Lifting</h3>
		<CodeSnippet code={snippets} key="MonadLift Instance" />
		<SlideNotes {...note('Monad Lifting')} />
	</Section>

	<Section>
		<h3>Monad Lifting of <code>ReaderT</code> and <code>StateT</code></h3>
		<p><code>MonadLift</code> has been defined for these transformers</p>
		<Code category="ref">{`
instance  : MonadLift m (ReaderT ρ m) where
  monadLift x := fun _ => x
protected def lift {α : Type u} (t : m α) : StateT σ m α :=
  fun s => do let a ← t; pure (a, s)
instance : MonadLift m (StateT σ m) := ⟨StateT.lift⟩
`}</Code>
	</Section>

	<Section>
		<h3>Use cases of Monad Transformers</h3>
		<CodeSnippet code={snippets} key="RandomT" />
		<Code category="message">{`2
1`}</Code>
		<Note category="program">
			<code>abbrev</code> is a version of <code>def</code> that is transparent to type class inference.
		</Note>
		<aside class="notes">
			Reader and State monad transformers are often used to provide context and state to otherwise
			purely functional programs.
		</aside>
	</Section>

	<Section>
		<h3><code>OptionT</code> and <code>ExceptT</code></h3>
		<p>Adds early return to a monad that otherwise has no early return.</p>
		<Code lines="1-2|3-4|5-8|9-10" category="ref">{`def OptionT (m : Type u → Type v) (α : Type u) : Type v :=
  m (Option α)
protected def mk (x : m (Option α)) : OptionT m α :=
  x
protected def bind (x : OptionT m α) (f : α → OptionT m β) : OptionT m β := OptionT.mk do
  match (← x) with
  | some a => f a
  | none   => pure none
protected def pure (a : α) : OptionT m α := OptionT.mk do
  pure (some a)`}</Code>
		<SlideNotes {...note('OptionT and ExceptT')} />
	</Section>

	<Section animate>
		<h3>Example: Roulette</h3>
		<CodeSnippet code={snippets} key="Roulette" />
	</Section>

	<Section animate>
		<h3>Example: Roulette</h3>
		<p>The roulette is equivalent to</p>
		<CodeSnippet code={snippets} key="Roulette'" />
	</Section>

	<Section>
		<h3>Ordering Monad Transformers</h3>
		<p>
			If <code>T1</code> and <code>T2</code> are monad transformers, usually
			<code>T1 (T2 m)</code> and <code>T2 (T1) m</code> are fundamentally different.
		</p>
		<Note category="program">
			Two monad transformers <b>commute</b> when their orders do not matter. This is rare! For
			example, two <code>StateT α</code> monad transformers commute.
		</Note>
		<SlideNotes {...note('Ordering Monad Transformers')} />
	</Section>
</section>
