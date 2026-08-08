#!/usr/bin/env node
// Cross-checks each deck against its handout:
//   - every `key="..."` a slide asks for must exist in the handout (error)
//   - every `--- snippet` in the handout should appear on some slide (warning)
//   - every extra handout file should be shown by the deck (warning)
// Run with `npm run check:snippets`.
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const HANDOUTS = 'static/handout';
const SLIDES = 'src/routes/slides';
const HEADER = /^--- snippet (.*)$/gm;
const KEY = /\bkey="([^"]*)"/g;

let failures = 0;

const lectures = readdirSync(HANDOUTS, { withFileTypes: true })
	.filter((e) => e.isDirectory())
	.map((e) => e.name)
	.sort();

for (const slug of lectures) {
	const pagePath = join(SLIDES, slug, '+page.svelte');
	if (!existsSync(pagePath)) {
		console.log(`FAIL ${slug.padEnd(18)} handouts exist but there is no deck at ${pagePath}`);
		failures += 1;
		continue;
	}
	const page = readFileSync(pagePath, 'utf8');

	const files = readdirSync(join(HANDOUTS, slug))
		.filter((f) => f.endsWith('.lean'))
		.sort();

	// A snippet may live in any of the lecture's handout files.
	const defined = new Set();
	for (const f of files) {
		const source = readFileSync(join(HANDOUTS, slug, f), 'utf8');
		for (const m of source.matchAll(HEADER)) defined.add(m[1].trim());
	}
	const used = new Set(Array.from(page.matchAll(KEY), (m) => m[1]));

	const missing = [...used].filter((k) => !defined.has(k)).sort();
	const unused = [...defined].filter((k) => !used.has(k)).sort();

	// Every handout file is material the audience has in front of them, so the
	// deck has to actually reference it.
	const orphanFiles = files.filter((f) => !page.includes(`${slug}/${f}?raw`));

	const status = missing.length ? 'FAIL' : unused.length || orphanFiles.length ? 'warn' : 'ok';
	console.log(`${status.padEnd(4)} ${slug.padEnd(18)} ${defined.size} snippets, ${used.size} used`);
	for (const k of missing) console.log(`       on a slide but not in the handout: ${k}`);
	for (const k of unused) console.log(`       in the handout but on no slide:     ${k}`);
	for (const f of orphanFiles) console.log(`       handout file never shown:           ${f}`);
	if (missing.length) failures += missing.length;
}

process.exit(failures ? 1 : 0);
