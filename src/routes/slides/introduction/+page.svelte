<script lang="ts">
	import Section from '$lib/slides/Section.svelte';
	import Code from '$lib/slides/Code.svelte';
	import CodeSnippet from '$lib/slides/CodeSnippet.svelte';
	import CodeCompare from '$lib/slides/CodeCompare.svelte';
	import Citation from '$lib/slides/Citation.svelte';
	import Diagram from '$lib/slides/Diagram.svelte';
	import Note from '$lib/slides/Note.svelte';
	import { base } from '$app/paths';
	import SlideNotes from '$lib/notes/SlideNotes.svelte';
	import { noteLookup } from '$lib/notes/parse';
	import { parseSnippets } from '$lib/slides/snippets';
	import Handout from '$handouts/introduction/handout.lean?raw';
	import NotesSource from './notes.md?raw';
	import Collections from '$handouts/introduction/collections.lean?raw';
	import Io from '$handouts/introduction/io.lean?raw';
	import Csv from '$handouts/introduction/csv.lean?raw';
	import * as cmp from './compare';

	const title = 'Types, and why Lean';

	const note = noteLookup(NotesSource);
	const h = parseSnippets(Handout);
	const coll = parseSnippets(Collections);
	const io = parseSnippets(Io);
	const csv = parseSnippets(Csv);

	// ── Diagrams ───────────────────────────────────────────────────────────
	const obligations = `
flowchart LR
  P1["authenticate<br/>produces Admin"] --> T["UserType"]
  P2["processJob<br/>produces System"] --> T
  T --> C1["authorize<br/>must handle each"]
  T --> C2["render<br/>must handle each"]
  T --> C3["audit<br/>must handle each"]
`;

	const jigsaw = `
flowchart LR
  G["Specification<br/>the picture on the box"] --> F["Partial<br/>implementation"]
  P["Candidate<br/>pieces"] --> F
  F --> Q{"Does it fit<br/>the hole?"}
  Q -->|type checks| K["Keep"]
  Q -->|does not| D["Discard"]
`;

	// The syntax-and-semantics picture, revealed one layer at a time.
	const layers1 = `
flowchart TD
  subgraph PM["Pure math"]
    direction LR
    S["All possible<br/>combinations of symbols"] -->|Syntax| V["Logically valid<br/>statements"]
  end
`;
	const layers2 =
		layers1 +
		`
  subgraph SM["Scientific models"]
    Y["Symbolic models"]
  end
  V --> Y
`;
	const layers3 =
		layers1 +
		`
  subgraph SM["Scientific models"]
    direction LR
    Y["Symbolic models"] --> C["Computable models"]
  end
  V --> Y
`;
	const layers4 =
		layers3 +
		`
  subgraph SS["Scientific software"]
    K["Code"]
  end
  C --> K
`;
	const layers5 =
		layers4 +
		`
  subgraph R["Reality"]
    RE["Reality"]
  end
  Y --> RE
  K --> RE
`;

	const testing = `
flowchart LR
  P["Program"] --> T["Test"]
  T -->|fails| DBG["Debug"]
  DBG --> P
  T -->|passes| OK["Code that<br/>passes the tests"]
`;

	const proving = `
flowchart LR
  SP["Specify"] --> P["Program"]
  P --> PR["Prove"]
  PR -->|does not| DBG["Debug"]
  DBG --> P
  PR -->|does| OK["Code that is<br/>correct"]
`;

	const kitchen = `
flowchart LR
  K["Kitchen<br/>pure, total, verified"] --> W["Waiter<br/>IO"]
  W --> D["Dining room<br/>messy, unpredictable"]
  D --> W
  W --> K
`;
</script>

<svelte:head>
	<title>{title} | Slides</title>
</svelte:head>

<section data-transition="zoom">
	<h2>{title}</h2>
	<p><small>An introduction</small></p>
	<aside class="notes">
		The whole lecture argues one thing: a type system is a machine for moving obligations around.
	</aside>
</section>

<!-- ═══════════════ 1. Does software work? ═══════════════ -->
<section>
	<Section>
		<h2>Does software work?</h2>
		<SlideNotes {...note('Does software work?')} />
	</Section>

	<Section>
		<h3>An answer we all agree on</h3>
		<p>Software <i>should</i> work.</p>
		<p class="fragment">Nobody argues with this. We disagree about what to do about it.</p>
	</Section>

	<Section>
		<h3>Fifteen years ago</h3>
		<p>If you wanted static types on a large system, you had two mainstream options.</p>
		<ul>
			<li><b>Java</b>: infamously conservative, and deeply entangled with OOP</li>
			<li><b>C++</b>: extremely complex, and unsound</li>
		</ul>
	</Section>

	<Section>
		<h3>Java: conservative by design</h3>
		<p>
			No sum types. No pattern matching. Generics erased at runtime. Every abstraction had to be a
			class, so the type system taught you object orientation whether you wanted it or not.
		</p>
		<Note category="program">
			Java has since grown sealed interfaces and pattern matching. But this is what a generation
			learned "static typing" to mean.
		</Note>
	</Section>

	<Section>
		<h3>C++: types as sizes</h3>
		<p>
			In C++ a type largely answers <i>how many bytes, laid out how</i>. That is a representation
			question rather than a meaning question, and the escape hatches are everywhere.
		</p>
		<Code language="cpp">{`int* p = reinterpret_cast<int*>(&some_float);
unsigned n = 5;
n - 6;              // 4294967295, silently
std::vector<int> v;
v[10];              // undefined behaviour, no diagnostic`}</Code>
		<SlideNotes {...note('C++: types as sizes')} />
	</Section>

	<Section>
		<h3>When types cost more than they give</h3>
		<p>
			If a type system mainly catches mistakes like <code>int</code> versus <code>String</code>,
			while making ordinary programs more verbose and rigid, the trade-off can look pretty bad.
		</p>
		<p class="fragment">
			That is one reason languages such as Python, Ruby, and JavaScript became so attractive:
			they let programmers move quickly without requiring every detail to be expressed in the type system.
		</p>
		<Note category="program">
			The point is not that dynamic languages are "bad". They made a sensible trade:
			less static checking in exchange for flexibility and lower upfront cost.
		</Note>
	</Section>


	<Section>
		<h3>Then a renaissance: Rust</h3>
		<ul>
			<li>Soundness taken seriously</li>
			<li>Sum types (<code>enum</code>) and exhaustive pattern matching</li>
			<li>Traits and associated types instead of inheritance</li>
			<li>Ownership: a resource discipline expressed <i>in the type system</i></li>
		</ul>
	</Section>

	<Section>
		<h3>And TypeScript</h3>
		<ul>
			<li>Structural typing: shapes rather than names</li>
			<li>Inference good enough that annotations feel optional</li>
			<li>Type-level programming: conditional types, mapped types, template literal types</li>
		</ul>
		<Note category="metaprog">
			TypeScript is deliberately unsound. It chose "useful on real JavaScript" over "cannot go
			wrong", and that choice is why it won.
		</Note>
	</Section>

	<Section>
		<h3>Static typing is cool now?</h3>
		<p>Apparently. Every popular dynamic language has grown a gradual type system.</p>
		<p class="fragment">Python has annotations and mypy. Ruby has RBS. PHP has declared types.</p>
	</Section>

	<Section>
		<h3>A type checker is not an oracle</h3>
		<p>It is a program. Somebody wrote it. You can read it.</p>
		<p class="fragment">
			This lecture is partly about making that concrete: in Lean the rules are small enough to hold
			in your head, and the checker is not hiding anything.
		</p>
	</Section>

	<Section>
		<h3>What do we actually need?</h3>
		<p>For most systems, a type checker needs surprisingly little:</p>
		<ol>
			<li>Some form of <b>product</b> types: this <i>and</i> that</li>
			<li>Some form of <b>sum</b> types: this <i>or</i> that</li>
			<li><b>Exhaustive pattern matching</b> on the cases of a sum, also called case analysis</li>
		</ol>
		<p class="fragment">Nearly everything in this lecture is built from those three.</p>
		<SlideNotes {...note('What do we actually need?')} />
	</Section>
