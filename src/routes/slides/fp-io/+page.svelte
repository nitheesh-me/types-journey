<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import Note from '$lib/slides/Note.svelte';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/fp-io/handout.lean?raw';
	import NotesSource from './notes.md?raw';
	import Stdio from '$handouts/fp-io/stdio.lean?raw';
	import Tasks from '$handouts/fp-io/tasks.lean?raw';
	import RefRace from '$handouts/fp-io/ref-race.lean?raw';
	import RefSync from '$handouts/fp-io/ref-sync.lean?raw';
	import Cancel from '$handouts/fp-io/cancel.lean?raw';
	import Channel from '$handouts/fp-io/channel.lean?raw';

	const title = 'IO, Exceptions, Concurrency';
	const snippets = parseSnippets(Handout);
	const note = noteLookup(NotesSource);
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section data-transition="zoom">
	<h2>{title}</h2>
	<aside class="notes">
		The overarching theme of this lecture is we can control when a computation happens.
	</aside>
</section>

<section>
	<Section>
		<h2><code>IO</code></h2>
		<SlideNotes {...note('IO')} />
	</Section>

	<Section>
		<h3>Standard Output</h3>
		<CodeSnippet lines="true" code={snippets} key="Println" />
		<Note category="program"><code>#eval</code> can also run IO monads.</Note>
		<SlideNotes {...note('Standard Output')} />
	</Section>

	<Section>
		<h3>Standard Output</h3>
		<CodeSnippet lines="true" code={snippets} key="Println'" />
		<Note category="program">
			<code>println!</code> is just <code>IO.println</code> with automatic string interpolation.
		</Note>
		<SlideNotes {...note('Standard Output')} />
	</Section>

	<Section>
		<h3>Console Standard I/O</h3>
		<p>A simple echo program</p>
		<Code>{Stdio}</Code>
	</Section>

	<Section>
		<h3>Other IO Functions</h3>
		<ul>
			<li>File Read/write</li>
			<li>Sleep</li>
			<li>Spawn subprocess</li>
		</ul>
	</Section>

	<Section>
		<h3>The Definition of <code>IO</code></h3>
		<p><code>IO</code> is a monad!</p>
		<Code category="ref">{`def EIO (ε : Type) : Type → Type := EStateM ε IO.RealWorld
abbrev IO : Type → Type := EIO IO.Error`}</Code>
		<SlideNotes {...note('The Definition of IO')} />
	</Section>

	<Section>
		<h3><code>EStateM</code></h3>
		<p><code>EStateM</code> is a state monad with exception</p>
		<Code category="ref">{`inductive Result (ε σ α : Type u) where
  | ok    : α → σ → Result ε σ α
  | error : ε → σ → Result ε σ α
def EStateM (ε σ α : Type u) := σ → Result ε σ α`}</Code>
		<SlideNotes {...note('EStateM')} />
	</Section>

	<Section>
		<h3><code>The World</code></h3>
		<Code category="ref">{`opaque IO.RealWorld : Type := Unit
#reduce IO`}</Code>
		<Code category="message">
			fun α => IO.RealWorld → EStateM.Result IO.Error IO.RealWorld α
		</Code>
		<p>
			<code>IO.RealWorld</code> is a placeholder to represent the world state outside of this program
		</p>
		<Note category="program">
			Is an impure function modifying the world, or is the world being replaced by a new world? That
			is a philosophical question.
		</Note>
		<SlideNotes {...note('The World')} />
	</Section>
</section>

