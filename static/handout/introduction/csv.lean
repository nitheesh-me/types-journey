/- Introduction: a CSV parser, start to finish.

   Everything the lecture argued for, in one small program: the cases live in
   the type, the parser is total, and failure is a value rather than a panic.

   Run with:   lean --run csv.lean
-/

/- ────────────────────────────────────────────────────────────
   1. The state of the parse, as a structure
   ──────────────────────────────────────────────────────────── -/

--- snippet Parser State
structure ParserState where
  rows : Array (Array String) := #[]
  row : Array String := #[]
  field : String := ""
  /-- Inside a "quoted field". -/
  inQuotes : Bool := false
  /-- Saw a `"` while inside quotes; the next character decides what it meant. -/
  pendingQuote : Bool := false
  deriving Repr
--- end

--- snippet Field and Row Ends
def endField (st : ParserState) : ParserState :=
  { st with row := st.row.push st.field, field := "" }

def endRow (st : ParserState) : ParserState :=
  let st := endField st
  { st with rows := st.rows.push st.row, row := #[] }
--- end

/- ────────────────────────────────────────────────────────────
   2. One character at a time
   ──────────────────────────────────────────────────────────── -/

--- snippet Outside Quotes
def stepOutside (st : ParserState) (c : Char) : ParserState :=
  if c == '"' then { st with inQuotes := true }
  else if c == ',' then endField st
  else if c == '\n' then endRow st
  else if c == '\r' then st
  else { st with field := st.field.push c }
--- end

--- snippet The Step Function
-- Three situations, and the type will not let us forget one of them.
def step (st : ParserState) (c : Char) : ParserState :=
  if st.pendingQuote then
    -- `""` inside a quoted field means one literal quote.
    if c == '"' then { st with field := st.field.push '"', pendingQuote := false }
    else stepOutside { st with inQuotes := false, pendingQuote := false } c
  else if st.inQuotes then
    if c == '"' then { st with pendingQuote := true }
    else { st with field := st.field.push c }
  else
    stepOutside st c
--- end

/- ────────────────────────────────────────────────────────────
   3. The parser itself: total, by structural recursion
   ──────────────────────────────────────────────────────────── -/

--- snippet Parse
-- Recursion on the list of characters: it shrinks every call, so Lean accepts
-- this without `partial` and without a termination proof from us.
def run : List Char → ParserState → ParserState
  | [], st => st
  | c :: rest, st => run rest (step st c)

def parse (input : String) : Array (Array String) :=
  let st := run input.toList {}
  -- A trailing newline should not invent an empty last row.
  if st.field.isEmpty && st.row.isEmpty then st.rows else (endRow st).rows
--- end

--- snippet Parse Example
#eval parse "a,b,c\n1,2,3"
#eval parse "name,note\nAda,\"loves, commas\""
#eval parse "quote,\"he said \"\"hi\"\"\""
--- end

/- ────────────────────────────────────────────────────────────
   4. From strings to a type worth having
   ──────────────────────────────────────────────────────────── -/

--- snippet Reading
structure Reading where
  station : String
  celsius : Int
  verified : Bool
  deriving Repr
--- end

--- snippet Row To Reading
-- Failure is a returned value, not a panic. Every caller has to deal with it.
def toReading (row : Array String) : Except String Reading :=
  match row.toList with
  | [s, t, v] =>
    match t.trimAscii.toString.toInt? with
    | none => .error s!"temperature is not a number: {t.trimAscii.toString}"
    | some celsius =>
      match v.trimAscii.toString with
      | "true" => .ok { station := s.trimAscii.toString, celsius := celsius, verified := true }
      | "false" => .ok { station := s.trimAscii.toString, celsius := celsius, verified := false }
      | other => .error s!"verified is not a boolean: {other}"
  | fields => .error s!"expected 3 fields, got {fields.length}"
--- end

--- snippet Load
-- Header dropped, every row decoded, errors kept rather than thrown away.
def load (input : String) : Array (Except String Reading) :=
  (parse input).toList.drop 1 |>.map toReading |>.toArray
--- end

/- ────────────────────────────────────────────────────────────
   5. Running it
   ──────────────────────────────────────────────────────────── -/

--- snippet Sample Data
def sample : String :=
"station,celsius,verified
Kirkwall,7,true
\"Stanley, Falklands\",9,true
Vostok,-89,false
Broken,not-a-number,true
TooShort,1"
--- end

--- snippet main
def main : IO Unit := do
  let results := load sample
  let mut good := 0
  for result in results do
    match result with
    | .ok r => do
      good := good + 1
      IO.println s!"ok    {r.station} at {r.celsius}°C (verified: {r.verified})"
    | .error e =>
      IO.println s!"error {e}"
  IO.println s!"\n{good} of {results.size} rows decoded"
--- end