</section>

<!-- ═══════════════ 2. What is a type? ═══════════════ -->
<section>
	<Section>
		<h2>What is a type?</h2>
		<SlideNotes {...note('What is a type?')} />
	</Section>

	<Section>
		<h3>First answer: a restriction</h3>
		<p>
			A type carves a subset out of the values that already exist. <code>Nat</code> is
			<code>Int</code> where the value is at least zero.
		</p>
		<Code category="example" language="lean">{`// The type as a predicate over a bigger set.
def Nat  :=  { n : Int  //  n >= 0 }`}</Code>
	</Section>

	<Section>
		<h3>Second answer: a construction</h3>
		<p>
			A type introduces a new set of values by saying how to build them. <code>Nat</code> is zero, or
			the successor of a <code>Nat</code>.
		</p>
		<Code category="example">{`inductive Nat where
  | zero
  | succ (n : Nat)`}</Code>
	</Section>

	<Section>
		<h3>Negative space and positive space</h3>
		<div class="two-up">
			<div>
				<h4>Negative</h4>
				<p>Start with everything, then rule things out. "Not negative."</p>
			</div>
			<div>
				<h4>Positive</h4>
				<p>Start with nothing, then say what can be built. "Zero, or one more than one of these."</p>
			</div>
		</div>
		<p class="fragment">The second one is checkable by construction. The first needs a proof.</p>
		<SlideNotes {...note('Negative space and positive space')} />
	</Section>

	<Section>
		<h3>Nat, four ways</h3>
		<CodeCompare columns={cmp.natType} focus="Lean" />
	</Section>

	<Section>
		<h3>A non-empty list</h3>
		<p>The restriction reading:</p>
		<Code language="rust">{`NonEmptyList<T>  =  { xs : List<T>  |  xs.length > 0 }`}</Code>
		<p class="fragment">
			Which is fine, until someone builds one and you have to check. Every time.
		</p>
	</Section>

	<Section>
		<h3>The same thing, constructed</h3>
		<p>"At least one" is just <i>one element, and then zero or more</i>.</p>
		<CodeCompare columns={cmp.nonEmpty} focus="Lean" />
	</Section>

	<Section>
		<h3>A list of even length</h3>
		<p>
			Same move. A list with an even number of elements is a list of <i>pairs</i>.
		</p>
		<Code language="rust">{`EvenList<T>  =  List<(T, T)>`}</Code>
		<p class="fragment">No check. No proof obligation. The property is arithmetic on the shape.</p>
	</Section>

	<Section>
		<h3>Isn't this cheating?</h3>
		<p>
			It feels like a trick: we did not enforce the property, we picked a representation that cannot
			express its violation.
		</p>
		<p class="fragment">That is not cheating. That is the whole technique.</p>
		<SlideNotes {...note("Isn't this cheating?")} />
	</Section>

	<Section>
		<h3>Decouple representation from interpretation</h3>
		<p>
			There is no <i>privileged</i> representation of a concept. <code>List&lt;(T, T)&gt;</code> and
			"a list whose length is even" describe the same set of values; only one of them can be got
			wrong.
		</p>
		<Note category="math">
			Choosing the representation is a design act, and it is where most of the correctness is won or
			lost.
		</Note>
		<SlideNotes {...note('Decouple representation from interpretation')} />
	</Section>

	<Section>
		<h3>A worked example</h3>
		<p>A user has an id, and contact details. At least one of email or phone must be set.</p>
		<Code language="rust">{`struct User {
    id: u64,
    email: Option<EmailAddress>,
    phone: Option<PhoneNumber>,
    // ...and at least one of them is Some. Somehow.
}`}</Code>
	</Section>

	<Section>
		<h3>The dependent-type temptation</h3>
		<p>You could try to say it directly:</p>
		<Code language="rust">{`struct User {
    id: u64,
    email: Option<EmailAddress>,
    phone: if email == None { PhoneNumber }
           else { Option<PhoneNumber> },
}`}</Code>
		<p class="fragment">
			You <i>can</i> do this in Lean. But look what happens if you just enumerate instead.
		</p>
	</Section>

	<Section>
		<h3>Enumerate the cases</h3>
		<p>Two optional fields with a constraint become three cases with none.</p>
		<CodeCompare columns={cmp.contactSum} focus="Lean" />
	</Section>

	<Section>
		<h3>Now add system users</h3>
		<p>System accounts have no contact details at all. Two ways to absorb that:</p>
		<CodeCompare columns={cmp.contactFlag} focus="The case" />
		<SlideNotes {...note('Now add system users')} />
	</Section>

	<Section>
		<h3>Why the second one wins</h3>
		<ul>
			<li>Four states and four meanings, with no combination you can build that means nothing</li>
			<li>Every <code>match</code> stops compiling until it is updated</li>
			<li>The type checker hands you the list of places to think about</li>
		</ul>
	</Section>

	<Section>
		<h3>It is not always this easy</h3>
		<p>A time range, where the start must not be after the end:</p>
		<CodeCompare columns={cmp.timeRange} focus="Cannot be wrong" />
		<SlideNotes {...note('It is not always this easy')} />
	</Section>

	<Section>
		<h3>So how do you choose?</h3>
		<p>
			We have been picking representations by taste. To do better we need to answer a prior
			question.
		</p>
		<p class="fragment"><b>What is the type system <i>for</i>?</b></p>
	</Section>
</section>

