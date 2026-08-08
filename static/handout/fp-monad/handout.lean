--- snippet Option Functions
-- Wraps a value
#check Option.some
-- Applies a function to the argument of an option
#check Option.map
-- Applies a function if an option is .some
#check Option.bind
--- snippet StateNatM
def StateNatM (α) := Nat → (Nat × α)
instance : Monad StateNatM where
  pure x := λ s => (s, x)
  bind m f := λ s =>
    let (s', x) := m s
    f x s'
def StateNatM.get : StateNatM Nat := λ s => (s, s)
def StateNatM.set (s : Nat) : StateNatM Unit
  := λ _ => (s, ())
--- snippet Stateful computation
/-- Adds 1 to the state and returns the previous state -/
def incrementState : StateNatM Nat :=
  .get >>=
  λ x => .set (x + 1) >>=
  λ _ => pure x
#eval incrementState 5
--- snippet do-notation
def mystery (s : String) : Option String := do
  let first ← s.get? 0
  return first.toString
#eval mystery "hi"
--- snippet Implementation of do
set_option pp.notation false
#print mystery
--- snippet Early Return
def mysteryM (hi : Nat) : Option Nat := do
  if hi < 5 then
    return 10
  -- else pure ()
  return hi + 1
#eval mysteryM 5
#eval mysteryM 4
--- snippet Reader
def truncator (s: String) : ReaderM Nat String := do
  return s.take (← read)
#eval truncator "abc" |>.run 2
--- snippet withReader
def reader1 : ReaderM Nat Nat := do
  return (← read) + 1
def reader2 : ReaderM Nat Nat := do
  withReader (λ s => s * 2) reader1
#eval reader2 |>.run 2
--- snippet Linear Congruential
def linCongrGen : StateM Nat Nat := do
  let prev ← get
  let next := (23 * prev + 14) % 79
  set next
  return next % 10
#eval linCongrGen.run 7
--- end

--- snippet Accumulation
def accumulation : Id Nat := do
  let mut acc := 0
  for i in List.range 5 do
    acc ← acc + i
  return acc
#eval accumulation.run
--- snippet Triangle
def triangle (x : Nat) : Nat := Id.run do
  let mut z := 0
  let mut acc := 0
  while z < x do
    z := z + 1
    acc := acc + z
  return acc
#eval triangle 5
--- snippet ReaderT
def replicatorM (pre : String) : ReaderT Nat Option (List Char) := do
  let times ← read
  let head ← pre.get? 0
  return List.replicate times head

#eval replicatorM "hi" |>.run 5
#eval replicatorM "" |>.run 5
--- snippet StateT
def visitorM : StateT Nat Option Nat := do
  let s ← get
  set (s + 1)
  match s with
    | 0 => .none
    | k+1 => .some k
#eval visitorM.run 5
--- snippet RandomT
abbrev RandomT := StateT Nat
def next [Monad m] : RandomT m Nat :=
  modifyGet λ s => (s, (2 * s + 4) % 7)
def generator : RandomT IO Unit := do
  IO.println s!"{← next}"
  IO.println s!"{← next}"
def main : IO Unit :=  generator.run' 2
#eval main
--- snippet Roulette
def roulette : OptionT (RandomT Id) Nat := do
  let r ← next (m := Id)
  if r == 0 then
    OptionT.fail
  return r
--- snippet Roulette'
def roulette' : RandomT Id (Option Nat) := do
  let r ← next (m := Id)
  if r == 0 then
    return .none
  return .some r
--- end

/- ─────────────────────────────────────────────────────────────────────────
   Added for this adaptation: examples that appear on the slides but had no
   snippet in the upstream handout.
   ───────────────────────────────────────────────────────────────────────── -/

-- Namespaced: the file already has a `mysteryM` in the Early Return snippet.
namespace Lifting
--- snippet MonadLift Instance
instance : MonadLift (ReaderM Nat) (ReaderT Nat Option) where
  monadLift m := do
    let s ← read
    let z := m.run s
    return z

def mysteryPureM : ReaderM Nat Nat := do
  let s ← read
  return s + s

def mysteryM : ReaderT Nat Option Nat := do
  let s ← read
  let pure ← mysteryPureM
  match s with
    | 0 => .none
    | k+1 => .some (k + pure)

#eval mysteryM.run 5
--- end
end Lifting
