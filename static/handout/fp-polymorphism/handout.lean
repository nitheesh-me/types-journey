--- snippet Type
#check 1
#check "Hi"
#check fun (x: Nat) => x + 1
--- snippet Dependent Type
#check List Nat
#check List
#check (List)
--- snippet Dependent Function Type
def duplicate { α } (x : α) := [x, x]
#check duplicate
#eval duplicate 1
--- snippet Type Universes
example : Type 1 := Type
example : Type 2 := Type 1
example : Type 1 := Type → Type
--- snippet Polymorphic Vec
structure Vec2 (α) where
  x : α
  y : α
#check Vec2.mk 1 2
--- snippet Type of Function
#check Type 5 → Type 4
--- snippet Universe Polymorphism
def duplicate'.{u} { α : Type u } (x : α) := [x, x]
-- Adaptation fix: upstream checked `duplicate`, but this snippet (and the
-- output shown on the slide) is about `duplicate'`.
#check duplicate'
--- snippet Either
inductive Either (α : Type u) (β : Type v) : Type (max u v) where
  | left : α → Either α β
  | right : α → Either α β
--- snippet Function on Either
def replicate { α β } (e : Either α β): Either (List α) (List β) :=
  match e with
  | .left x => .left [x, x]
  | .right y => .left [y, y, y]
--- end

--- snippet FixedArray
inductive FixedArray (α : Type u) : Nat → Type (u + 1) where
  | nil : FixedArray α 0
  | cons : α → FixedArray α n → FixedArray α (n + 1)
--- snippet FixedArray sum
def FixedArray.sum { n : Nat } : FixedArray Nat n → Nat
  | .nil => 0
  | .cons head tail => head + tail.sum
#print FixedArray.sum
--- snippet Even-Odd List
inductive EvenOddList (α : Type u) : Bool → Type u where
  | nil : EvenOddList α true
  | cons : α → EvenOddList α isEven → EvenOddList α (not isEven)
example : EvenOddList String true :=
  .cons "a" (.cons "b" .nil)
--- snippet Invalid Recursive Parameter
inductive Bad (α : Type u) : Type (u + 2) where
  | intro
  | mult (x : Bad α) (y : Bad (List α))
--- snippet Type as Index
inductive Good : α → Type (u + 2) where
  | intro : Good α
  | mult : (x : Good α) → (y : Good (List α)) → Good α
--- end

namespace Sandbox
--- snippet Type Class Attempt
structure Contracat ( α ) where
  contracat : α → α → α

def instStringContracat : Contracat String := ⟨λ a b ↦
  let b' := String.foldl (λ acc ch => ch.toString ++ acc) "" b
  a ++ b'⟩

#eval instStringContracat.contracat "abc" "123"
--- end
end Sandbox

--- snippet Type Class
class Contracat (α) where
  contracat : α → α → α

instance : Contracat String where
  contracat a b:=
    let b' := String.foldl (λ acc ch => ch.toString ++ acc) "" b
    a ++ b'

#eval Contracat.contracat "123" "abc"
#check instContracatString
--- snippet Contracat of String
instance : Contracat (List α) where
  contracat a b:=
    a ++ b.reverse

#eval Contracat.contracat [1,2] [3,4]
--- snippet Duplicate
class Duplicate (α) where
  duplicate : α → α
class Quadruplicate (α) extends Duplicate α where
  quadruplicate : α → α := duplicate ∘ duplicate

instance : Duplicate Nat where
  duplicate x := x * 2
instance : Quadruplicate Nat where

#eval Quadruplicate.quadruplicate 2
--- end

--- snippet Point BEq
structure Point where
  x : Nat
  y : Nat

instance : BEq Point where
  beq p1 p2 :=
    p1.x == p2.x && p1.y == p2.y

#eval ({ x := 5, y := 4 } : Point) == ({ x := 5, y := 4 } : Point)
--- snippet Vec2 BEq
structure Vec2 where
  x : Nat
  y : Nat
  deriving BEq
#eval ({ x := 5, y := 4 } : Vec2) == ({ x := 5, y := 4 } : Vec2)
--- snippet Vec2 Add
instance : Add Vec2 where
  add p q := ⟨p.x + q.x, p.y + q.y⟩

#eval (⟨3, 4⟩: Vec2) + (⟨5, 6⟩: Vec2)
--- snippet Monoid
class Monoid (α) where
  mul : α → α → α
  identity : α

instance instMonoidNatAdd : Monoid Nat where
  mul a b := a + b
  identity := 0
@[default_instance default]
instance instMonoidNatMul : Monoid Nat where
  mul a b := a * b
  identity := 1

#eval Monoid.mul 5 5
--- snippet Functions on Monoid
def square { α } [Monoid α] (x : α) := Monoid.mul x x

#eval square 5
#eval @square Nat instMonoidNatAdd 5
#eval @square Nat instMonoidNatMul 5
--- end

--- snippet OfNat
structure Complex where
  x : Nat
  y : Nat

instance : OfNat Complex n where
  ofNat := ⟨n, 0⟩

#eval (OfNat.ofNat 5 : Complex)
--- snippet Coercion
instance : Coe String Nat where
  coe s := s.length

#eval ("hi" : Nat)
--- snippet Pair
structure Pair (α) where
  x : α
  y : α
def Pair.toString (p : Pair Nat) : String := s!"({p.x}, {p.y})"
--- snippet Pair Functor
instance : Functor Pair where
  map f p := { x := f p.x, y := f p.y }
#eval Functor.map (· + 1) (⟨2,4⟩: Pair Nat) |>.toString
--- snippet Unlawful Functor
instance unlawful : Functor Pair where
  map f p := { x := f p.y, y := f p.x }
#eval unlawful.map (id ∘ (· + 1)) (⟨2,4⟩: Pair Nat) |>.toString
#eval unlawful.map id (unlawful.map (· + 1) (⟨2,4⟩: Pair Nat)) |>.toString

/- ─────────────────────────────────────────────────────────────────────────
   Added for this adaptation: examples that appear on the slides but had no
   snippet in the upstream handout.
   ───────────────────────────────────────────────────────────────────────── -/

--- snippet Class Abbreviation
class abbrev AddMul (α : Type u) := Add α, Mul α
--- end

--- snippet Class Abbreviation Desugared
class AddMul' (α : Type u) extends Add α, Mul α
instance [Add α] [Mul α] : AddMul' α where
--- end