<!-- ═══════════════ 3. What is a type system for? ═══════════════ -->
<section>
	<Section>
		<h2>What is a type system for?</h2>
		<SlideNotes {...note('What is a type system for?')} />
	</Section>

	<Section>
		<h3>Candidate: it stops nonsense</h3>
		<Code language="typescript">{`1 + "some string"`}</Code>
		<p>
			True, and worth something. But this is the least interesting thing a type system does, and it
			is not why anyone reaches for one on a large system.
		</p>
	</Section>

	<Section>
		<h3>Candidate: it proves my program correct</h3>
		<p>
			Occasionally. Mostly it proves a handful of shallow properties, and "correct" was never
			written down anywhere to be proved against.
		</p>
	</Section>

	<Section>
		<h3>Candidate: taxonomy of the domain</h3>
		<p>
			Playing Linnaeus with your product domain, a class per noun. This is how a lot of enterprise
			code gets written, and the taxonomy is usually obsolete within two quarters.
		</p>
	</Section>

	<Section>
		<h3>Candidate: maximally precise runtime shapes</h3>
		<p>
			Specifying exactly what is in memory. Useful for serialisation; it tells you nothing about
			what your program is obliged to do.
		</p>
	</Section>

	<Section>
		<h3>My answer</h3>
		<p class="big">
			A type system keeps track of the different <b>cases you have to handle</b>.
		</p>
		<SlideNotes {...note('My answer')} />
	</Section>

	<Section>
		<h3>Where values are produced</h3>
		<CodeCompare columns={cmp.userTypeProduce} />
	</Section>

	<Section>
		<h3>Now add one case</h3>
		<Code language="rust">{`enum UserType {
    Standard,
    Admin,
    System,
    Api,        // <- new
}`}</Code>
		<p class="fragment">
			The type checker now names every consumer that has to decide what an API user means. Not a
			grep, but an exhaustive list.
		</p>
		<SlideNotes {...note('Now add one case')} />
	</Section>

	<Section>
		<h3>An obligation propagation machine</h3>
		<Diagram source={obligations} height="380px" />
		<p>
			The type system relates the places you <b>produce</b> values to the places you
			<b>consume</b> them, and carries obligations along those edges.
		</p>
	</Section>

	<Section>
		<h3>A second example</h3>
		<Code>{`def calculateTotal (entries : List InventoryLogEntry) : Int :=
  (entries.map (·.change)).sum`}</Code>
		<p>
			We know the log is never empty. Does it matter here?
		</p>
		<p class="fragment">No. <code>sum</code> of an empty list is <code>0</code>, which is right.</p>
		<SlideNotes {...note('A second example')} />
	</Section>

	<Section>
		<h3>Now the same data, a different question</h3>
		<Code>{`def getLastChanged (entries : List InventoryLogEntry) : Timestamp :=
  match entries.head? with
  | some latest => latest.timestamp
  | none => panic! "shouldn't happen"`}</Code>
		<p class="fragment">
			"Shouldn't happen" is a claim the type system cannot check, in a branch you have to write
			anyway.
		</p>
	</Section>

	<Section>
		<h3>Shrink the type instead</h3>
		<CodeCompare columns={cmp.totality} focus="Total (cannot)" />
		<p>The impossible branch is gone, because the case is gone.</p>
		<SlideNotes {...note('Shrink the type instead')} />
	</Section>

	<Section>
		<h3>Make illegal states unrepresentable</h3>
		<p>Which is another way of saying: <b>write total functions</b>.</p>
		<ul>
			<li>A total function has an answer for every input its type admits</li>
			<li>If you cannot answer, the type was too wide</li>
			<li>Narrow the input, or widen the output, but decide it in the type</li>
		</ul>
	</Section>

	<Section>
		<h3>Option is the other direction</h3>
		<p>
			Widening the output moves the obligation <i>outward</i>, to the caller. Narrowing the input
			moves it <i>inward</i>, to whoever constructs the value.
		</p>
		<Code>{`def find  : List α → Option α        -- caller must handle none
def first : NonEmptyList α → α       -- builder must supply one`}</Code>
	</Section>

	<Section>
		<h3>The point</h3>
		<p class="big">Types let you move obligations around.</p>
		<p>
			Not eliminate them, because obligations do not vanish. You choose <i>who</i> discharges them, and
			<i>where</i>.
		</p>
		<SlideNotes {...note('The point')} />
	</Section>
</section>

<!-- ═══════════════ 4. Type, define, refine ═══════════════ -->
<section>
	<Section>
		<h2>Type, define, refine</h2>
		<SlideNotes {...note('Type, define, refine')} />
	</Section>

	<Section>
		<h3>The loop</h3>
		<p>
			If types move obligations, then designing a type is deciding where the obligations go. That
			is a working method, not just a way of thinking.
		</p>
		<ol>
			<li><b>Type</b>: write down the shape of the problem</li>
			<li><b>Define</b>: write something that fits</li>
			<li><b>Refine</b>: make the type more precise, and repeat</li>
		</ol>
	</Section>

	<Section>
		<h3>Programming as a jigsaw</h3>
		<Diagram source={jigsaw} height="400px" />
	</Section>

	<Section>
		<h3>Why the jigsaw works</h3>
		<p>
			You have a goal, a partial implementation, and candidate pieces. The shape of the hole rules
			out almost everything. You are not searching, you are eliminating.
		</p>
		<Note category="metaprog">
			This is not a metaphor in Lean. `exact?` and `apply?` really do search the library for terms
			of the right type.
		</Note>
		<SlideNotes {...note('Why the jigsaw works')} />
	</Section>

	<Section>
		<h3>Precision and confidence</h3>
		<p class="big">
			The more precise the specification, the fewer the programs that satisfy it, and the more
			confident you can be in the one you wrote.
		</p>
	</Section>

	<Section>
		<h3>A digression: infrastructure as code</h3>
		<ul>
			<li><b>Ansible</b>: YAML</li>
			<li><b>Kubernetes</b>: YAML</li>
			<li><b>Helm</b>: a package manager for YAML, templated with string substitution</li>
			<li><b>Terraform</b>: HCL, and a type system that arrived late</li>
			<li><b>GitHub Actions</b>: YAML, with shell inside strings inside YAML</li>
		</ul>
		<SlideNotes {...note('A digression: infrastructure as code')} />
	</Section>

	<Section>
		<h3>Does any of this type check?</h3>
		<Code language="yaml">{`replicas: "3"        # string or number? depends who is reading
enabled: yes         # YAML 1.1 says boolean, YAML 1.2 says string
port: 08080          # leading zero: octal, in some parsers
version: 1.10        # a float, so 1.1`}</Code>
		<p class="fragment">
			This is the configuration of production systems, and it is stringly typed.
		</p>
		<SlideNotes {...note('Does any of this type check?')} />
	</Section>

	<Section>
		<h3>The retrofits</h3>
		<ul>
			<li><b>JSON Schema</b>: structure after the fact, no abstraction, no reuse worth the name</li>
			<li><b>yaml.org type repository</b>: tags almost nobody writes</li>
			<li><b>CRD validation</b>: a schema language embedded in the thing it validates</li>
		</ul>
		<p class="fragment">
			Each is a partial answer to a question that a real type system answers completely.
		</p>
	</Section>

	<Section>
		<h3>What you would actually want</h3>
		<p>
			Products, sums and pattern matching, the same three ingredients, over your deployment
			topology. That is not exotic. It is Tuesday, in any language with an <code>enum</code>.
		</p>
	</Section>
