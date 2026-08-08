--- note Should you learn Lean 4?
This deck exists because the series otherwise starts by assuming the answer. The
reader is an experienced engineer who has not decided, and who has probably never
been taught what a type system is doing.

It is a decision tree, not a lecture. Nobody is expected to see all of it.
--- presenter
If you are presenting rather than handing this over, ask the room the questions
out loud and take the branch the majority wants. That is what it is built for.

--- note How to read this
Two keys, one meaning each. Worth demonstrating rather than describing: press
Down, then Right, and let them watch it move.
--- presenter
Do this live. Ten seconds of demonstration beats the diagram.

--- note Have you ever shipped a bug a computer could have caught?
The opening question is deliberately one that everybody answers yes to, and that
stings slightly. It buys attention for the taxonomy that follows.
--- presenter
Let the silence sit. Somebody usually volunteers a story, and that is better than
anything on the slide.

--- note Four nets
The four tools as filters with different mesh. The point is not that types are
best; it is that each tool misses a describable category, and one of those gaps
is unusually large.
--- presenter
Walk left to right along the arrows.

--- note The interesting gap
The load-bearing claim of the section: tests are bounded by imagination and a
type checker is not.
--- presenter
This is the sentence to repeat if the section gets cut for time.

--- note Being honest about it
Placed deliberately at the end of the first branch. A deck that opens by
overclaiming loses this audience permanently.
--- presenter
Concede it cheerfully. Credibility here pays for everything later.

--- note Does your code carry comments like "must not be empty"?
Everybody's code does. The question is chosen because the answer is
unambiguously yes and requires no vocabulary to understand.
--- presenter
Ask for examples from their own codebase. You will get several.

--- note What the right one changed
The pivot of the whole deck. It did not add a check; it removed the possibility.
Make sure that distinction lands before moving on.
--- presenter
"It did not add a check. It changed what could be built." Say it twice.

--- note Now the names
Vocabulary arrives only here, after two slides of the thing itself. That ordering
is the deck's main rule and this slide is where it is most visible.
--- presenter
Point out that they already understood it before it had a name. That is
reassuring for exactly the audience this deck is for.

--- note When it does not work
The honest limit. Some invariants relate two fields and cannot be enumerated
away.
--- presenter
If someone raises it before this slide, congratulate them and skip ahead.

--- note When a thing can be one of several, does your language make you handle all of them?
Most readers do not know whether their language does this, which makes the
comparison genuinely informative rather than a lecture.
--- presenter
Ask which column they are in before revealing it.

--- note Two of those shipped a bug
The Go and Python versions compile, run, and return the wrong answer quietly.
Quiet wrongness is the worst failure mode and worth naming as such.
--- presenter
Ask what the Go version returns. The answer, an empty string, is the lesson.

--- note Now the names#2
The second time vocabulary arrives after the fact, and the terms here are the
ones that matter most in practice: a case, and exhaustive pattern matching.
--- presenter
Point back at the Rust column. They watched the checker do it two slides ago.

--- note Does your language do this?
The most immediately actionable slide in the deck. Someone in the left column can
act on it tomorrow without learning Lean at all, and saying so builds trust.
--- presenter
Do not soften the last line. If they already have this, they may not need us.

--- note Have you ever fought the compiler and thought it was paperwork?
The attitude question. Of all ten branches this is the one that changes how
someone works, whether or not they ever install Lean.
--- presenter
Show of hands. It is always most of the room.

--- note The reframe
The single sentence the deck would keep if it could keep only one.
--- presenter
Pause before and after.

--- note When the complaint is fair
Needed for credibility. Sometimes the checker really is wasting your time, and an
audience of experienced engineers knows it.
--- presenter
Invite examples. Bad error messages get the most agreement.

--- note Is being wrong expensive where you work?
The economic question. It decides how much of this is justified, and the answer
varies enormously between teams.
--- presenter
Nobody needs to answer out loud. Some people's answer is confidential.

--- note People actually do this
Names and projects, so this stops sounding hypothetical. Note that most of the
list uses Coq or Isabelle rather than Lean; that is deliberate honesty about a
field older than this tool.
--- presenter
The fragment about how few verify a whole system is the real point of the slide.