<section>
	<Section>
		<h2>Exception Handling</h2>
		<SlideNotes {...note('Exception Handling')} />
	</Section>

	<Section>
		<h3>IO Exceptions</h3>
		<CodeSnippet lines="true" code={snippets} key="IO Exception" />
		<Code category="message">{`5
I can't process 0`}</Code>
	</Section>

	<Section>
		<h3><code>MonadExcept</code></h3>
		<Code category="ref">{`
class MonadExcept (ε : Type u) (m : Type v → Type w) where
  throw {α : Type v} : ε → m α
  tryCatch {α : Type v} (body : m α) (handler : ε → m α) : m α
`}</Code>
		<ul>
			<li>
				<code>throw</code> throws an error of type <code>ε</code> to the nearest catching block.
			</li>
			<li>
				<code>tryCatch</code> executes <code>body</code> and calls <code>handler</code> for any error.
			</li>
		</ul>
		<SlideNotes {...note('MonadExcept')} />
	</Section>

	<Section>
		<h3>The <code>try</code>-<code>catch</code> block</h3>
		<p>Lean provides a syntactic sugar for immediate return after match failure.</p>
		<CodeSnippet lines="true" code={snippets} key="Throw Syntactic Sugar" />
	</Section>

	<Section>
		<h3>The <code>finally</code> Block</h3>
		<Code category="ref">{`
class MonadFinally (m : Type u → Type v) where
  tryFinally' {α β} : m α → (Option α → m β) → m (α × β)
@[always_inline, inline]
def tryFinally {m : Type u → Type v} {α β : Type u} [MonadFinally m] [Functor m] (x : m α) (finalizer : m β) : m α :=
  let y := tryFinally' x (fun _ => finalizer)
  (·.1) <$> y
`}</Code>
		<p>
			The "finalizer" is executed regardless of the success or failure of <code>x</code>
		</p>
	</Section>

	<Section>
		<h3>The <code>try</code>-<code>catch</code>-<code>finally</code> block</h3>
		<CodeSnippet lines="true" code={snippets} key="Finally" />
		<Code category="message">{`5
I can't process 0
This will run regardless`}</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<ul>
			<li>
				Can <code>MonadExcept</code> be implemented for the <code>Option</code> type? What is
				<code>ε</code>?
			</li>
			<li>
				Does it make sense to define <code>MonadFinally</code> for <code>Option</code>? What about
				<code>Id</code>?
			</li>
		</ul>
	</Section>

	<Section>
		<h3>Panic</h3>
		<CodeSnippet lines="true" code={snippets} key="Panic" />
		<Code category="message">can't handle this case</Code>
		<Note category="program">
			<code>panic</code> (and the string interpolated <code>panic!</code>) can be used for pure
			function as well, but it requires whatever type it replaces to inhabitable.
		</Note>
		<SlideNotes {...note('Panic')} />
	</Section>
</section>

