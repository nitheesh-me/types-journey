--- note Does software work?
The opening is deliberately a question nobody disagrees with, so that the
disagreement can be located precisely: not *whether* software should work, but
what a type system is supposed to contribute to that.

The section is history, and history is the setup for the argument. The claim is
that a generation formed its opinion of static typing from two languages that
were bad advertisements for it.
--- presenter
Do not rush this. If the room does not accept "static typing had a bad decade",
the renaissance slides land as trivia rather than as a reversal.

--- note C++: types as sizes
The point is not that C++ is bad. It is that in C++ a type mostly answers a
*representation* question, meaning how many bytes arranged how, and representation
questions do not constrain meaning.

`unsigned n = 5; n - 6;` is the compact version: the type is doing arithmetic
you did not ask for, silently.
--- presenter
The wraparound example gets a reaction from anyone who has been bitten. Wait for
it before moving on.

--- note But look what happened to the complexity
This is the honest complaint, and it is worth conceding before making the
counter-argument. Type systems really have grown enormously, and most working
programmers really do treat the checker as an oracle.
--- presenter
Ask for a show of hands: who has said "fighting the type checker" out loud in
the last month? Usually most of the room.

--- note What do we actually need?
The three ingredients are the spine of the whole lecture. Products, sums,
pattern matching, and everything later is these three applied harder.

Worth writing on a board and leaving up.
--- presenter
Say explicitly: "if you remember one slide, this is the one."

--- note What is a type?
Two answers, and the difference between them is the difference between checking
a property and making it unstateable.
--- presenter
Get both answers out before evaluating either. The comparison is the content.

--- note Negative space and positive space
Negative space starts with everything and rules things out, which needs a proof
that the rule holds. Positive space starts with nothing and says what can be
built, which needs no proof, because nothing else exists.
--- presenter
The sculpture analogy is available if the room likes analogies: carving away
versus building up.

--- note Isn't this cheating?
Everyone feels this at first, and it is worth naming rather than talking past.
The answer is that "enforce a property" and "choose a representation in which the
property is automatic" are not different in kind. The second is simply the version
that cannot be got wrong.
--- presenter
If someone pushes back, the honest concession is that not every property admits
this treatment. `TimeRange` two slides later is the case where it takes work.

--- note Decouple representation from interpretation
The central design claim of the section. There is no privileged representation;
you are choosing one, and the choice is where correctness is won.
--- presenter
This is the sentence to repeat verbatim later when the CSV parser's state
structure shows up.

--- note Now add system users
The flag version has two fields and four states, only three of which mean
anything. The case version has four states and four meanings.

The second benefit is the one people underrate: adding a case *breaks* every
match, and that breakage is the compiler handing you a to-do list.
--- presenter
Ask what happens in the flag version when someone constructs
`contact: Some(..), is_system: true`. Nothing happens. That is the problem.

--- note It is not always this easy
The counterexample, deliberately placed. `start <= end` is a relation between two
fields, and no amount of enumeration removes it. You have to change what you
store.
--- presenter
Concede here. A lecture that claims the technique always works is not credible.

--- note What is a type system for?
Four candidate answers, all of which people genuinely hold, then the one this
lecture argues for. Let the candidates stand on their own before knocking them
down; two of them are partly right.
--- presenter
Ask the room for their answer before showing the candidates. Someone always says
"catching bugs", which is a good place to start pulling.

--- note My answer
The thesis. Everything before it was setup and everything after is consequence.
--- presenter
Slow down. Say it, pause, say it again.

--- note Now add one case
This is the moment the thesis becomes concrete: the checker does not merely
reject bad programs, it *enumerates the work*.

The difference between this and grepping is exhaustiveness. Grep finds the places
that match your pattern; the checker finds the places that exist.
--- presenter
"Not a grep, but a list." That is the line.

--- note A second example
Deliberately the case where the weaker type is fine. Not every list needs to be
non-empty, and a lecture that says otherwise teaches cargo cult.
--- presenter
Ask whether `List` is wrong here before revealing that it is not.

--- note Shrink the type instead
Contrast with the previous slide: same data, different question, and now the
weaker type forces a branch you cannot honestly write.
--- presenter
The panic branch is the tell. Any time you write "shouldn't happen", the type is
wider than the truth.

--- note The point
The summary of the section, and the phrase to carry into the rest of the lecture.
Obligations are conserved; you are choosing who discharges them.
--- presenter
If time is short, this slide and "My answer" are the two that must survive.

--- note Type, define, refine
The methodology section. Short, and mostly setting up the jigsaw.
--- presenter
Light relief after the density of section three.