</section>

<!-- ═══════════════ 5. Three views ═══════════════ -->
<section>
	<Section>
		<h2>Three views of type theory</h2>
		<SlideNotes {...note('Three views of type theory')} />
	</Section>

	<Section>
		<h3>The same subject, three vocabularies</h3>
		<p>Type theory is studied from mathematics, from logic, and from computer science.</p>
		<p class="fragment">
			They are not three subjects. They are three groups who found the same object and named it
			differently.
		</p>
	</Section>

	<Section>
		<h3>Mathematics</h3>
		<Citation
			field="Mathematics"
			title="Homotopy Type Theory: Univalent Foundations of Mathematics"
			authors="The Univalent Foundations Program"
			venue="Institute for Advanced Study, 2013"
			quote="Types may be regarded as spaces, or as higher groupoids."
			href="https://homotopytypetheory.org/book/"
			cover="{base}/citation/hott-cover.png"
			coverCredit="Cover reproduced under CC BY-SA 3.0."
		/>
	</Section>

	<Section>
		<h3>Mathematics, computationally</h3>
		<Citation
			field="Mathematics"
			title="Naive Computational Type Theory"
			authors="Robert L. Constable"
			venue="Cornell / Proof and System-Reliability, 2002"
			quote="Types are built from a few simple constructors, and every type has a computational meaning."
			href="https://www.cs.cornell.edu/home/rc/"
		/>
	</Section>

	<Section>
		<h3>Logic</h3>
		<Citation
			field="Logic"
			title="Propositions as Types"
			authors="Philip Wadler"
			venue="Communications of the ACM, 2015"
			quote="Propositions correspond to types, proofs to programs, and simplification of proofs to evaluation of programs."
			href="https://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-types/propositions-as-types.pdf"
		/>
	</Section>

	<Section>
		<h3>Why that correspondence matters</h3>
		<p>
			If a proposition is a type and a proof is a program, then a proof assistant is a compiler and a
			theorem is a function signature.
		</p>
		<p class="fragment">Lean is what happens when you build a language on that idea.</p>
		<SlideNotes {...note('Why that correspondence matters')} />
	</Section>

	<Section>
		<h3>Computer science</h3>
		<Citation
			field="Computer science"
			title="Type Systems"
			authors="Luca Cardelli"
			venue="The Computer Science and Engineering Handbook, 1997"
			quote="A type system's purpose is to prevent the occurrence of execution errors during the running of a program."
			href="http://lucacardelli.name/Papers/TypeSystems.pdf"
		/>
	</Section>

	<Section>
		<h3>Computer science, at length</h3>
		<Citation
			field="Computer science"
			title="Type Theory and Functional Programming"
			authors="Simon Thompson"
			venue="Addison-Wesley, 1991. Available free from the author"
			quote="A treatment of type theory as a programming logic, rather than as a branch of proof theory."
			href="https://www.cs.kent.ac.uk/people/staff/sjt/TTFP/"
		/>
	</Section>

	<Section>
		<h3>And in practice</h3>
		<Citation
			field="Computer science"
			title="Type-Driven Development with Idris"
			authors="Edwin Brady"
			venue="Manning, 2017"
			quote="Write the type first, and let it guide the implementation."
			href="https://www.manning.com/books/type-driven-development-with-idris"
		/>
	</Section>
</section>