--- note Where the curve bends
Most of the value is in the first two tiers, and most teams never finish the
first. Worth stating plainly to anyone imagining they must go all the way.
--- presenter
This is the slide that makes the idea affordable.

--- note If being wrong is cheap
The permission slip to walk away. Include it; it is why the rest is believable.
--- presenter
Mean it.

--- note Do you write tests, and do you trust them?
Two questions in one, and the second is the interesting half. Almost everybody
trusts their suite less than they admit.
--- presenter
The pause after "and do you trust them" does the work.

--- note What a green test suite means
Restating green as "no counterexample found among the cases we tried" is
uncomfortable and accurate.
--- presenter
Not a criticism of testing. Say so, or you will lose people who are proud of
their suite.

--- note What it does not give you
The specification can be wrong. This caveat appears in every honest talk about
verification and its absence is a warning sign in the ones that omit it.
--- presenter
"A carefully verified wrong program" is the memorable phrasing.

--- note What you keep testing regardless
Proofs shrink a test suite; they do not replace it. Anyone who has been burned by
an over-claiming methodology needs to hear this.
--- presenter
Short. Then move on.

--- note Want to see what it actually looks like?
The branch for people who think in code rather than argument, which in this
audience is most of them.
--- presenter
Some rooms want this first. It is fine to jump here and come back.

--- note Now the name
Second time the deck names something after showing it, and the term is the one
that usually scares people off. By this slide they have already understood three
examples of it.
--- presenter
"You have now seen it, so the term describes something rather than announcing
it." That is the whole pedagogy of the deck.

--- note What just happened
The recap, five bullets, each traceable to a slide they just saw.
--- presenter
Read them slowly. This is the summary people write down.

--- note Worried the maths will be over your head?
The unspoken blocker. Naming it out loud is most of the value of this branch.
--- presenter
Say "nobody says this out loud" and watch the room relax.

--- note The honest answer
Almost none, to start. True, and the sentence that unblocks people.
--- presenter
Full stop after it. Do not qualify immediately; the qualification comes two
slides later where it belongs.

--- note Two different things get called "the maths"
The distinction that resolves most of the anxiety: the maths of the tool versus
the maths you might do with it. Neither is required to begin.
--- presenter
Most engineers only ever need the left column, and only later.

--- note Where it does get hard
The counterweight. Proving real theorems does want maturity, and saying so keeps
the earlier reassurance honest.
--- presenter
Land on the last sentence: you can go a long way without it.

--- note How much time have you got?
The question that decides whether anything actually happens. Everything before it
was persuasion.
--- presenter
Ask them to pick a row before you show the next slides.

--- note A month
The row where the value actually arrives, and the one worth pointing at.
--- presenter
If they only do one row, this is the one.

--- note If you have to convince a team
Organisational advice, which matters more than technical advice for anyone
senior enough to be asked "why".
--- presenter
The first bullet is the one people ignore and then regret.

--- note What to measure
Bugs found in the specification, not lines proved. This is the number that
convinces sceptical colleagues, and it is nearly always surprising.
--- presenter
Ask whether they have ever written their spec down precisely. Usually not.

--- note Still not convinced?
An entire branch arguing the other side. It exists because this audience has
heard overclaiming before and discounts it automatically.
--- presenter
Present it straight. Do not undercut it with a rebuttal at the end.

--- note Your bugs may not be these bugs
The strongest argument against, and it is often correct. Timeouts, capacity and
misunderstood requirements are untouched by any of this.
--- presenter
Agree with anyone who says this describes their last five incidents.

--- note If your types already do the job
Aimed at competent Rust teams, who are the most likely to be told they should
learn Lean and the least likely to need it urgently.
--- presenter
"Worth something, but maybe not this quarter" is the honest position.

--- note What to learn instead
Ending the case-against with real alternatives rather than a redirect back to
Lean. It is the difference between a guide and an advertisement.
--- presenter
Recommend these sincerely. Some of the room should leave and learn TLA+.

--- note If you remember one thing
The same sentence Lecture 01 closes on, so the two decks agree.
--- presenter
Stop here.
