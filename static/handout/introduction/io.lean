/- Introduction: doing things to the outside world.

   The kitchen is pure and verified. The dining room is the messy, unpredictable
   real world. `IO` is the waiter: the only thing allowed to cross between them,
   and the type says so.

   Run with:   lean --run io.lean
-/

/- ────────────────────────────────────────────────────────────
   The kitchen: ordinary total functions
   ──────────────────────────────────────────────────────────── -/

--- snippet Pure Kitchen
-- No IO in the type, so this cannot print, read a file, or fail.
def shout (s : String) : String := s.toUpper ++ "!"

#eval shout "hello"
--- end

/- ────────────────────────────────────────────────────────────
   The waiter: IO
   ──────────────────────────────────────────────────────────── -/

--- snippet Hello IO
-- `IO Unit` is a description of an action that returns nothing useful.
def hello : IO Unit := IO.println "hello, dining room"

#eval hello
--- end

--- snippet do Notation
-- `do` sequences actions. It reads like an imperative program and elaborates
-- into ordinary function calls.
def greet (name : String) : IO Unit := do
  IO.println s!"hello, {name}"
  IO.println "welcome"

#eval greet "POPL/M"
--- end

--- snippet Binding a Result
-- `←` runs an action and names what it returned.
def askAndEcho : IO Unit := do
  let stdin ← IO.getStdin
  IO.println "type something:"
  let line ← stdin.getLine
  IO.println s!"you said: {line.trimAscii.toString}"
--- end

--- snippet Mutable Locals
-- `let mut` and `for` exist inside `do`, and are still pure underneath.
def countUp (n : Nat) : IO Unit := do
  let mut total := 0
  for i in List.range n do
    total := total + i
    IO.println s!"step {i}, total {total}"
  IO.println s!"final {total}"

#eval countUp 4
--- end

--- snippet Crossing the Boundary
-- The kitchen function is used from inside the waiter's action. The reverse
-- is impossible: `shout` cannot call `IO.println`, and its type proves it.
def serve (order : String) : IO Unit := do
  IO.println (shout order)

#eval serve "two coffees"
--- end

/- ────────────────────────────────────────────────────────────
   Failure is in the type too
   ──────────────────────────────────────────────────────────── -/

--- snippet IO Can Fail
def readOrDefault (path : System.FilePath) : IO String := do
  try
    IO.FS.readFile path
  catch _ =>
    return "(no such file)"

#eval readOrDefault "definitely-not-here.txt"
--- end

/- ────────────────────────────────────────────────────────────
   main
   ──────────────────────────────────────────────────────────── -/

--- snippet main
-- `lean --run` looks for `main`. This is the one place the real world gets in.
def main : IO Unit := do
  IO.println "── kitchen ──"
  IO.println (shout "mise en place")
  IO.println "── dining room ──"
  countUp 3
--- end