<!-- ═══════════════ 6. The core questions ═══════════════ -->
<section>
	<Section><h2>The questions themselves</h2></Section>

	<Section>
		<h3>What is a type?</h3>
		<p>A collection of values, together with the operations that make sense on them.</p>
		<p class="fragment">
			In Lean, more precisely: a type is a term, and its inhabitants are the terms that can be built
			by its constructors.
		</p>
		<SlideNotes {...note('What is a type?#2')} />
	</Section>

	<Section>
		<h3>What is a type system?</h3>
		<p>
			A set of rules assigning types to the pieces of a program, plus an algorithm that checks the
			assignment is consistent.
		</p>
		<p class="fragment">
			Rules, and a program that applies them. There is no third ingredient.
		</p>
	</Section>

	<Section>
		<h3>Four kinds of dependency</h3>
		<p>Rules relating what to what? There are only four combinations.</p>
		<table class="quadrants">
			<thead>
				<tr><th></th><th>indexed by a <b>term</b></th><th>indexed by a <b>type</b></th></tr>
			</thead>
			<tbody>
				<tr>
					<th>a <b>term</b></th>
					<td>Functions</td>
					<td>Generics, overloading</td>
				</tr>
				<tr>
					<th>a <b>type</b></th>
					<td class="win">Dependent types</td>
					<td>Templates, type variables</td>
				</tr>
			</tbody>
		</table>
		<p class="fragment">Three of these you use every day. The fourth is why we are here.</p>
		<SlideNotes {...note("Four kinds of dependency")} />
	</Section>

	<Section>
		<h3>A term indexed by a term</h3>
		<p>The ordinary function. Give it a value, get a value back.</p>
		<CodeSnippet code={h} key="Term on Term" />
		<p>Nobody argues about this one, which is exactly why it is the baseline.</p>
		<SlideNotes {...note("A term indexed by a term")} />
	</Section>

	<Section>
		<h3>A term indexed by a type</h3>
		<p>One definition that works for every element type. The type is the argument.</p>
		<CodeCompare columns={cmp.termOnType} focus="Lean" />
		<SlideNotes {...note("A term indexed by a type")} />
	</Section>

	<Section>
		<h3>The same box, filled differently</h3>
		<p>
			Overloading also lives here. The type does not parameterise the body, it <i>selects</i> it.
		</p>
		<CodeCompare columns={cmp.overloading} focus="Lean" />
		<SlideNotes {...note("The same box, filled differently")} />
	</Section>

	<Section>
		<h3>Both halves, in Lean</h3>
		<p>
			The generic function takes the type as an argument. The type class lets the type choose the
			body.
		</p>
		<CodeSnippet lines="true" code={h} key="Term on Type" />
	</Section>

	<Section>
		<h3>A note on inheritance</h3>
		<p>
			Virtual dispatch belongs to the same family: the term that runs is chosen by a type, just at
			run time rather than compile time.
		</p>
		<Note category="program">
			Strictly, subtyping is its own axis rather than one of these four. It is worth separating,
			because inheritance answers "which body runs" while generics answer "for which types does one
			body work".
		</Note>
		<SlideNotes {...note("A note on inheritance")} />
	</Section>

	<Section>
		<h3>A type indexed by a type</h3>
		<p>
			<code>List</code> is not a type. It is a function from types to types, and
			<code>List Nat</code> is what you get by applying it.
		</p>
		<CodeCompare columns={cmp.typeOnType} focus="Lean" />
		<SlideNotes {...note("A type indexed by a type")} />
	</Section>

	<Section>
		<h3>Type constructors, in Lean</h3>
		<CodeSnippet lines="true" code={h} key="Type on Type" />
		<p>
			<code>List</code> has type <code>Type u → Type u</code>. It really is a function, and it is
			applied the same way everything else is.
		</p>
	</Section>

	<Section>
		<h3>A type indexed by a term</h3>
		<p>The fourth box. A <i>value</i> appears in a type.</p>
		<CodeSnippet lines="true" code={h} key="Type on Term" />
		<SlideNotes {...note("A type indexed by a term")} />
	</Section>

	<Section>
		<h3>Almost everyone has a little of it</h3>
		<CodeCompare columns={cmp.typeOnTerm} focus="Lean" />
		<p class="fragment">
			The others admit integers, or literals, or tuple lengths. Lean admits any term of any type.
		</p>
		<SlideNotes {...note("Almost everyone has a little of it")} />
	</Section>

	<Section>
		<h3>Why the fourth box is different</h3>
		<ul>
			<li>The first three keep types and values in separate worlds</li>
			<li>The fourth lets a type say something about a specific value</li>
			<li>
				Which is what a <i>proposition</i> is: <code>3 = 3</code> is a type that mentions terms
			</li>
		</ul>
		<p class="fragment">
			So proving and typing stop being different activities. That is the whole of section five, in
			one box of a table.
		</p>
		<SlideNotes {...note("Why the fourth box is different")} />
	</Section>

	<Section>
		<h3>This has a name</h3>
		<p>
			The three ways of adding dependency to plain functions are the axes of Barendregt's
			<b>lambda cube</b>. Take all three and you have the calculus of constructions, which is what
			sits underneath Lean.
		</p>
		<Note category="math">
			Terms on types is System F. Types on types adds type operators. Types on terms is the
			dependent step, and it is the one that buys you proofs.
		</Note>
		<SlideNotes {...note("This has a name")} />
	</Section>

	<Section>
		<h3>What is type safety?</h3>
		<p class="big">Well-typed programs do not go wrong.</p>
		<p>
			"Go wrong" means a specific list of bad states. It does not mean <i>bugs</i>, and it does
			not mean <i>your</i> definition of wrong.
		</p>
		<SlideNotes {...note('What is type safety?')} />
	</Section>

	<Section>
		<h3>Stated properly</h3>
		<ul>
			<li>
				<b>Progress</b>: a well-typed term is either a value, or it can take another step
			</li>
			<li>
				<b>Preservation</b>: if a well-typed term steps, the result is well typed too
			</li>
		</ul>
		<p class="fragment">
			Together: a well-typed program never gets stuck. C++ has neither. TypeScript deliberately
			gives up both.
		</p>
		<SlideNotes {...note('Stated properly')} />
	</Section>

	<Section>
		<h3>What is type inference?</h3>
		<p>Reconstructing the types you did not write.</p>
		<Code>{`def double n := 2 * n     -- Lean works out Nat → Nat`}</Code>
	</Section>

	<Section>
		<h3>Inference has a ceiling</h3>
		<p>
			The more expressive the type system, the less can be inferred. Full inference for dependent
			types is undecidable, so Lean infers a great deal and asks for the rest.
		</p>
		<Note category="program">
			This is the honest trade: annotations at the boundaries, inference inside. Which is roughly
			where you want them anyway, since a signature is documentation.
		</Note>
	</Section>

	<Section>
		<h3>What are type universes?</h3>
		<p>
			If types are terms, they need types. <code>Nat : Type</code>. So what is
			<code>Type</code>?
		</p>
		<CodeSnippet code={h} key="Type Universes" />
	</Section>

	<Section>
		<h3>Why not just Type : Type?</h3>
		<p>
			Because it is inconsistent. With <code>Type : Type</code> you can encode a Russell-style
			paradox and derive <code>False</code>, and from <code>False</code> everything follows.
		</p>
		<Note category="math">
			Girard's paradox. A single convenient-looking rule, and your proof assistant proves 0 = 1.
		</Note>
		<SlideNotes {...note('Why not just Type : Type?')} />
	</Section>

	<Section>
		<h3>So the levels go up forever</h3>
		<p>
			<code>Type 0 : Type 1 : Type 2 : ⋯</code>, and definitions can be polymorphic in the level so
			you rarely write one by hand.
		</p>
	</Section>

	<Section>
		<h3>Why should anyone care?</h3>
		<ul>
			<li>Because obligations you do not track are obligations you discover in production</li>
			<li>Because "shouldn't happen" is not a plan</li>
			<li>Because the alternative to a checked specification is an unchecked one</li>
		</ul>
	</Section>

	<Section>
		<h3>Is functional programming worth it in 2026?</h3>
		<p>You are already using it, whether or not you call it that:</p>
		<ul>
			<li><code>map</code>, <code>filter</code> and <code>reduce</code>, everywhere</li>
			<li>Immutability by default: React, Redux, value types</li>
			<li>Sum types and pattern matching: Rust, Swift, Kotlin, TypeScript, Java 21</li>
			<li><code>Option</code>/<code>Result</code> instead of null and exceptions</li>
		</ul>
		<p class="fragment">The question is not whether. It is how far.</p>
		<SlideNotes {...note('Is functional programming worth it in 2026?')} />
	</Section>

	<Section>
		<h3>Can I stick with what I know?</h3>
		<p>
			Yes. But every idea in this lecture is available in the language you already use, and knowing
			where they come from is what lets you apply them deliberately rather than by fashion.
		</p>
	</Section>
</section>

