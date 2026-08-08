/- Construction of monads: In a purely functional programming language, function
cannot have side effects. The most common side effect is when a function mutates
the environment (everything outside of the function). In functional terms, we
can formulate this as taking a state argument and returning a state result. -/
abbrev State := Nat
abbrev StateF α := State → (α × State)

/-- The return type of `StateF` is unit. This function does not return anything,
but it increments the state by 1. -/
def increment : StateF Unit := λ state => ((), state + 1)

-- Executing `increment` on an initial state of 2
#eval increment 2

/-- We also want to be able to execute multiple of these functions with side
effects. This is a "sequence" operation, and we do it by feeding the state from
the first function to the second. The apostrophy will be explained later. -/
def seq' { α β } (m : StateF α) (n : StateF β) : StateF β := λ s =>
  -- The output `a` is ignored.
  let (_a, s') := m s
  let (b, s'') := n s'
  (b, s'')

def double : StateF Unit := λ state => ((), state * 2)

-- Increment first, then double
#eval (seq' increment double) 5
-- Double first, then increment
#eval (seq' double increment) 5

-- Therefore, `seq` is not a commutative operation, but it is associative (can
-- you prove it?)

#eval (seq' (seq' increment double) increment) 5
#eval (seq' increment (seq' double increment)) 5

/-- Being able to execute one operation after another is sufficient to model
operations such as printing to the console, but we still cannot model the case
where the result of the first operation gets fed into the second operation. This
is where `bind` comes in. It takes the result of the first operation and feeds
it into the second. -/
def bind (m : StateF α) (f : α → StateF β) : StateF β := λ s =>
  let (a, s') := m s
  let (b, s'') := f a s'
  (b, s'')

/-- Replaces the current state with another value -/
def replace (x : Bool) : StateF Nat := λ s => (s, if x then 1 else 0)

/-- Calculates whether the state is odd or even -/
def isStateOdd : StateF Bool := λ s => (s % 2 == 1, s)

-- Final state is 1, returns 5
#eval (bind isStateOdd replace) 5
-- Final state is 0, returns 4
#eval (bind isStateOdd replace) 4

/-- The last operation we need is wrapping a constant inside a `StateF`. This
does not mutate the state. -/
def pure (x : α) : StateF α := λ s => (x, s)

-- Final state is 1, returns 5
#eval (bind (pure true) replace) 5
-- Final state is 1, returns 4
#eval (bind (pure true) replace) 4

--- snippet StateF Monad
/-- We now have all the necessary integredients for a monad -/
instance : Monad StateF where
  pure x := pure x
  bind m f := bind m f
--- end

#eval (isStateOdd >>= replace) 5
#eval ((pure true) >>= replace) 4

-- In contrast to functions in imperative languages such as C++ or Python, a
-- Lean function may access IO functions or modify a state only when it is
-- explicitly permitted to do so.

/-- Another use for the monad is to model fallibility. This result type
indicates a computation is either successful (`.ok`) or failed (`.error`) -/
inductive Result (α) where
  | ok (x : α)
  | error (message : String)

instance : ToString (Result Nat) where
  toString x? := match x? with
    | .ok x => s!"Success! {x}"
    | .error message => message


/-- The true `seq` function takes a lazily evaluated `n`. If the first operation
fails, we don't want to evaluate the second. -/
def seq { α β } (m? : Result α) (n? : Unit → Result β) : Result β :=
  match m? with
  | .ok _a =>
    -- Successful result `a` is discarded.
    n? ()
  | .error msg => .error msg

/-- Expensive fib function -/
def fib : Nat → Nat
  | 0 => 1
  | 1 => 1
  | n+2 => (fib n) + (fib (n + 1))

#eval seq (.ok 5) (λ _ => .ok $ fib 10)
-- Second operation is not evaluated because the first one failed.
#eval seq (.error "first op failed" : Result Nat) (λ _ => .ok $ fib 100000)

/-- We can define analogous `pure` and `bind` functions for `Result` -/
def Result.pure {α} (x : α) := Result.ok x
def Result.bind (m? : Result α) (f? : α → Result β) : Result β :=
  match m? with
  | .ok a =>
    f? a
  | .error msg => .error msg

instance : Monad Result where
  pure x := .pure x
  bind m f := .bind m f
