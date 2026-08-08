def main : IO Unit := do
  let site ← IO.Mutex.new 0
  let task1 ← EIO.asTask (worker site 1)
  let task2 ← EIO.asTask (worker site 2)
  let .ok _ := task1.get | panic "task failed"
  let .ok _ := task2.get | panic "task failed"
  site.atomically do println! "{← get}"
  where
  worker (site : IO.Mutex Nat) (id : Nat) : IO Unit :=
    site.atomically do
      let v ← get
      set (v + id)
