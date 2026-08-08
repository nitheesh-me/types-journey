/**
 * Per-deck notes files, so notes live beside each other rather than being
 * scattered through the deck markup:
 *
 *     --- note If-Else
 *     Markdown for the "Notes" tab.
 *     --- presenter
 *     Markdown for the "Presenter" tab.
 *     --- note Match
 *     ...
 */
export type SlideNote = { notes: string; presenter: string };

const NOTE_HEADER = /^--- note (.*)$/gm;
const PRESENTER_HEADER = /^--- presenter[ \t]*$/m;

export function parseNotes(source: string): Record<string, SlideNote> {
	const headers = Array.from(source.matchAll(NOTE_HEADER)).map((m) => ({
		key: m[1].trim(),
		index: m.index as number,
		lead: m[0].length + 1
	}));

	const out: Record<string, SlideNote> = {};
	for (const [i, header] of headers.entries()) {
		const stop = i < headers.length - 1 ? headers[i + 1].index : source.length;
		const body = source.slice(header.index + header.lead, stop);
		const split = body.match(PRESENTER_HEADER);
		out[header.key] = split
			? {
					notes: body.slice(0, split.index).trim(),
					presenter: body.slice((split.index as number) + split[0].length).trim()
				}
			: { notes: body.trim(), presenter: '' };
	}
	return out;
}

/** Lookup that never returns undefined, so a missing key just shows empty. */
export function noteLookup(source: string) {
	const notes = parseNotes(source);
	return (key: string): SlideNote => notes[key] ?? { notes: '', presenter: '' };
}