<section>
	<Section>
		<h2>Concurrency and References</h2>
		<SlideNotes {...note('Concurrency and References')} />
	</Section>

	<Section>
		<h3>Tasks</h3>
		<p><code>IO</code> can be executed concurrently</p>
		<ul>
			<li>
				<code>EIO.asTask</code>: Executes an <code>IO</code> monad asynchronously. Returns
				<code>Task</code> object
			</li>
			<li><code>Task.pure</code>: Construct a task which is already finished</li>
			<li><code>Task.get</code>: Wait until a task is done, and fetches its return value</li>
		</ul>
		<SlideNotes {...note('Tasks')} />
	</Section>

	<Section>
		<h3>Tasks</h3>
		<Code>{Tasks}</Code>
		<Code category="message">{`2
1
1, 4`}</Code>
		<SlideNotes {...note('Tasks')} />
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>Modify the previous example so a variable number of tasks can be run</p>
	</Section>

	<Section>
		<h3>References</h3>
		<p>
			Lean provides functions to synchronize data between tasks.
			<Code category="ref">{`
opaque mkRef {σ α} (a : α) : ST σ (Ref σ α)
opaque Ref.get {σ α} (r : @& Ref σ α) : ST σ α
opaque Ref.set {σ α} (r : @& Ref σ α) (a : α) : ST σ Unit
opaque Ref.swap {σ α} (r : @& Ref σ α) (a : α) : ST σ α
`}</Code>
			<Note category="program">
				<code>ST</code> is another monad! Don't worry. It automatically lifts to <code>IO</code>.
			</Note>
		</p>
		<SlideNotes {...note('References')} />
	</Section>

	<Section animate>
		<h3>Synchronization</h3>
		<Code id="ref-sync">{RefRace}</Code>
		<p>The output is randomly 1,2, or 3</p>
		<Note category="program">
			This is an example of <b>race condition</b>: The program's output depends on the order of thread
			execution.
		</Note>
		<SlideNotes {...note('Synchronization')} />
	</Section>

	<Section animate>
		<h3>Synchronization</h3>
		<Code id="ref-sync">{RefSync}</Code>
		<p>The output is consistently 3</p>
		<SlideNotes {...note('Synchronization')} />
	</Section>

	<Section>
		<h3>Mutex</h3>
		<Code category="ref">{`
def Mutex.new (a : α) : BaseIO (Mutex α)
def Mutex.atomically [Monad m] [MonadLiftT BaseIO m] [MonadFinally m]
    (mutex : Mutex α) (k : AtomicT α m β) : m β
`}</Code>
		<Note category="program">
			<code>AtomicT</code> is a monad transformer which makes available <code>get</code> and
			<code>set</code> to modify the Mutex's state. Mutexes guard <i>data</i>, not <i>code</i>. (like
			Rust)
		</Note>
		<SlideNotes {...note('Mutex')} />
	</Section>

	<Section animate>
		<h3>Cancellation</h3>
		<Code category="ref">{`/-- Check if the task's cancellation flag has been set by calling \`IO.cancel\` or dropping the last reference to the task. -/
@[extern "lean_io_check_canceled"] opaque checkCanceled : BaseIO Bool

/-- Request cooperative cancellation of the task. The task must explicitly call \`IO.checkCanceled\` to react to the cancellation. -/
@[extern "lean_io_cancel"] opaque cancel : @& Task α → BaseIO Unit`}</Code>
		<Note category="program">
			Lean's concurrency model is <i>coöperative</i>: A long-running task is responsible for checking
			cancellation flags and halting on its own accord.
		</Note>
		<SlideNotes {...note('Cancellation')} />
	</Section>

	<Section animate>
		<h3>Cancellation</h3>
		<Code>{Cancel}</Code>
		<SlideNotes {...note('Cancellation')} />
	</Section>

	<Section animate>
		<h3>Channel</h3>
		<Code category="ref">{`def Channel.new : BaseIO (Channel α)
def Channel.send (ch : Channel α) (v : α) : BaseIO Unit
def Channel.close (ch : Channel α) : BaseIO Unit
def Channel.recv? (ch : Channel α) : BaseIO (Task (Option α))`}</Code>
		<SlideNotes {...note('Channel')} />
	</Section>

	<Section animate>
		<h3>Channel</h3>
		<Code>{Channel}</Code>
		<SlideNotes {...note('Channel')} />
	</Section>

	<Section>
		<h3>Other Synchronization Primitives</h3>
		<ul>
			<li><code>BaseMutex</code>: Mutex with no guarded data</li>
			<li><code>Promise</code>: Can be fulfilled by another thread</li>
			<li><code>CancelToken</code>: A flag to cancel a computation</li>
			<li><code>Condvar</code>: Waits on a resource to become available</li>
		</ul>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>
			Implement a <code>Channel</code> with <code>Mutex</code> and a <code>List</code>. This channel
			would not be very efficient.
		</p>
	</Section>
</section>

