import Std.Sync.Channel

def producer (ch : Std.Channel Nat) : IO Unit := do
  for i in List.range 100 do
    ch.send i
    IO.sleep 10
  ch.close
def consumer (ch : Std.Channel Nat) : IO Nat := do
  let mut acc := 0
  for v in ch.sync do
    acc := acc + v
  return acc
def main : IO Unit := do
  let ch ← Std.Channel.new
  let _taskP ← EIO.asTask (producer ch)
  let taskC ← EIO.asTask (consumer ch)
  let .ok sum := taskC.get | panic "task failed"
  IO.println s!"Sum: {sum}"