<!-- ═══════════════ 7. Paradigms and state ═══════════════ -->
<section>
	<Section>
		<h2>Paradigms and state</h2>
		<SlideNotes {...note('Paradigms and state')} />
	</Section>

	<Section>
		<h3>Most paradigms are takes on state</h3>
		<p>
			Those ideas arrived with a paradigm, and paradigms are easier to compare once you notice they
			are answering one question: where does state live?
		</p>
		<ul>
			<li><b>Imperative</b>: state is external to the code, flowing through mutable memory</li>
			<li><b>Object oriented</b>: state is part of the code, owned by objects that interact</li>
			<li><b>Functional</b>: state does not exist, and values flow through composition</li>
		</ul>
	</Section>

	<Section>
		<h3>The same sum, three ways</h3>
		<CodeCompare columns={cmp.paradigmState} focus="Functional" />
	</Section>

	<Section>
		<h3>Imperative and functional, compared</h3>
		<table class="compare-table">
			<thead>
				<tr><th>Imperative</th><th>Functional</th></tr>
			</thead>
			<tbody>
				<tr><td>Emphasises <i>how</i> to solve</td><td>Emphasises <i>what</i> to solve</td></tr>
				<tr>
					<td>State and mutation: a variable can change after you set it</td>
					<td>Immutability: once assigned, never changed</td>
				</tr>
				<tr>
					<td>Procedural: follow a sequence of steps</td>
					<td>Declarative: define and declare what things are</td>
				</tr>
				<tr>
					<td>Control flow: loops, conditionals, breaks</td>
					<td>First-class functions: passed, returned, stored</td>
				</tr>
				<tr><td>C, Fortran, Go</td><td>Haskell, OCaml, Lean, Elm</td></tr>
			</tbody>
		</table>
	</Section>

	<Section>
		<h3>Where does OOP sit?</h3>
		<table class="compare-table">
			<thead>
				<tr><th></th><th>Encapsulation</th><th>Dispatch</th><th>Reuse</th></tr>
			</thead>
			<tbody>
				<tr><td>Imperative</td><td>Modules</td><td>Function calls</td><td>Procedures</td></tr>
				<tr><td>Object oriented</td><td>Objects own state</td><td>Virtual methods</td><td>Inheritance</td></tr>
				<tr><td>Functional</td><td>Closures, modules</td><td>Pattern matching, classes</td><td>Composition</td></tr>
			</tbody>
		</table>
	</Section>

	<Section>
		<h3>Why is mutability so popular?</h3>
		<p>Because it is fast, and because the machine is mutable.</p>
		<p class="fragment">
			Copying a large array to change one element is absurd. The functional answer has to be better
			than "don't do that".
		</p>
		<SlideNotes {...note('Why is mutability so popular?')} />
	</Section>

	<Section>
		<h3>Functional, but in-place</h3>
		<Citation
			field="Implementation"
			title="Counting Immutable Beans: Reference Counting Optimized for Purely Functional Programming"
			authors="Sebastian Ullrich, Leonardo de Moura"
			venue="IFL 2019 / CADE 2021"
			quote="When a value's reference count is one, updating it in place is unobservable."
			href="https://arxiv.org/abs/1908.05647"
		/>
	</Section>

	<Section>
		<h3>How Lean gets both</h3>
		<p>
			You write a pure update. At runtime, if nobody else holds a reference, Lean mutates the
			original, and that is unobservable precisely <i>because</i> the language is pure.
		</p>
		<Note category="kernel">
			Purity is not the tax you pay for reasoning. Here it is the property that makes the
			optimisation legal.
		</Note>
		<SlideNotes {...note('How Lean gets both')} />
	</Section>

	<Section>
		<h3>Loops versus recursion</h3>
		<p>
			A loop is a recursion whose state you carry by hand. Lean gives you both, and turns tail
			recursion into a loop.
		</p>
		<CodeSnippet code={h} key="Tail Recursion" />
	</Section>
</section>

<!-- ═══════════════ 8. Errors, and a vision ═══════════════ -->
<section>
	<Section><h2>Errors, and a vision</h2></Section>

	<Section>
		<h3>Three kinds of error</h3>
		<table class="compare-table">
			<thead>
				<tr><th>Category</th><th>Example</th><th>How you find it</th></tr>
			</thead>
			<tbody>
				<tr>
					<td>Syntax</td>
					<td>Not closing a parenthesis</td>
					<td>Editor</td>
				</tr>
				<tr>
					<td>Runtime</td>
					<td>Indexing past the end of a list</td>
					<td>Run it, and read the error</td>
				</tr>
				<tr>
					<td>Logic</td>
					<td>A missing minus sign; transposed tensor indices</td>
					<td>Human inspection; tests; noticing something is off</td>
				</tr>
			</tbody>
		</table>
		<SlideNotes {...note('Three kinds of error')} />
	</Section>

	<Section>
		<h3>The same table, in Lean</h3>
		<table class="compare-table">
			<thead>
				<tr><th>Category</th><th>Example</th><th>How you find it</th><th>In Lean</th></tr>
			</thead>
			<tbody>
				<tr><td>Syntax</td><td>Unclosed parenthesis</td><td>Editor</td><td class="win">Editor</td></tr>
				<tr>
					<td>Runtime</td>
					<td>Index past the end</td>
					<td>Run it</td>
					<td class="win">Editor</td>
				</tr>
				<tr>
					<td>Logic</td>
					<td>Missing minus sign</td>
					<td>Inspection, tests, luck</td>
					<td class="win">Editor</td>
				</tr>
			</tbody>
		</table>
		<p class="fragment">
			The third row is the claim worth arguing about, and it only holds for what you actually
			specified.
		</p>
		<SlideNotes {...note('The same table, in Lean')} />
	</Section>

	<Section>
		<h3>How we work now</h3>
		<Diagram source={testing} height="320px" />
		<p>Tests sample the input space. Passing means "no counterexample found yet".</p>
	</Section>

	<Section>
		<h3>What we could do instead</h3>
		<Diagram source={proving} height="320px" />
		<p>A proof quantifies over the whole input space at once.</p>
	</Section>

	<Section>
		<h3>The honest caveat</h3>
		<p>
			Proving gives you code that matches its specification. If the specification is wrong, you have
			a beautifully verified wrong program.
		</p>
		<Note category="math">
			Which is still progress: the error moves somewhere small, explicit, and reviewable.
		</Note>
		<SlideNotes {...note('The honest caveat')} />
	</Section>
</section>

