/- A short tour, for deciding whether any of this is worth your time.

   Nothing here assumes you have met Lean before. Every block is shown on a
   slide in Lecture 00.

   Run the whole file with:   lean tour.lean
-/

/- ────────────────────────────────────────────────────────────
   1. A value that cannot be built wrong
   ──────────────────────────────────────────────────────────── -/

--- snippet No Empty Case
-- Instead, build "at least one" into the shape of the data: one element,
-- and then however many more.
structure Batch where
  first : String
  rest : List String

-- No empty case exists, so this function has nothing to fail on.
def Batch.newest (b : Batch) : String := b.first

#eval (Batch.mk "2024-06-01" ["2024-05-30"]).newest
--- end

/- ────────────────────────────────────────────────────────────
   2. A function with no failure case
   ──────────────────────────────────────────────────────────── -/

--- snippet Every Case Answered
inductive Payment where
  | card (last4 : String)
  | transfer (iban : String)
  | credit (note : String)

-- Delete any one of these three lines and the file stops compiling.
def receipt : Payment → String
  | .card l => s!"card ending {l}"
  | .transfer i => s!"transfer from {i}"
  | .credit n => s!"account credit ({n})"

#eval receipt (.card "4242")
--- end

--- snippet Adding A Case
-- Add a fourth way to pay, and the checker names every place that has to
-- decide what it means. Not a search: a list.
inductive Payment' where
  | card (last4 : String)
  | transfer (iban : String)
  | credit (note : String)
  | voucher (code : String)

def receipt' : Payment' → String
  | .card l => s!"card ending {l}"
  | .transfer i => s!"transfer from {i}"
  | .credit n => s!"account credit ({n})"
  | .voucher c => s!"voucher {c}"

#eval receipt' (.voucher "SPRING24")
--- end

/- ────────────────────────────────────────────────────────────
   3. A length that lives in the type
   ──────────────────────────────────────────────────────────── -/

--- snippet Length In The Type
-- The 3 is not documentation. It is part of the type, and the checker
-- knows it.
def week : Vector String 3 := #v["mon", "tue", "wed"]

-- So this index cannot be out of range, and there is no check at run time.
#eval week[1]

-- Hand it a differently sized vector and it will not compile.
def middle (v : Vector String 3) : String := v[1]

#eval middle week
--- end

/- ────────────────────────────────────────────────────────────
   4. One small proof
   ──────────────────────────────────────────────────────────── -/

--- snippet A Property
-- Reversing a list twice gives you back the list you started with.
-- Not for the lists we tested: for every list, of every type.
theorem reverse_reverse (xs : List α) : xs.reverse.reverse = xs := by
  simp
--- end

/- ────────────────────────────────────────────────────────────
   5. And it is still a program
   ──────────────────────────────────────────────────────────── -/

--- snippet It Runs
def main : IO Unit := do
  let batch := Batch.mk "2024-06-01" ["2024-05-30"]
  IO.println s!"newest: {batch.newest}"
  IO.println (receipt (.transfer "GB33BUKB..."))
  IO.println s!"middle of the week: {middle week}"
--- end
