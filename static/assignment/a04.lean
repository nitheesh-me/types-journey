/-- Q1:
The `StateNatM` monad maintains a mutable state of type `Nat`. We can
analogously define a `ReaderNatM` which maintains an immutable state. In this
case, what should its type be? Define the monad and create an instance for it.
-/
def ReaderNatM (α) := sorry
instance : Monad ReaderNatM where
  pure x := sorry
  bind m f := sorry

/-- Q2:
Write a function that concatenates all strings in a list together, using a
monadic loop.
-/
def concatall (x : List String) : String := sorry

/-- Q3:
`IO` is a monad which allows interaction with the outside world. We can define
an analogous monad here using a `List String` state to represent messages
written to the console. Define a `println` function that adds one line to this
list.
-/
abbrev SimpleIO := StateM (List String)
def SimpleIO.println (s : String) : SimpleIO Unit := sorry

def count (n : Nat) : SimpleIO Unit := do
  for i in List.range n do
    SimpleIO.println s!"{i+1}"

/- This should print out the numbers from 1 to 10 -/
#eval (count 10).run [] |>.snd
