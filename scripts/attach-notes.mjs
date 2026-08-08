#!/usr/bin/env node
/**
 * Inserts `<SlideNotes {...note('Key')} />` into the slides of a deck whose
 * heading matches a key in that deck's notes.md.
 *
 * Keys match the slide's first heading with tags stripped, so a note keyed
 * "If-Else" attaches to every slide headed `<h3>If-Else</h3>`. Several slides
 * often share a heading; to single one out, key the note `Heading#2` for the
 * second such slide — that beats a bare key on the slide it names.
 *
 * Slides that already carry a SlideNotes are left alone, so re-running is safe.
 *
 *   node scripts/attach-notes.mjs fp-control [...more decks]
 */
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

// Matches both `<Section>…</Section>` on one line and spread over many.
const SECTION = /([ \t]*)<Section\b[^>]*>([\s\S]*?)<\/Section>/g;
const HEADING = /<h[2-6][^>]*>([\s\S]*?)<\/h[2-6]>/;
const NOTE_KEY = /^--- note (.*)$/gm;

const plain = (html) =>
	html
		.replace(/<[^>]+>/g, '')
		.replace(/\{title\}/g, '')
		.replace(/\s+/g, ' ')
		.trim();

let total = 0;
for (const slug of process.argv.slice(2)) {
	const dir = join('src/routes/slides', slug);
	const pagePath = join(dir, '+page.svelte');
	const notesPath = join(dir, 'notes.md');
	if (!existsSync(pagePath) || !existsSync(notesPath)) {
		console.log(`skip ${slug}: needs both +page.svelte and notes.md`);
		continue;
	}

	let page = readFileSync(pagePath, 'utf8');
	const keys = new Set(
		Array.from(readFileSync(notesPath, 'utf8').matchAll(NOTE_KEY), (m) => m[1].trim())
	);

	const used = new Set();
	const already = new Set(); // attached by a previous run
	const seen = new Map(); // heading -> how many slides with it so far
	page = page.replace(SECTION, (match, indent, body) => {
		// Record existing attachments before the heading check: a slide can carry
		// notes without a heading (the Manual's note slides are just a callout).
		const existing = body.match(/note\((['"])(.*?)\1\)/);
		if (existing) already.add(existing[2]);

		const heading = body.match(HEADING);
		if (!heading) return match;

		const name = plain(heading[1]);
		const nth = (seen.get(name) ?? 0) + 1;
		seen.set(name, nth);
		// Already wired up on an earlier run; leave it alone.
		if (body.includes('<SlideNotes')) return match;

		// An explicit `Heading#n` wins over the bare heading.
		const key = keys.has(`${name}#${nth}`) ? `${name}#${nth}` : keys.has(name) ? name : null;
		if (!key) return match;
		used.add(key);

		// Keys are prose and can contain apostrophes.
		const quoted = JSON.stringify(key);
		const line = `${indent}\t<SlideNotes {...note(${quoted})} />`;
		return match.endsWith('\n' + indent + '</Section>')
			? match.replace(/\n[ \t]*<\/Section>$/, `\n${line}\n${indent}</Section>`)
			: // single-line slide: expand it so the note sits on its own line
				`${indent}<Section>\n${indent}\t${body.trim()}\n${line}\n${indent}</Section>`;
	});

	if (!page.includes("from '$lib/notes/SlideNotes.svelte'")) {
		page = page
			.replace(
				/(\n\timport \{ parseSnippets \} from '\$lib\/slides\/snippets';)/,
				`\n\timport SlideNotes from '$lib/notes/SlideNotes.svelte';` +
					`\n\timport { noteLookup } from '$lib/notes/parse';$1`
			)
			// Decks name their handout imports differently; hang the notes import
			// off the first `?raw` one.
			.replace(
				/(\n\timport \w+ from '[^']*\?raw';)/,
				`$1\n\timport NotesSource from './notes.md?raw';`
			)
			// Decks name their snippet maps differently; hang the lookup off the
			// first `parseSnippets` call, whatever it is assigned to.
			.replace(
				/(\n\tconst \w+ = parseSnippets\([^)]*\);)/,
				`$1\n\tconst note = noteLookup(NotesSource);`
			);
	}

	writeFileSync(pagePath, page);
	const missed = [...keys].filter((k) => !used.has(k) && !already.has(k)).sort();
	total += used.size;
	console.log(
		`${slug}: attached ${used.size}, already wired ${already.size}, of ${keys.size} keys`
	);
	for (const k of missed) console.log(`   no slide headed: ${k}`);
}
console.log(`\ntotal attached: ${total}`);
