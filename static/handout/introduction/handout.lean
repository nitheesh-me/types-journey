/- Introduction: from types to Lean.

   Follow along in your editor. Every block below is shown on a slide, and the
   name after `--- snippet` is the label printed on the box.

   Run the whole file with:   lean handout.lean
-/

/- ────────────────────────────────────────────────────────────
   Definitions
   ──────────────────────────────────────────────────────────── -/

--- snippet Definitions
-- A definition names a term. That is all `def` does.
def greeting : String := "hello"
def double (n : Nat) : Nat := 2 * n

-- Names are reusable: definitions are built from other definitions.
def quadruple (n : Nat) : Nat := double (double n)

#eval greeting
#eval quadruple 5
--- end

namespace Terms
--- snippet Terms and Types
-- Every term has a type, and `#check` asks what it is.
#check 5              -- Nat
#check "hello"        -- String
#check double         -- Nat → Nat

-- Types are terms too, so they have types of their own.
#check Nat            -- Type
#check Type           -- Type 1
--- end
end Terms

namespace Props
--- snippet Prop
-- A proposition is a type whose terms are proofs of it.
#check 2 + 2 = 4      -- Prop
#check ∀ n : Nat, n + 0 = n

-- A proof is an ordinary term of that type.
theorem two_plus_two : 2 + 2 = 4 := rfl
#check two_plus_two   -- 2 + 2 = 4
--- end
end Props

namespace FnTypes
--- snippet Function Types
-- The type records the domain and the codomain, not the image.
def isEven (n : Nat) : Bool := n % 2 == 0
#check isEven         -- Nat → Bool

-- Functions of several arguments are functions returning functions.
def add (a b : Nat) : Nat := a + b
#check add            -- Nat → Nat → Nat
#check add 1          -- Nat → Nat
--- end
end FnTypes

namespace Universes
--- snippet Type Universes
-- `Type` cannot contain itself, so the levels go up forever.
#check Type 0         -- Type 1
#check Type 1         -- Type 2

-- A definition can be polymorphic in the level.
def identity.{u} {α : Sort u} (a : α) : α := a
#check @identity
--- end
end Universes

--- snippet def, partial def, noncomputable def
-- `def` must be shown to terminate; Lean can evaluate it.
def countdown : Nat → List Nat
  | 0 => [0]
  | n + 1 => (n + 1) :: countdown n

-- `partial` opts out of the termination proof. It still runs, but the
-- logic cannot see inside it.
partial def collatz (n : Nat) : Nat :=
  if n <= 1 then 0 else
  if n % 2 == 0 then 1 + collatz (n / 2) else 1 + collatz (3 * n + 1)

-- `noncomputable` marks a definition that exists but cannot be run.
noncomputable def someNat : Nat := Classical.choice ⟨0⟩

#eval countdown 3
#eval collatz 27
--- end

/- ────────────────────────────────────────────────────────────
   Structures: the "and" type
   ──────────────────────────────────────────────────────────── -/

--- snippet Structure
structure Point where
  x : Nat
  y : Nat := 0        -- a default value
  deriving Repr

#eval ({ x := 3, y := 4 } : Point)
#eval (⟨3, 4⟩ : Point).x
#eval { x := 3, y := 4 : Point }.y
--- end

--- snippet Structure Update
def shiftRight (p : Point) : Point := { p with x := p.x + 1 }

#eval shiftRight { x := 1, y := 2 }
--- end

/- ────────────────────────────────────────────────────────────
   Inductives: the "or" type
   ──────────────────────────────────────────────────────────── -/

--- snippet Enum
inductive UserType where
  | standard
  | admin
  | system
  deriving Repr

-- Every case has to be handled; leave one out and this will not compile.
def canDeleteAccounts : UserType → Bool
  | .standard => false
  | .admin => true
  | .system => true

#eval canDeleteAccounts .admin
--- end

--- snippet UserContact
-- The constraint "at least one of email or phone" becomes three cases.
inductive UserContact where
  | email (address : String)
  | phone (number : String)
  | both (address : String) (number : String)
  deriving Repr

structure User where
  id : Nat
  contact : UserContact
  deriving Repr

def contactLabel : UserContact → String
  | .email a => s!"email: {a}"
  | .phone n => s!"phone: {n}"
  | .both a n => s!"email: {a}, phone: {n}"

#eval contactLabel (.both "a@example.com" "555-0100")
--- end

--- snippet UserContact with System
-- A system user has no contact details. Adding a case beats adding a flag:
-- the checker now names every place that has to decide what to do.
inductive Contact where
  | email (address : String)
  | phone (number : String)
  | both (address : String) (number : String)
  | system
  deriving Repr

def notify : Contact → String
  | .email a => s!"mailing {a}"
  | .phone n => s!"texting {n}"
  | .both a _ => s!"mailing {a}"
  | .system => "system user: nothing to notify"

#eval notify .system
--- end

--- snippet Recursive Inductive
-- A list is empty, or a head and a tail.
inductive MyList (α : Type) where
  | nil
  | cons (head : α) (tail : MyList α)
  deriving Repr

def MyList.length {α : Type} : MyList α → Nat
  | .nil => 0
  | .cons _ tail => 1 + tail.length

#eval (MyList.cons 1 (.cons 2 .nil)).length
--- end

--- snippet NonEmptyList
-- "At least one element" is a head and a possibly-empty tail.
structure NonEmptyList (α : Type) where
  head : α
  tail : List α
  deriving Repr

