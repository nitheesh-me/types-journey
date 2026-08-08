def count : IO Nat := do
  let mut acc := 0
  repeat
    acc := acc + 1
    if ← IO.checkCanceled then
      return acc
  return 0

def main : IO Unit := do
  let task ← EIO.asTask count
  IO.sleep 100
  IO.cancel task
  let .ok n := task.get | panic "Task failed"
  IO.println s!"Counted {n}"