<!-- ═══════════════ 9. Syntax and semantics ═══════════════ -->
<section>
	<Section>
		<h2>Syntax and semantics</h2>
		<SlideNotes {...note('Syntax and semantics')} />
	</Section>

	<Section animate>
		<h3>Start with symbols</h3>
		<Diagram id="layers" source={layers1} height="380px" />
		<p>Syntax picks the well-formed strings out of all possible ones.</p>
	</Section>

	<Section animate>
		<h3>Give them meaning</h3>
		<Diagram id="layers" source={layers2} height="380px" />
		<p>A symbolic model interprets valid statements as being <i>about</i> something.</p>
	</Section>

	<Section animate>
		<h3>Some models compute</h3>
		<Diagram id="layers" source={layers3} height="400px" />
	</Section>

	<Section animate>
		<h3>Which become code</h3>
		<Diagram id="layers" source={layers4} height="440px" />
	</Section>

	<Section animate>
		<h3>And meet reality</h3>
		<Diagram id="layers" source={layers5} height="470px" />
		<p class="fragment">
			Two paths reach reality. Only one of them went through code.
		</p>
		<SlideNotes {...note('And meet reality')} />
	</Section>

	<Section>
		<h3>Definitions</h3>
		<p>A definition names a term. Functions, propositions and modules are all the same mechanism.</p>
		<CodeSnippet lines="true" code={h} key="Definitions" />
	</Section>

	<Section>
		<h3>Terms and types</h3>
		<CodeSnippet lines="true" code={h} key="Terms and Types" />
		<p>Types are terms, so they have types of their own.</p>
	</Section>

	<Section>
		<h3>Propositions are types</h3>
		<CodeSnippet lines="true" code={h} key="Prop" />
		<Note category="math">
			<code>Prop</code> is where equations, formulas and theorems live. A proof is a term, and
			<code>rfl</code> is an ordinary function.
		</Note>
	</Section>

	<Section>
		<h3>Function types</h3>
		<CodeSnippet lines="true" code={h} key="Function Types" />
		<p>
			The type gives the domain and the codomain. It does not give the <i>image</i>. That is a
			theorem rather than a signature.
		</p>
	</Section>

	<Section>
		<h3>Universes, concretely</h3>
		<CodeSnippet lines="true" code={h} key="Type Universes" />
	</Section>

	<Section>
		<h3>Three kinds of definition</h3>
		<CodeSnippet lines="true" code={h} key="def, partial def, noncomputable def" />
		<SlideNotes {...note('Three kinds of definition')} />
	</Section>

	<Section>
		<h3>What each one costs</h3>
		<table class="compare-table">
			<thead>
				<tr><th></th><th>Terminates</th><th>Runs</th><th>Reason about it</th></tr>
			</thead>
			<tbody>
				<tr><td><code>def</code></td><td class="win">Proved</td><td class="win">Yes</td><td class="win">Yes</td></tr>
				<tr><td><code>partial def</code></td><td>Not proved</td><td class="win">Yes</td><td>Opaque</td></tr>
				<tr><td><code>noncomputable def</code></td><td class="win">n/a</td><td>No</td><td class="win">Yes</td></tr>
			</tbody>
		</table>
	</Section>
</section>

