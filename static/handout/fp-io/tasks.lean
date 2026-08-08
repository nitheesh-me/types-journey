def main : IO Unit := do
  let task1 ← EIO.asTask (task 1)
  let task2 ← EIO.asTask (task 2)
  let result1 := task1.get.toOption.getD 0
  let result2 := task2.get.toOption.getD 0
  IO.println s!"{result1}, {result2}"
  where
  task (n : Nat) : IO Nat := do
    IO.println s!"{n}"
    return n * n
