/**
 * Handout files are plain source files carved into named blocks:
 *
 *     --- snippet Function
 *     def f x = x + 2
 *     --- end
 *
 * `--- end` is optional; a block otherwise runs until the next header or EOF.
 */
export const SNIPPET_HEADER = '--- snippet ';

const HEADER_PATTERN = /--- snippet (?<key>.*)\n/g;
const END_PATTERN = /--- end/;

export function parseSnippets(source: string): Record<string, string> {
	const headers = Array.from(source.matchAll(HEADER_PATTERN))
		.map((match) => ({
			lead: match[0].length,
			index: match.index as number,
			key: (match.groups?.key ?? '').trim()
		}))
		.sort((a, b) => a.index - b.index);

	const snippets: Record<string, string> = {};
	for (const [i, header] of headers.entries()) {
		const stop = i < headers.length - 1 ? headers[i + 1].index : source.length;
		let body = source.slice(header.index + header.lead, stop);
		const end = body.match(END_PATTERN);
		if (end != null) {
			body = body.slice(0, end.index);
		}
		snippets[header.key] = body;
	}
	return snippets;
}