--- note Why the jigsaw works
Worth stressing that this is literal in Lean: `exact?` searches the library for
terms of the right type. The analogy is an implementation.
--- presenter
Demo `exact?` live if the room is technical and the setup is working.

--- note A digression: infrastructure as code
This lands with practitioners more than any other slide in the lecture. Everyone
in the room has been burned by YAML.
--- presenter
Ask who has shipped an outage caused by a YAML type coercion. Hands go up.

--- note Does any of this type check?
Every line is a real footgun. `enabled: yes` parsing as a boolean under YAML 1.1
and a string under 1.2 is the one that surprises people most.
--- presenter
Do not editorialise; the slide is funnier read straight.

--- note Three views of type theory
The scholarly section. Its job is to place the subject rather than teach it, so the
audience should leave knowing which literature to open, not believing they have
read it.
--- presenter
Keep this brisk. Five minutes, not fifteen.

--- note Why that correspondence matters
Propositions-as-types is the hinge between the logic view and the practice of
using Lean. If only one citation slide survives a time cut, keep Wadler and this
one.
--- presenter
"A theorem is a function signature" is the line that makes people sit up.

--- note What is a type?#2
The recap, several sections after the question was first asked. Section two
argued about it; this slide states the answer the lecture settled on, so it can
sit beside the other definitions.
--- presenter
Deliberately short. If it needs more than a sentence here, section two did not
land.

--- note Four kinds of dependency
The taxonomy that organises the rest of the section. One thing can depend on
another in exactly four combinations, and three of them are features the room
already uses without naming them.

Draw the 2x2 on a board if you can. People remember the grid long after they
forget the slide.
--- presenter
Ask which box they think they live in. Most say the first; most are actually
using three of them daily.

--- note A term indexed by a term
The baseline, deliberately boring. It is here so the other three have something
to be measured against.
--- presenter
Ten seconds. Do not linger.

--- note A term indexed by a type
Parametric polymorphism. The type is an argument, and the body does not change
when it changes.
--- presenter
Note that the four columns are the same idea with different syntax. That
sameness is the point.

--- note The same box, filled differently
Ad-hoc polymorphism. Here the type does not parameterise the body, it selects
between bodies that were written separately.

Both belong in the same box because in both the term depends on a type. What
differs is whether there is one body or several.
--- presenter
"Parameterise" versus "select" is the distinction worth saying out loud.

--- note A note on inheritance
Worth being precise. Virtual dispatch does choose a term by a type, so it feels
like it belongs here, but subtyping is its own axis and not one of the cube's
three. Say so rather than smoothing it over.
--- presenter
If someone objects that inheritance is not in the cube, agree with them. They
are right, and the slide says so.

--- note A type indexed by a type
Type constructors. `List` is a function from types to types, and that is not a
metaphor: it has an arrow in its type.
--- presenter
Show `#check List` and let the arrow do the work.

--- note A type indexed by a term
The fourth box, and the one the whole lecture has been walking towards. A value
appears in a type.
--- presenter
Pause here. This is the slide where dependent types stop being a rumour.

--- note Almost everyone has a little of it
The honest comparison. Rust has const generics over integers, C++ has non-type
template parameters, TypeScript has literal types and tuple lengths. All three
are the fourth box, restricted.

Lean's version is unrestricted: any term, of any type, with the whole language
available inside the type.
--- presenter
This lands better as "you already have a keyhole view of this" than as "your
language cannot do it".

--- note Why the fourth box is different
The payoff. Once a type can mention a term, a proposition is just a type, and
proving is just typing.
--- presenter
Connect it forward to the propositions-as-types slide if you have already shown
it, or backward if you have not.

--- note This has a name
Barendregt's lambda cube, named at the end rather than the beginning so the
audience meets the idea before the jargon.
--- presenter
Do not draw the cube. The 2x2 already did the work; the cube adds a dimension
and subtracts clarity.

--- note What is type safety?
"Well-typed programs do not go wrong" is Milner's phrase and is widely
misremembered as a much stronger claim. Be precise: "go wrong" is a specific
list of states, not a synonym for "have bugs".
--- presenter
Someone will say "but I have shipped bugs in a typed language". Agree
immediately, because that is the point of the caveat.

--- note Stated properly
Progress and preservation, in one line each. This is the whole of type safety,
and it is worth showing that it fits on a slide.
--- presenter
Note that TypeScript gives up both deliberately, and was right to.

--- note Why not just Type : Type?
Girard's paradox. The short version: one convenient-looking rule, and the system
proves `False`, and from `False` everything follows.
--- presenter
Do not attempt to present the paradox. Name it, say what it costs, move on.

