/**
 * Side-by-side snippets for Lecture 00.
 *
 * These are for recognition rather than for running: the reader should see
 * their own code in at least one column. The Lean blocks come from
 * `static/handout/should-i-learn-lean/tour.lean` instead, so they can be
 * executed.
 */
export type Column = { label: string; language: string; code: string };

/** The invariant that lives in a comment, and the same thing in the data. */
export const inComment: Column[] = [
	{
		label: 'The comment',
		language: 'typescript',
		code: `/**
 * @param entries - must not
 *   be empty. Caller checks.
 */
function latest(
  entries: Entry[],
): Entry {
  return entries[0];
  // undefined, sometimes,
  // in production, at 3am
}`
	},
	{
		label: 'The shape',
		language: 'typescript',
		code: `type Batch = {
  first: Entry;
  rest: Entry[];
};

function latest(
  b: Batch,
): Entry {
  return b.first;
  // Always an Entry.
  // No comment needed.
}`
	}
];

/** Does the language make you handle every case? */
export const exhaustive: Column[] = [
	{
		label: 'Go',
		language: 'go',
		code: `switch p.Kind {
case Card:
    return "card"
case Transfer:
    return "transfer"
}
// Forgot Credit.
// Compiles. Returns "".`
	},
	{
		label: 'Python',
		language: 'python',
		code: `match p:
    case Card():
        return "card"
    case Transfer():
        return "transfer"
# Forgot Credit.
# Runs. Returns None.`
	},
	{
		label: 'TypeScript',
		language: 'typescript',
		code: `switch (p.kind) {
  case "card":
    return "card";
  case "transfer":
    return "transfer";
}
// Error, if the return type
// says string and you have
// strict checks on.`
	},
	{
		label: 'Rust',
		language: 'rust',
		code: `match p {
    Card(_) => "card",
    Transfer(_) => "transfer",
}
// error[E0004]: non-exhaustive
// patterns: \`Credit(_)\` not
// covered. Will not build.`
	}
];

/** Testing a property by sampling, versus stating it once. */
export const testVsProof: Column[] = [
	{
		label: 'A property test',
		language: 'typescript',
		code: `test("reverse twice", () => {
  fc.assert(fc.property(
    fc.array(fc.integer()),
    (xs) => {
      expect(
        xs.reverse().reverse()
      ).toEqual(xs);
    },
  ));
});

// 100 random arrays.
// Green means "no
// counterexample found".`
	},
	{
		label: 'A proof',
		language: 'lean',
		code: `theorem reverse_reverse
    (xs : List α) :
    xs.reverse.reverse = xs := by
  simp

-- Every list.
-- Every element type.
-- Checked once, at compile
-- time, and then it is
-- settled.`
	}
];

/** What "the length is known" looks like where the reader already works. */
export const lengthKnown: Column[] = [
	{
		label: 'Runtime check',
		language: 'typescript',
		code: `function middle(
  week: string[],
): string {
  if (week.length !== 3) {
    throw new Error("nope");
  }
  return week[1];
}
// A check, a throw, and a
// caller who must handle it.`
	},
	{
		label: 'Known already',
		language: 'lean',
		code: `def middle
    (v : Vector String 3) :
    String :=
  v[1]

-- No check. No throw.
-- Nothing for the caller
-- to handle, because the
-- wrong size will not
-- compile.`
	}
];
