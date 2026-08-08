def main : IO Unit := do
  let site ← IO.mkRef 0
  let task1 ← EIO.asTask (worker site 1)
  let task2 ← EIO.asTask (worker site 2)
  let .ok _ := task1.get | panic "task failed"
  let .ok _ := task2.get | panic "task failed"
  println! "{← site.get}"
  where
  worker (site : IO.Ref Nat) (id : Nat) : IO Unit := do
    let v ← site.get
    site.set (v + id)
