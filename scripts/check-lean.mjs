#!/usr/bin/env node
/**
 * Compiles every handout with the Lean toolchain, so a snippet on a slide is
 * known to be code that actually works rather than code that looks right.
 *
 * Errors fail; deprecation warnings are reported, since a handout the audience
 * runs should not spew them.
 *
 *   npm run check:lean [-- <lecture>...]
 */

/*
 * Only some handouts are whole programs. The CS99 ones are snippet sources
 * for slides: they declare the same name twice (`Vec2`, `Bad`), include
 * examples that are *meant* to fail (strict positivity, `throw`), and in the
 * Manual deck's case are not Lean at all. Compiling them is informative, so
 * they are still reported — but a failure there is upstream's shape, not a
 * regression, and must not fail the check.
 */
const ENFORCED = new Set(['introduction', 'should-i-learn-lean']);
import { execFile } from 'node:child_process';
import { readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { promisify } from 'node:util';

const run = promisify(execFile);
const HANDOUTS = 'static/handout';

const only = process.argv.slice(2);
const lectures = readdirSync(HANDOUTS, { withFileTypes: true })
	.filter((e) => e.isDirectory())
	.map((e) => e.name)
	.filter((name) => only.length === 0 || only.includes(name))
	.sort();

try {
	await run('lean', ['--version']);
} catch {
	console.log('lean not on PATH — skipping (install a toolchain with elan)');
	process.exit(0);
}

let failures = 0;
for (const lecture of lectures) {
	const dir = join(HANDOUTS, lecture);
	const files = readdirSync(dir)
		.filter((f) => f.endsWith('.lean'))
		.sort();

	for (const file of files) {
		const path = join(dir, file);
		let output = '';
		let ok = true;
		try {
			const { stdout, stderr } = await run('lean', [path], {
				maxBuffer: 32 * 1024 * 1024,
				timeout: 15 * 60 * 1000
			});
			output = stdout + stderr;
		} catch (error) {
			ok = false;
			output = `${error.stdout ?? ''}${error.stderr ?? ''}`;
		}

		const errors = output.split('\n').filter((l) => l.includes('error:'));
		const warnings = output.split('\n').filter((l) => l.includes('warning:'));
		const clean = ok && errors.length === 0;
		const enforced = ENFORCED.has(lecture);
		const status = clean ? (warnings.length ? 'warn' : 'ok') : enforced ? 'FAIL' : 'note';

		console.log(
			`${status.padEnd(4)} ${`${lecture}/${file}`.padEnd(34)} ` +
				`${errors.length} errors, ${warnings.length} warnings` +
				(enforced ? '' : '   (snippet source, not enforced)')
		);
		for (const line of errors.slice(0, 5)) console.log(`       ${line.trim()}`);
		for (const line of warnings.slice(0, 3)) console.log(`       ${line.trim()}`);
		if (status === 'FAIL') failures += 1;
	}
}

process.exit(failures ? 1 : 0);
