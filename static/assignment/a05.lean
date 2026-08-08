/-- Q1
Print the Christmas tree of size `height` to to stdout. This stub only prints
the tree trunk. Below is an example of a Christmas tree of size 3.
```
  *
 ***
*****
  *
  *
```
Now we have seen monads, we can use monadic operations instead of `List.foldl`.
Check the definition of `List.forM` and how it is used here.
-/
def christmas_tree (height : Nat := 3) : IO Unit := do
  List.range height |>.forM λ _ => do
    IO.println "*"
#eval christmas_tree

/-- Describes the immutable configuration of the animation. e.g. its size, frame rate -/
structure Config where
  width : Nat := 20
  height : Nat := 20
/-- Describes the current scene -/
structure Scene where
  time : Nat := 0
  circleRadius : Nat := 3

/-- Q2
A silhouette animation is where the animated character only shows up as a black
silouhette. We are going to produce one with the help of monads.
-/
abbrev AnimateT α := ReaderT Config $ StateT Scene α

/-- Q2.1
This draws a hollow square
-/
def drawSquare: AnimateT IO Unit := do
  let config ← read
  let _scene ← get
  List.range config.height |>.forM λ y => do
    -- Draw the current line
    let line := if config.height / 4 > y ∨ config.height * 3 / 4 < y then
        String.join (List.replicate config.width "*")
      else
        let li := List.range config.width |>.map λ x =>
          if config.width / 4 > x ∨ config.width * 3 / 4 < x then
            "*"
          else
            " "
        String.join li
    IO.println s!"{line}"
#eval drawSquare.run {} |>.run' {}

/-- Q2.2
Define a function that draws a circle with centre at (0, z) where `z` oscillates
between `r` and `height - r`. `r` is the radius of the circle in `Scene`
-/
def drawCircle : AnimateT IO Unit := do
  let scene ← get
  let z : Nat := sorry
  -- draw a circle
  sorry

/-- Q2.3
Modify the `animateM` monad so it sleeps between frames
-/
def silouette (frame : AnimateT IO Unit) (maxTime := 100) : IO Unit := do
  let animateM : AnimateT IO Unit := do
    for i in List.range maxTime do
      modify λ state => { state with time := i }
      frame
  animateM.run {} |>.run' {}

/-- Q2.4
Replace `drawSquare` by the completed `drawCircle` and play the silouette
animation on the command line with `lean --run a05.lean`
-/
def main : IO Unit := do
  silouette drawSquare