<!-- ═══════════════ 10. Lean in practice ═══════════════ -->
<section>
	<Section>
		<h2>Lean in practice</h2>
		<SlideNotes {...note('Lean in practice')} />
	</Section>

	<Section>
		<h3>Structures: the "and" type</h3>
		<CodeSnippet lines="true" code={h} key="Structure" />
	</Section>

	<Section>
		<h3>Updating a structure</h3>
		<CodeSnippet code={h} key="Structure Update" />
		<Note category="program">
			This builds a new point. Thanks to reference counting, it may well reuse the old one's memory.
		</Note>
	</Section>

	<Section>
		<h3>Enums: the "or" type</h3>
		<CodeSnippet lines="true" code={h} key="Enum" />
		<p>Remove a case from the match and it stops compiling. That is the whole feature.</p>
		<SlideNotes {...note('Enums: the "or" type')} />
	</Section>

	<Section>
		<h3>The user contact example, for real</h3>
		<CodeSnippet lines="true" code={h} key="UserContact" />
	</Section>

	<Section>
		<h3>Adding the system case</h3>
		<CodeSnippet lines="true" code={h} key="UserContact with System" />
	</Section>

	<Section>
		<h3>Recursive inductives</h3>
		<CodeSnippet lines="true" code={h} key="Recursive Inductive" />
		<p>A linked list is not a builtin. It is two constructors.</p>
	</Section>

	<Section>
		<h3>NonEmptyList, for real</h3>
		<CodeSnippet code={h} key="NonEmptyList" />
	</Section>

	<Section>
		<h3>Option</h3>
		<CodeSnippet lines="true" code={h} key="Option" />
	</Section>

	<Section>
		<h3>Sum and product</h3>
		<CodeSnippet lines="true" code={h} key="Sum and Product" />
		<p>
			<code>α × β</code> is "and". <code>α ⊕ β</code> is "or". Every structure and every inductive is
			built from these two.
		</p>
	</Section>

	<Section>
		<h3>Polymorphism</h3>
		<CodeSnippet lines="true" code={h} key="Polymorphism" />
		<Note category="math">
			Knowing nothing about <code>α</code>, <code>swap</code> can only move values around. The type
			nearly writes the function.
		</Note>
		<SlideNotes {...note('Polymorphism')} />
	</Section>

	<Section>
		<h3>Writing functions</h3>
		<CodeSnippet lines="true" code={h} key="Functions" />
	</Section>

	<Section>
		<h3>let rec</h3>
		<CodeSnippet code={h} key="let rec" />
	</Section>

	<Section>
		<h3>Recursion instead of loops</h3>
		<CodeSnippet code={h} key="Structural Recursion" />
		<p>Accepted because the argument shrinks on every call.</p>
	</Section>

	<Section>
		<h3>When termination is not obvious</h3>
		<CodeSnippet code={h} key="Termination Fails" />
		<p>
			Lean will not take your word for it. Either prove it, or say <code>partial</code> and accept
			that the logic cannot see inside.
		</p>
	</Section>

	<Section>
		<h3>Lists</h3>
		<CodeSnippet lines="true" code={coll} key="List Basics" />
	</Section>

	<Section>
		<h3>List operations</h3>
		<CodeSnippet lines="true" code={coll} key="List Operations" />
	</Section>

	<Section>
		<h3>A list is an inductive type</h3>
		<CodeSnippet code={coll} key="List is Inductive" />
	</Section>

	<Section>
		<h3>Arrays</h3>
		<CodeSnippet lines="true" code={coll} key="Array Basics" />
		<p>
			<code>a[i]!</code> panics, <code>a[i]?</code> returns an <code>Option</code>. Two different
			obligations, two different types.
		</p>
		<SlideNotes {...note('Arrays')} />
	</Section>

	<Section>
		<h3>Or prove the index is fine</h3>
		<CodeSnippet code={coll} key="Array Index Is Checked" />
		<Note category="kernel">
			No bounds check at runtime and no failure case, because the proof was supplied at compile
			time.
		</Note>
		<SlideNotes {...note('Or prove the index is fine')} />
	</Section>

	<Section>
		<h3>Vectors carry their length</h3>
		<CodeSnippet lines="true" code={coll} key="Vector" />
	</Section>

	<Section>
		<h3>Strings</h3>
		<CodeSnippet lines="true" code={coll} key="String Basics" />
	</Section>

	<Section>
		<h3>Interpolation</h3>
		<CodeSnippet code={coll} key="String Interpolation" />
	</Section>

	<Section>
		<h3>A string is not a list of characters</h3>
		<CodeSnippet code={coll} key="String Is Not A List" />
	</Section>

	<Section>
		<h3>The kitchen and the dining room</h3>
		<Diagram source={kitchen} height="320px" />
		<p>
			The kitchen is pure and verified. The dining room is the real world. <code>IO</code> is the
			waiter, the only thing allowed to cross.
		</p>
		<SlideNotes {...note('The kitchen and the dining room')} />
	</Section>

	<Section>
		<h3>The kitchen</h3>
		<CodeSnippet code={io} key="Pure Kitchen" />
		<p>No <code>IO</code> in the type, so it cannot print, read a file, or fail.</p>
	</Section>

	<Section>
		<h3>The waiter</h3>
		<CodeSnippet code={io} key="Hello IO" />
		<p>
			<code>IO Unit</code> is a <i>description</i> of an action, and a value like any other.
		</p>
	</Section>

	<Section>
		<h3>do notation</h3>
		<CodeSnippet lines="true" code={io} key="do Notation" />
	</Section>

	<Section>
		<h3>Naming what an action returned</h3>
		<CodeSnippet lines="true" code={io} key="Binding a Result" />
	</Section>

	<Section>
		<h3>Imperative style, purely</h3>
		<CodeSnippet lines="true" code={io} key="Mutable Locals" />
		<Note category="program">
			<code>let mut</code> and <code>for</code> inside <code>do</code>. It reads like Python and
			elaborates into ordinary function calls.
		</Note>
		<SlideNotes {...note('Imperative style, purely')} />
	</Section>

	<Section>
		<h3>Crossing the boundary</h3>
		<CodeSnippet code={io} key="Crossing the Boundary" />
		<p>
			One direction only: the waiter may call the kitchen. The kitchen cannot call the waiter, and
			its type proves it.
		</p>
	</Section>

	<Section>
		<h3>Failure is in the type too</h3>
		<CodeSnippet lines="true" code={io} key="IO Can Fail" />
	</Section>

	<Section>
		<h3>main</h3>
		<CodeSnippet code={io} key="main" />
		<Code category="terminal" language="sh">$ lean --run io.lean</Code>
	</Section>

	<Section>
		<h3>Putting it together: a CSV parser</h3>
		<p>Everything so far, in one small program.</p>
		<ul>
			<li>The cases live in the type</li>
			<li>The parser is total, with no <code>partial</code> and no panic</li>
			<li>Failure is a returned value</li>
		</ul>
		<SlideNotes {...note('Putting it together: a CSV parser')} />
	</Section>

	<Section>
		<h3>The state of the parse</h3>
		<CodeSnippet lines="true" code={csv} key="Parser State" />
	</Section>

	<Section>
		<h3>Ending a field, ending a row</h3>
		<CodeSnippet code={csv} key="Field and Row Ends" />
	</Section>

	<Section>
		<h3>Outside quotes</h3>
		<CodeSnippet lines="true" code={csv} key="Outside Quotes" />
	</Section>

	<Section>
		<h3>Three situations</h3>
		<CodeSnippet lines="true" code={csv} key="The Step Function" />
		<p>
			Pending quote, inside quotes, or outside. The structure of the function is the structure of
			the problem.
		</p>
		<SlideNotes {...note('Three situations')} />
	</Section>

	<Section>
		<h3>The parser, and why it is total</h3>
		<CodeSnippet lines="true" code={csv} key="Parse" />
		<Note category="kernel">
			Recursion on the list of characters shrinks every call, so Lean accepts it with no
			<code>partial</code> and no termination proof from us.
		</Note>
		<SlideNotes {...note('The parser, and why it is total')} />
	</Section>

	<Section>
		<h3>It handles the awkward cases</h3>
		<CodeSnippet code={csv} key="Parse Example" />
	</Section>

	<Section>
		<h3>From strings to a type worth having</h3>
		<CodeSnippet code={csv} key="Reading" />
	</Section>

	<Section>
		<h3>Decoding a row</h3>
		<CodeSnippet lines="true" code={csv} key="Row To Reading" />
		<p>Failure is a returned value. Every caller has to deal with it.</p>
	</Section>

	<Section>
		<h3>Loading the file</h3>
		<CodeSnippet code={csv} key="Load" />
	</Section>

	<Section>
		<h3>Some data, including bad rows</h3>
		<CodeSnippet lines="true" code={csv} key="Sample Data" />
	</Section>

	<Section>
		<h3>And running it</h3>
		<CodeSnippet lines="true" code={csv} key="main" />
	</Section>

	<Section>
		<h3>The output</h3>
		<Code category="message">{`ok    Kirkwall at 7°C (verified: true)
ok    Stanley, Falklands at 9°C (verified: true)
ok    Vostok at -89°C (verified: false)
error temperature is not a number: not-a-number
error expected 3 fields, got 2

3 of 5 rows decoded`}</Code>
	</Section>

	<Section>
		<h3>What the types did for us</h3>
		<ul>
			<li>Three parser situations, enumerated rather than remembered</li>
			<li>Termination, proved rather than assumed</li>
			<li>Bad rows, returned rather than thrown</li>
			<li>Two rows failed, and the program still finished</li>
		</ul>
		<SlideNotes {...note('What the types did for us')} />
	</Section>

	<Section>
		<h3>Where we started</h3>
		<p class="big">A type system keeps track of the cases you have to handle.</p>
		<p>Everything else in this lecture is that idea, applied harder.</p>
		<SlideNotes {...note('Where we started')} />
	</Section>

	<Section>
		<h3>The handouts</h3>
		<ul class="files">
			<li><a href="{base}/handout/introduction/handout.lean">handout.lean</a>: types, structures, inductives, functions</li>
			<li><a href="{base}/handout/introduction/collections.lean">collections.lean</a>: lists, arrays, vectors, strings</li>
			<li><a href="{base}/handout/introduction/io.lean">io.lean</a>: <code>do</code>, <code>IO</code> and <code>main</code></li>
			<li><a href="{base}/handout/introduction/csv.lean">csv.lean</a>: the parser, runnable</li>
		</ul>
		<Code category="terminal" language="sh">$ lean --run csv.lean</Code>
	</Section>
</section>

<style>
	.big {
		font-size: 1.15em;
		line-height: 1.35;
	}
	.two-up {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 1.2em;
		text-align: left;
	}
	.two-up h4 {
		margin: 0 0 0.3em;
		color: var(--ctp-lavender);
		font-size: 0.7em;
	}
	.two-up p {
		font-size: 0.62em;
	}
	.compare-table {
		font-size: 0.5em;
	}
	/* The 2x2 of what can be indexed by what. */
	.quadrants {
		width: auto;
		margin: 0.6em auto;
		font-size: 0.55em;
	}
	.quadrants th {
		color: var(--ctp-lavender);
		font-weight: normal;
	}
	.quadrants td {
		padding: 0.4em 1.1em;
		text-align: center;
	}
	.quadrants :global(td.win) {
		color: var(--ctp-green);
	}
	.compare-table :global(td.win) {
		color: var(--ctp-green);
	}
	.files {
		font-size: 0.62em;
	}
</style>