--- note Is functional programming worth it in 2026?
The answer is that the audience already adopted most of it without noticing. The
list is deliberately mainstream, with nothing exotic on it.
--- presenter
Read the list slowly and watch for recognition. Java 21 having pattern matching
usually gets a reaction.

--- note Paradigms and state
The framing that makes the three paradigms comparable rather than tribal: each is
a position on where state lives.
--- presenter
Resist paradigm war. The framing is descriptive.

--- note Why is mutability so popular?
The concession that has to be made honestly, because it is correct. Copying an
array to change one element is absurd, and "just don't" is not an answer.
--- presenter
Set this up as a genuine problem for the functional position. The next slide is
better if the audience believes the objection.

--- note How Lean gets both
The resolution, and the nicest result in the section: purity is not the price
paid for reasoning, it is the property that makes the in-place update legal.
--- presenter
"Unobservable precisely because the language is pure." Land that sentence.

--- note Three kinds of error
Standard taxonomy, deliberately unremarkable, so the next slide has something to
subvert.
--- presenter
Ask which row costs the most. It is always the third.

--- note The same table, in Lean
The claim of the whole course, compressed to one column. Be careful to attach the
caveat: it holds for what you actually specified, and not one inch further.
--- presenter
Do not oversell. The fragment with the caveat matters more than the table.

--- note The honest caveat
Specification error is real, and pretending otherwise loses the sceptics in the
room. The defence is that the error moves somewhere small and reviewable.
--- presenter
"A beautifully verified wrong program" is the phrase people remember.

--- note Syntax and semantics
The diagram is built up over five slides using auto-animate, so each layer lands
on its own. Do not skip ahead, because the incremental reveal is the explanation.
--- presenter
Narrate the arrows, not the boxes.

--- note And meet reality
The payoff: two paths reach reality, and only one went through code. Scientific
software sits on the path that has both a symbolic model and an implementation,
and the gap between them is where the bugs live.
--- presenter
Point at both arrows into Reality. The question "do these agree?" is the whole
field.

--- note Three kinds of definition
`def` is proved terminating and runs. `partial` runs but the logic cannot see
inside. `noncomputable` can be reasoned about but not executed.
--- presenter
The table on the next slide is the summary; this slide is the code.

--- note Lean in practice
From here it is concrete. Everyone should have the handouts open.
--- presenter
Give the room thirty seconds to open `handout.lean` before starting.

--- note Enums: the "or" type
Back to the first section's third ingredient, now in Lean. Deleting a case from
the match is the demo worth doing live.
--- presenter
Actually delete a case in the editor and let them watch the error appear.

--- note Polymorphism
Parametricity, without the word: knowing nothing about the type, there is almost
nothing the function can do. The type nearly writes the implementation.
--- presenter
Ask how many functions have type `α × β → β × α`. Essentially one.

--- note Arrays
Two indexing operators, two obligations, two types. `!` panics and `?` returns an
`Option`. The choice is which failure mode you want, made explicit.
--- presenter
This is section three's argument, in the standard library.

--- note Or prove the index is fine
The dependent-types payoff in miniature: supply a proof at compile time and there
is no runtime check and no failure case at all.
--- presenter
Worth pausing on. Most audiences have never seen an index that cannot be out of
range.

--- note The kitchen and the dining room
The analogy for IO. The kitchen is pure and verified, the dining room is the
unpredictable real world, and `IO` is the waiter, the only thing allowed to
cross, and the type says which side you are on.
--- presenter
Push the analogy: the kitchen cannot walk into the dining room, and its type is
what stops it.

--- note Imperative style, purely
The slide that surprises people who expect functional programming to forbid
loops. `let mut` and `for` exist, read like Python, and elaborate into ordinary
function calls.
--- presenter
Show the desugaring if anyone doubts it.

--- note Putting it together: a CSV parser
The capstone. Everything the lecture argued for, in a program small enough to
read on a slide.
--- presenter
Say up front what to watch for: no `partial`, no panic, failures returned.

--- note Three situations
The structure of the function is the structure of the problem: pending quote,
inside quotes, or outside. That is the lecture's thesis in a fifteen-line function.
--- presenter
Trace the input `"he said ""hi"""` by hand through the three branches.

--- note The parser, and why it is total
Structural recursion on the character list. No `partial`, no termination proof
written by us, and no possibility of a hang.
--- presenter
Contrast with the same parser in any language where a `while` loop could fail to
advance.

--- note What the types did for us
The summary. Four claims, each traceable to a slide earlier in the lecture.
--- presenter
Walk back through them and name where each came from.

--- note Where we started
Close on the thesis. If they remember one sentence from ninety minutes, this is
the one.
--- presenter
Then stop. Do not add a further summary.
