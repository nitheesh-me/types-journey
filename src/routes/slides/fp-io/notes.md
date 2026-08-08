--- note IO
`IO` is not a special compiler feature — it is the state monad from last
lecture with the state being "the world". Everything you already know about
`bind` and `do` applies unchanged.
--- presenter
Open by saying this lecture adds no new theory, only a particular monad and the
runtime around it.

--- note Standard Output
`#eval` will run an `IO` action, which is why you can try these without
building an executable. In a real program `main` is the action the runtime
executes.
--- presenter
Point out that `#eval` running IO is a convenience of the editor, not something
that happens at proof time.

--- note The Definition of IO
`IO` is `EIO IO.Error`, which is `EStateM` over `IO.RealWorld`. Reading that
chain out loud is the fastest way to see there is no magic.
--- presenter
Unfold it one layer at a time on the slide. The reveal is that it bottoms out
in something ordinary.

--- note EStateM
A state monad that can also fail: every step either returns a value and a new
state, or an error and a state. That covers both problems from lecture 04 at
once.
--- presenter
Note the state comes back on the error branch too — that is deliberate and
matters for `finally`.

--- note The World
`IO.RealWorld` is an opaque placeholder. Nothing ever inspects it; it exists so
the type system can order effects, because each action consumes the world it
was handed.
--- presenter
The philosophical aside on the slide is a good ten-second breather. Do not let
it become a five-minute one.

--- note Exception Handling
Exceptions are values in the error branch of `EStateM`, not a separate control
mechanism. `throw` and `tryCatch` come from `MonadExcept`, so any monad can
have them.
--- presenter
The exercise at the end of this section — whether `Option` can be a
`MonadExcept` — is worth actually asking.

--- note MonadExcept
Two functions: `throw` puts an error into the monad, `tryCatch` runs something
and hands any error to a handler. That is all "exceptions" means here.
--- presenter
Contrast with stack unwinding in C++ or Java. Nothing is unwound; a value is
returned down a different branch.

--- note Panic
`panic` is not an exception — it is for cases you have decided cannot happen.
It works in pure code, which is why it needs the result type to be inhabited:
it has to return *something*.
--- presenter
Say clearly when to use which: `throw` for expected failure, `panic` for
"impossible".

--- note Concurrency and References
Lean's concurrency is tasks plus references, with the same monadic plumbing.
The interesting part is that mutation is explicit — a `Ref` is a value you pass
around, not ambient state.
--- presenter
Flag the race condition demo two slides ahead so people watch for it.

--- note Tasks
`EIO.asTask` starts work; `Task.get` waits for it. Because the result is a
value, "run these concurrently and combine" is ordinary function application.
--- presenter
The output order in the example is not deterministic. If it comes out in a
different order live, that is the lesson, not a bug.

--- note References
`IO.Ref` is a mutable cell. `ST` is another monad, but it lifts into `IO`
automatically, so in practice you use `mkRef`, `get` and `set` inside a normal
`do` block.
--- presenter
Do not go into `ST`'s region parameter. It is a distraction here.

--- note Synchronization
This is a genuine race: both tasks read, then both write, and one update is
lost. The output is 1, 2 or 3 depending on scheduling.
--- presenter
Run it a few times if the environment allows. Seeing it change is worth more
than the explanation.

--- note Mutex
A mutex guards *data*, not code — you cannot reach the value without going
through `atomically`. Rust works the same way, and it rules out the commonest
mistake: forgetting to take the lock.
--- presenter
"The lock owns the data" is the sentence to leave them with.

--- note Cancellation
Cancellation is coöperative: `IO.cancel` sets a flag, and the task keeps
running until it chooses to check `IO.checkCanceled`. A task in a tight loop
that never checks is not cancellable.
--- presenter
Common source of confusion. Say explicitly that cancel does not kill anything.

--- note Channel
A channel decouples producer from consumer. `ch.sync` gives an iterator that
ends when the channel closes, so the consumer's `for` loop terminates on its
own.
--- presenter
Point out `ch.close` — forgetting it is why the consumer hangs.

--- note Interlude: Setting up a Lean Project
Everything so far fits in one file. You need a project once you want
dependencies, several interdependent files, or a library others can import.
--- presenter
Pure logistics section. Tell people they can follow along or just watch.

--- note lake
`lake` is Lean's build tool and comes with the toolchain — there is nothing to
install. `lake new` scaffolds, `lake build` builds, `lake exe` runs.
--- presenter
`lake -h` is the answer to most questions here. Say it once so they stop asking.

--- note Project Logistics
The project is the point of the course: pick something you actually want
formalised. Scope matters more than difficulty — a small thing finished beats a
large thing abandoned.
--- presenter
Push people towards the easy and medium options. Every year someone tries
mathlib and stalls.