<section>
	<Section>
		<h2>Interlude: Setting up a Lean Project</h2>
		<SlideNotes {...note('Interlude: Setting up a Lean Project')} />
	</Section>

	<Section>
		<h3>Why Setup a Lean Project?</h3>
		<p>Create a Lean project when you need to</p>
		<ul>
			<li>Use dependencies</li>
			<li>Have multiple inter-dependent files</li>
			<li>Build shared libraries</li>
		</ul>
	</Section>

	<Section>
		<h3><code>lake</code></h3>
		<p><code>lake</code> is Lean's build system. It comes bundled with a Lean installation.</p>
		<Code category="terminal" language="sh">$ lake -h</Code>
		<Note category="program">
			If you forget about a <code>lake</code> command, use the <code>-h</code> flag to read its manual.
		</Note>
		<SlideNotes {...note('lake')} />
	</Section>

	<Section>
		<h3>Creating a Lean project</h3>
		<Code category="terminal" language="sh">{`$ lake new MyProject
$ ls MyProject/
Main.lean  MyProject/  MyProject.lean  README.md  lakefile.lean  lean-toolchain`}</Code>
		<Note category="program">
			The similar <code>lake init</code> command creates a project in the current directory.
		</Note>
	</Section>

	<Section>
		<h3>Components of a Lean project</h3>
		<ul>
			<li><code>Main.lean</code>: Executable entry (not generated for library projects)</li>
			<li><code>MyProject/</code>: Lean source code</li>
			<li><code>MyProject.lean</code>: Lean library root</li>
			<li><code>README.md</code>: Documentation stub</li>
			<li><code>lakefile.toml</code>: Project specification</li>
			<li><code>lean-toolchain</code>: Lean version pin</li>
			<li>A Git repository is also generated by default</li>
		</ul>
	</Section>

	<Section>
		<h3>Build commands</h3>
		<Code category="terminal" language="sh">{`$ lake build # Builds the project library
$ lake exe myproject # Runs the main executable`}</Code>
		<Note category="program">
			Build outputs are in <code>.lake/</code> if you need them.
		</Note>
	</Section>

	<Section animate>
		<h3>Dependency Management</h3>
		<p>Add a dependency by modifying the <code>lakefile.toml</code> file</p>
		<Code language="toml" lines="5-8">{`name = "MyProject"
version = "0.1.0"
defaultTargets = ["myproject"]

[[require]]
name = "aesop"
scope = "leanprover-community"
rev = "v4.18.0"

...`}</Code>
	</Section>

	<Section animate>
		<h3>Dependency Management</h3>
		<p>Execute <code>lake update</code> to generate a <i>manifest file</i></p>
		<Code category="terminal">$ lake update</Code>
	</Section>

	<Section animate>
		<h3>Dependency Management</h3>
		<p>Aesop is now available after updating</p>
		<Code>{`-- Main.lean
import Aesop

def main : IO Unit := do
  ...`}</Code>
	</Section>

	<Section>
		<h3>Exercise</h3>
		<p>Setup a Lean project and replicate the <code>cat</code> command</p>
	</Section>

	<Section>
		<h3>Installing the Mathlib dependency</h3>
		<p>Create a library project with <code>lake</code>, and add</p>
		<Code language="toml" lines="5-8">{`name = "MyProject"
version = "0.1.0"
defaultTargets = ["myproject"]

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.18.0"

...`}</Code>
	</Section>

	<Section>
		<h3>Fetching cache</h3>
		<p>
			<code>lake exe cache get</code> downloads a pre-built cache so you don't have to build Mathlib (takes
			a while!)
		</p>
		<Code category="terminal">{`$ lake update mathlib
$ lake exe cache get
$ lake build`}</Code>
	</Section>
</section>

<section>
	<Section>
		<h2>Project Logistics</h2>
		<SlideNotes {...note('Project Logistics')} />
	</Section>

	<Section>
		<h3>Formalize Something!</h3>
		<ul>
			<li>(Easy) Formalize a solution to a (at least undergraduate level) textbook math or CS problem</li>
			<li>
				(Medium) Formalize a board game that has not been done before. e.g. chess. The formalization
				should be at a level where it is possible to prove winning conditions.
			</li>
			<li>(Medium) Formalize cryptographic primitives</li>
			<li>(Hard) Contribute to mathlib4 or other Lean formalization libraries</li>
			<li>(Hard) Fix a Lean bug</li>
		</ul>
	</Section>

	<Section>
		<h3>Loogle</h3>
		<p>Use <code>https://loogle.lean-lang.org/</code> to find definitions.</p>
	</Section>
</section>
