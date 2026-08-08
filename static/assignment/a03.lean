/-- Q1:
Define a function that repeats every element of a list twice.
e.g. `[1] -> [1, 1]`, `["hi"], ["hi", "hi"]`. What should its type be?
-/
def verbosify : sorry → sorry := sorry

inductive FixedArray (α : Type u) : Nat → Type (u + 1) where
  | nil : FixedArray α 0
  | cons : α → FixedArray α n → FixedArray α (n + 1)

/-- Q2:
Define a function which sums the elements in a fixed array.
-/
def FixedArray.sum {n : Nat} (x : FixedArray Nat n) : Nat := sorry


/-- Q3:
Define a complex integer type and equip it with the four arithmetic operations.
-/
structure Complex where
  x : Int
  y : Int
  deriving BEq

/-- Q3.1:
Define a to string function for complex
e.g. `(Complex.mk 1 2).toString == "1 + 2i"`
-/
instance : ToString Complex where
  toString z := sorry

instance : Add Complex where
  add z1 z2 := ⟨z1.x + z2.x, z1.y + z2.y⟩
-- more operations here
#eval (Complex.mk 1 2) + ⟨3, 4⟩

/-- Q4:
Define a `Coe` instance that turns an `Int` into a complex integer. This is a
standard way to construct generalized mathematical structures (e.g. Nat, Int,
Rational, Real, Complex)
-/
instance : Coe Int Complex where
  coe i := sorry

/-- Q5:
Define an elementwise multiplication operation for `Complex` and mark the
previous one as a default instance.
-/
instance elementwise : Mul Complex where
  mul z1 z2 := sorry

/-- This box knows where it was produced -/
structure Box (α) where
  elem : α
  maker : String
def produceNat (x : Nat) : Box Nat := ⟨x % 2, "Alice"⟩
def produceString (s : String) : Box String := ⟨s.take 5, "Bob"⟩
def describeN (x : Box Nat) := s!"I'm a Nat {x.elem} made by {x.maker}"
def describeS (x : Box String) := s!"I'm a String {x.elem} made by {x.maker}"

/-- Q6.1:
Define a `Functor` instance for `Box`
-/
instance : Functor Box where
  map f box := sorry

/-- Q6.2
Apply `String.length` to the string inside `Box String`
-/
def calculateLength (b : Box String) : Box Nat := sorry

#eval describeN $ calculateLength $ produceString "hello"
