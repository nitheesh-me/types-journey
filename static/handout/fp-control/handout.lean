--- snippet If
def f1 x :=
  if x < 10 then
    "small"
  else
    "big"
#eval f1 5
--- snippet Match
def f2 (n: Nat) : String :=
  match n with
  | 0 => "small"
  | 1 => "small"
  | _ => "big"
#eval f2 2
#eval f2 1
--- snippet Match-Sugar
def f2' : Nat → String
  | 0 => "small"
  | 1 => "small"
  | _ => "big"
#eval f2' 2
#eval f2' 1
--- snippet Comments
-- Line comment
/- Block comment -/
/- /- Nested Block comment -/ -/
/-- Documentation of a function -/
def documented_f (x : Nat) : Nat := x + 1
--- snippet Default Argument
def square (x : Nat) (op : Nat → Nat := λ x => x * x) := op (op x)
#eval square 5
#eval square 5 λ x => x + x
--- snippet Named Argument
#eval square (op := λ x => x + 1) 10
--- snippet Section
section
set_option pp.all true
#check λ x => x + 1
end
--- snippet Currying
def curry x y := x + y + 1
def add2 := curry 1
--- snippet Fold
#eval List.foldl
  (fun acc y => acc ++ " " ++ y)
  ""
  ["tic", "toc", "tic2", "toc2"]
--- snippet Recursion
def rec1 x := match x with
  | 0 => 1
  | y+1 => 2 + (rec1 y)
--- snippet Partial
partial def factorial (n : Nat) : Nat :=
  if n == 0
  then 1
  else
   n * factorial (n - 1)
--- snippet Mutual Recursion
mutual
def on x :=
  if x <= 1 then
    1
  else
    off (x - 1)
def off x :=
  if x <= 1 then
    0
  else
    on (x - 1)
end
--- snippet Let
#eval let x := 5; x + 1
def f_let x :=
  let y := x * 2
  y + y + 1
#eval f_let 10
--- snippet Let-Rec
def rect (x : Nat) :=
  let rec tri x := match x with
    | 0 => 1
    | y+1 => y + tri y
  tri x + (tri (x + 1))
--- snippet Thunk
def thunk : Unit → Nat := λ _ => 1 + 2 + 3 + 4 + 5
#eval thunk ()
--- snippet Structure
structure Point where
  x : Nat
  y : Nat := 0 -- Default value
--- snippet Pattern Matching
def swap (p : Point) : Point :=
  let { x, y } := p
  { x := y, y := x }
--- snippet Pattern Matching'
def sort (p : Point) : Point :=
  let p'@{ x, y := _ } := swap p
  if x < p.x then p else p'
--- snippet Extends
structure Point3 extends Point where
  z : Nat
#check Point3.mk
--- snippet Constructor Renaming
structure Complex where
  from2d ::
  re : Int
  im : Int
#check Complex.from2d
--- snippet Weekday
inductive Weekday where
  | monday
  | tuesday
  | wednesday
  | thursday (color : Nat)
def f : Weekday → Nat
  | .monday => 0
  | .tuesday => 1
  | .wednesday => 2
  | .thursday color => 3 + color
--- snippet Match-Nested
def f' : Option Weekday → Nat
  | .none => 0
  | .some .monday => 10
  | .some z => f z
--- snippet FakeNat
inductive FakeNat where
  | zero
  | succ (prev : FakeNat)
def toNat : FakeNat → Nat
  | .zero => 0
  | .succ prev => 1 + (toNat prev)
--- snippet Strict Positivity
inductive Bad where
  | bad (f : Bad → Bad)
--- snippet Tree
inductive Tree where
  | leaf (x : Nat)
  | branch (x : Nat) (left right : Tree)
def sumTree : Tree → Nat
  | .leaf x => x
  | .branch x left right => x + (sumTree left) + (sumTree right)
--- snippet Bool.casesOn
#eval Bool.casesOn (motive := λ _ => Nat) false 1 2
#eval Bool.casesOn (motive := λ _ => Nat) true 1 2
--- snippet Dependent type motive
#eval Bool.casesOn (motive := λ b => if b then String else Nat) false (5 : Nat) "a"
--- snippet Match Implementation
set_option pp.match false
#print f.match_1
--- snippet Triangle
def tri : Nat → Nat := Nat.rec
  (zero := 0)
  (succ := λ n prev => n + prev)
#eval tri 5
--- end


/- ─────────────────────────────────────────────────────────────────────────
   Added for this adaptation: examples that appear on the slides but had no
   snippet in the upstream handout. Each is namespaced so the file still
   compiles as a whole.
   ───────────────────────────────────────────────────────────────────────── -/

--- snippet Namespace
#check String.intercalate
#eval ", ".intercalate ["Apple", "Orange"]
--- end

namespace CurryingTypes
--- snippet Currying Types
def f x y := x + y + 1

#check (f)
#check f 5
#check f 1 2
--- end
end CurryingTypes

namespace PointFree
--- snippet Point-Free
def f := List.map String.length
#eval f ["123"]
--- end
end PointFree

namespace SubFunctions
--- snippet Sub-functions
def f x :=
  g (g x)
  where
  g y := y * 2
#eval f 10
--- end
end SubFunctions

namespace Tuple
--- snippet Tuple
def f x := (3 * x, 2 * x)

#eval (f 5).fst
--- end
end Tuple

--- snippet Structure Literal
#eval ({ x := 4, y := 5 }: Point) -- { x := 4, y := 5 }
#eval let p1 := Point.mk 1 2; { p1 with y := 5 } -- { x := 1, y := 5 }
#eval ( ⟨2, 3⟩: Point ) -- { x := 2, y := 3 }
--- end
