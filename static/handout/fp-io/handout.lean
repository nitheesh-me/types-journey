--- snippet Println
def simplePrint : IO Nat := do
  IO.println "hi"
  return 5
#eval simplePrint
--- snippet Println'
def interpolation : IO Unit := do
  let x := 1
  println! "{x + x}"
#eval interpolation
--- snippet IO Exception
def fallible (n : Nat) : IO Unit := do
  if n == 0 then
    throw (.userError "I can't process 0")
  else
    IO.println s!"{n}"
def catching : IO Unit := do
  try
    fallible 5
    fallible 0
  catch ex =>
    IO.println s!"{ex.toString}"
#eval catching
--- snippet Throw Syntactic Sugar
def fallible' (n? : Option Nat) : IO Unit := do
  let .some n := n? | throw $ .userError "No number provided."
  IO.println s!"{n}"
#eval fallible' .none
--- snippet Finally
def catching' : IO Unit := do
  try
    fallible 5
    fallible 0
  catch ex =>
    IO.println s!"{ex.toString}"
  finally
    IO.println "This will run regardless"
--- snippet Panic
def cant (n : Nat) : Nat :=
  if n < 1 then
    panic "can't handle this case"
  else
    n - 1
