/** The slice of the highlight.js API this grammar needs. */
type HLJS = {
	COMMENT: (begin: string, end: string, modes?: object) => object;
	BACKSLASH_ESCAPE: object;
	C_NUMBER_MODE: object;
};

/**
 * A small Lean 4 grammar for highlight.js — enough for slide-sized excerpts.
 * highlight.js ships no Lean language, and without one every `language-lean`
 * block logs a warning and renders unstyled.
 */
export function lean(hljs: HLJS) {
	return {
		name: 'Lean',
		keywords: {
			$pattern: /[A-Za-z_][\w'?!.]*|#\w+/,
			keyword: [
				'abbrev', 'attribute', 'axiom', 'by', 'calc', 'catch', 'class', 'def', 'deriving',
				'do', 'else', 'end', 'example', 'exact', 'export', 'extends', 'finally', 'for',
				'from', 'fun', 'have', 'if', 'import', 'in', 'inductive', 'instance', 'let',
				'macro', 'match', 'mut', 'mutual', 'namespace', 'notation', 'opaque', 'open',
				'partial', 'private', 'protected', 'repeat', 'return', 'section', 'set_option',
				'show', 'structure', 'syntax', 'then', 'theorem', 'throw', 'try', 'universe',
				'unsafe', 'variable', 'where', 'while', 'with'
			],
			built_in: [
				'Array', 'BaseIO', 'Bool', 'Char', 'EIO', 'EStateM', 'Except', 'Float', 'IO',
				'Id', 'Int', 'List', 'Nat', 'Option', 'Prop', 'Sort', 'String', 'Task', 'Type',
				'Unit'
			],
			literal: ['true', 'false', 'none', 'some'],
			meta: ['#check', '#eval', '#print', '#reduce']
		},
		contains: [
			// Block comments first: `/--` also matches the `--` line comment.
			hljs.COMMENT('/-', '-/', { contains: ['self'] }),
			hljs.COMMENT('--', '$'),
			{ className: 'string', begin: /s?!?"/, end: /"/, contains: [hljs.BACKSLASH_ESCAPE] },
			hljs.C_NUMBER_MODE,
			{ className: 'meta', begin: /@\[/, end: /\]/ },
			{ className: 'symbol', begin: /[←→⇒↦⟨⟩⊢∀∃λ·]/ }
		]
	};
}
