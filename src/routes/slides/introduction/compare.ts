/**
 * Side-by-side snippets for the Introduction deck.
 *
 * These are for contrast rather than for running. The Lean blocks, by contrast, all
 * come out of `static/handout/introduction/` so the audience can execute them.
 * Kept out of the deck markup because template literals full of braces and
 * backticks are unreadable inline.
 */
export type Column = { label: string; language: string; code: string };

export const natType: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `// A separate machine type.
let n: u32 = 5;

// The restriction is the
// representation.`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `// No such thing. Brand it
// and hope.
type Nat = number & {
  readonly __nat: unique symbol
};`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `// unsigned wraps, and
// is famously a trap.
unsigned n = 5;
n - 6;  // 4294967295`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `-- Built from zero and
-- successor. Subtraction
-- is total by truncation.
#eval 5 - 6  -- 0`
	}
];

export const nonEmpty: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `struct NonEmpty<T> {
    head: T,
    tail: Vec<T>,
}

impl<T> NonEmpty<T> {
    // Total: no Option.
    fn first(&self) -> &T {
        &self.head
    }
}`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `type NonEmpty<T> =
  [T, ...T[]];

function first<T>(
  xs: NonEmpty<T>
): T {
  // Total: the tuple type
  // guarantees index 0.
  return xs[0];
}`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `template <class T>
struct NonEmpty {
  T head;
  std::vector<T> tail;

  const T& first() const {
    return head;
  }
};`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `structure NonEmptyList
    (α : Type) where
  head : α
  tail : List α

def NonEmptyList.first
    (xs : NonEmptyList α) : α :=
  xs.head`
	}
];

export const contactSum: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `enum Contact {
    Email(EmailAddress),
    Phone(PhoneNumber),
    Both(EmailAddress,
         PhoneNumber),
}

struct User {
    id: u64,
    contact: Contact,
}`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `type Contact =
  | { kind: "email";
      email: Email }
  | { kind: "phone";
      phone: Phone }
  | { kind: "both";
      email: Email;
      phone: Phone };`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `using Contact = std::variant<
    Email,
    Phone,
    std::pair<Email, Phone>>;

struct User {
  std::uint64_t id;
  Contact contact;
};`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `inductive UserContact where
  | email (a : String)
  | phone (n : String)
  | both (a n : String)

structure User where
  id : Nat
  contact : UserContact`
	}
];

export const contactFlag: Column[] = [
	{
		label: 'The flag',
		language: 'rust',
		code: `struct User {
    id: u64,
    contact: Option<Contact>,
    is_system: bool,
}

// Nothing stops
//   contact: Some(..),
//   is_system: true
// Two fields, four states,
// only three of them mean
// anything.`
	},
	{
		label: 'The case',
		language: 'rust',
		code: `enum Contact {
    Email(EmailAddress),
    Phone(PhoneNumber),
    Both(EmailAddress,
         PhoneNumber),
    System,
}

// Four states, four
// meanings. And every
// match now fails to
// compile until it is
// updated.`
	}
];

export const timeRange: Column[] = [
	{
		label: 'Needs a check',
		language: 'rust',
		code: `struct TimeRange {
    start: Instant,
    end: Instant,
}
// start <= end is a comment,
// a constructor check, or a
// runtime panic. It is not
// in the type.

impl TimeRange {
    fn new(s: Instant, e: Instant)
        -> Result<Self, Error> {
        if s > e { return Err(..) }
        Ok(TimeRange { start: s,
                       end: e })
    }
}`
	},
	{
		label: 'Cannot be wrong',
		language: 'rust',
		code: `struct TimeRange {
    start: Instant,
    duration: Duration,
}
// Duration is non-negative by
// construction, so end is
// always >= start.

impl TimeRange {
    fn end(&self) -> Instant {
        self.start + self.duration
    }
}`
	}
];

export const userTypeProduce: Column[] = [
	{
		label: 'Produced here',
		language: 'rust',
		code: `enum UserType {
    Standard,
    Admin,
    System,
}

fn authenticate(req: &Request) -> User {
    if req.super_user_privileges() {
        User { kind: UserType::Admin, .. }
    } else {
        User { kind: UserType::Standard, .. }
    }
}

fn process_job(job: &Job) -> User {
    User { kind: UserType::System, .. }
}`
	},
	{
		label: 'Consumed there',
		language: 'rust',
		code: `// A different file. A different
// team, probably.

fn authorize(user: &User) -> Decision {
    match user.kind {
        UserType::Standard => { .. }
        UserType::Admin    => { .. }
        UserType::System   => { .. }
    }
}`
	}
];

