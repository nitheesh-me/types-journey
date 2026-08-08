def main : IO Unit := do
  let c ← (← IO.getStdin).getLine
  IO.println c