-- Total: there is no empty case to panic on.
def NonEmptyList.first {α : Type} (xs : NonEmptyList α) : α := xs.head

#eval (NonEmptyList.mk 3 [1, 2]).first
--- end

/- ────────────────────────────────────────────────────────────
   Option, Sum, Product
   ──────────────────────────────────────────────────────────── -/

--- snippet Option
-- `Option α` is "an α, or nothing": a sum type with a familiar name.
def firstEven (xs : List Nat) : Option Nat :=
  xs.find? (· % 2 == 0)

#eval firstEven [1, 3, 4, 5]
#eval firstEven [1, 3, 5]

-- The caller has to say what happens when there is nothing.
#eval (firstEven [1, 3, 5]).getD 0
--- end

--- snippet Sum and Product
-- Product: an α AND a β.  Sum: an α OR a β.
#check (⟨1, "one"⟩ : Nat × String)
#check (Sum.inl 1 : Nat ⊕ String)

def describe : Nat ⊕ String → String
  | .inl n => s!"number {n}"
  | .inr s => s!"text {s}"

#eval describe (.inr "hello")
--- end

/- ────────────────────────────────────────────────────────────
   Polymorphism
   ──────────────────────────────────────────────────────────── -/

--- snippet Polymorphism
-- One definition, every element type.
def pairUp {α β : Type} (a : α) (b : β) : α × β := (a, b)

#eval pairUp 1 "one"
#eval pairUp true 'x'

-- The type says what the function cannot do: knowing nothing about α,
-- `swap` can only move the values around.
def swap {α β : Type} : α × β → β × α
  | (a, b) => (b, a)

#eval swap (1, "one")
--- end

/- ────────────────────────────────────────────────────────────
   Ways to write a function
   ──────────────────────────────────────────────────────────── -/

--- snippet Functions
-- Anonymous functions, three spellings of the same thing.
#eval (fun n => n + 1) 5
#eval (λ n => n + 1) 5
#eval (· + 1) 5

-- `let` names an intermediate value.
def area (w h : Nat) : Nat :=
  let half := h / 2
  w * half

-- `where` puts helpers after the definition that uses them.
def quadrupleW (n : Nat) : Nat :=
  twice (twice n)
  where twice (m : Nat) : Nat := 2 * m

#eval area 10 6
#eval quadrupleW 3
--- end

--- snippet let rec
-- `let rec` defines a recursive helper inside a definition.
def sumTo (n : Nat) : Nat :=
  let rec go : Nat → Nat → Nat
    | 0, acc => acc
    | k + 1, acc => go k (acc + k + 1)
  go n 0

#eval sumTo 10
--- end

/- ────────────────────────────────────────────────────────────
   Recursion instead of loops
   ──────────────────────────────────────────────────────────── -/

--- snippet Structural Recursion
-- Lean accepts this because the argument shrinks on every call.
def sumList : List Nat → Nat
  | [] => 0
  | x :: xs => x + sumList xs

#eval sumList [1, 2, 3, 4]
--- end

--- snippet Tail Recursion
-- Carrying an accumulator makes the recursive call the last thing that
-- happens, which the compiler turns into a loop.
def sumListTR (xs : List Nat) : Nat :=
  go xs 0
  where
  go : List Nat → Nat → Nat
    | [], acc => acc
    | x :: rest, acc => go rest (acc + x)

#eval sumListTR [1, 2, 3, 4]
--- end

--- snippet Termination Fails
-- Without `partial`, Lean rejects this: nothing is getting smaller.
-- Uncomment to see the error.
-- def forever (n : Nat) : Nat := forever n
--- end

/- ────────────────────────────────────────────────────────────
   Four kinds of dependency

   One thing can depend on another in four combinations, and each
   combination is a feature you already use under a different name.
   ──────────────────────────────────────────────────────────── -/

namespace Dependency

--- snippet Term on Term
-- A term depending on a term: an ordinary function.
def addOne (n : Nat) : Nat := n + 1

#eval addOne 4
--- end

--- snippet Term on Type
-- A term depending on a type: one definition, every element type.
def firstOr {α : Type} (fallback : α) : List α → α
  | [] => fallback
  | x :: _ => x

#eval firstOr 0 [7, 8]
#eval firstOr "nothing" ([] : List String)

-- Or a term selected *by* a type, which is what overloading is.
class Describe (α : Type) where
  describe : α → String

instance : Describe Nat where
  describe n := s!"the number {n}"
instance : Describe Bool where
  describe b := s!"the flag {b}"

#eval Describe.describe 3
#eval Describe.describe true
--- end

--- snippet Type on Type
-- A type depending on a type: `List` is a function from types to types.
#check List                 -- Type u → Type u
#check List Nat             -- Type

abbrev Pair (α : Type) := α × α

#check Pair Nat
#eval ((3, 4) : Pair Nat)
--- end

--- snippet Type on Term
-- A type depending on a term: the length is a `Nat`, and it is in the type.
def three : Vector Nat 3 := #v[1, 2, 3]

def repeatN (n : Nat) (x : Nat) : Vector Nat n := Vector.replicate n x

#eval (repeatN 4 7).toArray

-- A proposition is a type that depends on terms too.
#check (3 = 3)
#check ∀ n : Nat, n + 0 = n
--- end

end Dependency
