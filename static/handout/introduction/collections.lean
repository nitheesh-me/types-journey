/- Introduction: lists, arrays, vectors and strings.

   Run with:   lean collections.lean
-/

/- ────────────────────────────────────────────────────────────
   List: a linked list, and an inductive type like any other
   ──────────────────────────────────────────────────────────── -/

--- snippet List Basics
def nums : List Nat := [3, 1, 4, 1, 5]

#eval nums.length
#eval nums.head?              -- Option Nat: the empty case is in the type
#eval nums.reverse
#eval 9 :: nums               -- cons: cheap at the front
--- end

--- snippet List Operations
#eval nums.map (· * 2)
#eval nums.filter (· > 2)
#eval nums.foldl (· + ·) 0
#eval nums.take 3
#eval nums.drop 3
#eval nums ++ [9, 2]
#eval nums.contains 4
--- end

--- snippet List is Inductive
-- `List` is not built in. It is the same shape you would write yourself.
inductive Chain (α : Type) where
  | done
  | link (head : α) (rest : Chain α)

def Chain.toList {α : Type} : Chain α → List α
  | .done => []
  | .link h r => h :: r.toList

#eval (Chain.link 1 (.link 2 .done)).toList
--- end

/- ────────────────────────────────────────────────────────────
   Array: contiguous, indexed, fast
   ──────────────────────────────────────────────────────────── -/

--- snippet Array Basics
def arr : Array Nat := #[3, 1, 4, 1, 5]

#eval arr.size
#eval arr[2]!                 -- panics if out of range
#eval arr[2]?                 -- Option Nat: no panic
#eval arr.push 9
#eval arr.map (· * 2)
--- end

--- snippet Array Index Is Checked
-- Given a proof that the index is in range, no check is needed at runtime
-- and no failure case exists.
def secondOf (a : Array Nat) (h : 1 < a.size) : Nat := a[1]

#eval secondOf arr (by decide)
--- end

/- ────────────────────────────────────────────────────────────
   Vector: an array whose length is part of its type
   ──────────────────────────────────────────────────────────── -/

--- snippet Vector
def v3 : Vector Nat 3 := #v[1, 2, 3]

#eval v3.toArray
#eval v3[0]                   -- always in range: 0 < 3 is known statically

-- The length travels with the value, so this cannot be given a
-- differently-sized vector.
def sum3 (v : Vector Nat 3) : Nat := v[0] + v[1] + v[2]

#eval sum3 v3
--- end

/- ────────────────────────────────────────────────────────────
   String
   ──────────────────────────────────────────────────────────── -/

--- snippet String Basics
def greeting : String := "Hello, POPL/M"

#eval greeting.length
#eval greeting.toUpper
#eval greeting.take 5
#eval greeting.splitOn ", "
#eval greeting.replace "Hello" "Goodbye"
-- `trimAscii` returns a slice, so ask for the String back.
#eval "  padded  ".trimAscii.toString
--- end

--- snippet String Interpolation
def name : String := "world"

#eval s!"hello, {name}"       -- s! builds a String
#eval toString (1 + 2)
--- end

--- snippet String Is Not A List
-- Indexing a string is by position, and the empty case is still in the type.
#eval greeting.toList.head?
#eval greeting.toList.take 5  -- List Char, if you really want one
--- end