export const totality: Column[] = [
	{
		label: 'Partial (panics)',
		language: 'rust',
		code: `fn last_changed(
    entries: &[LogEntry]
) -> Instant {
    match entries.first() {
        Some(e) => e.timestamp,
        None => panic!(
            "shouldn't happen"
        ),
    }
}`
	},
	{
		label: 'Total (cannot)',
		language: 'rust',
		code: `fn last_changed(
    entries: &NonEmpty<LogEntry>
) -> Instant {
    entries.first().timestamp
}

// The obligation moved to
// whoever builds the list.`
	}
];

export const paradigmState: Column[] = [
	{
		label: 'Imperative',
		language: 'c',
		code: `int total = 0;
for (int i = 0; i < n; i++) {
    total += xs[i];
}
// State lives outside the code,
// in mutable memory.`
	},
	{
		label: 'Object oriented',
		language: 'java',
		code: `class Basket {
  private int total = 0;
  void add(int x) {
    this.total += x;
  }
}
// State is owned by an object.`
	},
	{
		label: 'Functional',
		language: 'lean',
		code: `def total (xs : List Nat) : Nat :=
  xs.foldl (· + ·) 0

-- No state. A value is
-- threaded through, and every
-- step is a new value.`
	}
];

/* ── Four kinds of dependency ─────────────────────────────────────────── */

export const termOnType: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `// One definition, any T.
fn first_or<T: Copy>(
    fallback: T,
    xs: &[T],
) -> T {
    match xs.first() {
        Some(x) => *x,
        None => fallback,
    }
}`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `function firstOr<T>(
  fallback: T,
  xs: T[],
): T {
  return xs.length
    ? xs[0]
    : fallback;
}`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `template <class T>
T first_or(T fallback,
           std::vector<T> xs) {
  return xs.empty()
    ? fallback
    : xs.front();
}`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `def firstOr {α : Type}
    (fallback : α) :
    List α → α
  | [] => fallback
  | x :: _ => x`
	}
];

export const overloading: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `trait Describe {
    fn describe(&self)
        -> String;
}

impl Describe for u32 { .. }
impl Describe for bool { .. }

// The type picks the body.`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `function describe(
  x: number): string;
function describe(
  x: boolean): string;
function describe(
  x: any): string {
  return String(x);
}
// Signatures only. One body.`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `std::string describe(int n);
std::string describe(bool b);

// Resolved at compile time
// from the argument types.

struct Shape {
  virtual void draw();
};
// Or at run time, by class.`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `class Describe (α : Type) where
  describe : α → String

instance : Describe Nat where
  describe n := s!"num {n}"
instance : Describe Bool where
  describe b := s!"flag {b}"`
	}
];

export const typeOnType: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `// Vec is not a type.
// Vec<i32> is a type.
type Pair<T> = (T, T);

let p: Pair<u8> = (1, 2);`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `type Pair<T> = [T, T];

// And it computes:
type Flag<T> =
  T extends string
    ? "text" : "other";`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `template <class T>
using Pair = std::pair<T, T>;

Pair<int> p{1, 2};`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `abbrev Pair (α : Type) :=
  α × α

#check List
-- Type u → Type u`
	}
];

export const typeOnTerm: Column[] = [
	{
		label: 'Rust',
		language: 'rust',
		code: `// Const generics: the length
// is in the type, but only
// integers and only literals
// or consts.
struct Grid<const N: usize> {
    cells: [f64; N],
}

// No arithmetic on N that the
// checker will reason about.`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `// Literal types come from
// values, but nothing is
// computed with them.
type Digit = 0 | 1 | 2;

type Len<T extends any[]> =
  T["length"];
// Tuple lengths only.`
	},
	{
		label: 'C++',
		language: 'cpp',
		code: `// Non-type template
// parameters, since C++98.
template <class T,
          std::size_t N>
struct array { .. };

std::array<int, 3> a;
// Integers and constants.`
	},
	{
		label: 'Lean',
		language: 'lean',
		code: `-- Any term, of any type,
-- with the full language
-- available in the type.
def three : Vector Nat 3 :=
  #v[1, 2, 3]

def repeatN (n : Nat) (x : Nat)
    : Vector Nat n :=
  Vector.replicate n x`
	}
];
