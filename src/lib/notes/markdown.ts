import { marked } from 'marked';
import { renderMermaid } from '$lib/diagram/mermaid';

/**
 * Markdown for the slide notes panel, with ```mermaid fences rendered to SVG.
 * The mermaid instance is shared with `Diagram` on slides — see
 * `$lib/diagram/mermaid.ts`.
 */

const MERMAID_FENCE = /^```mermaid[^\n]*\n([\s\S]*?)^```[ \t]*$/gm;

function escapeHtml(value: string): string {
	return value.replace(
		/[&<>"']/g,
		(c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c] as string
	);
}

async function renderFence(source: string): Promise<string> {
	const result = await renderMermaid(source);
	return result.ok
		? `<figure class="diagram">${result.svg}</figure>`
		: `<pre class="diagram-error">Diagram failed to render:\n${escapeHtml(result.message)}</pre>`;
}

/**
 * Markdown to HTML. Mermaid fences are pulled out first so `marked` never
 * sees them, then spliced back in as rendered SVG.
 */
export async function renderNotes(source: string | undefined | null): Promise<string> {
	if (!source?.trim()) return '';

	const diagrams: Promise<string>[] = [];
	const withPlaceholders = source.replace(MERMAID_FENCE, (_match, code: string) => {
		diagrams.push(renderFence(code));
		return ` DIAGRAM${diagrams.length - 1} `;
	});

	let html = await marked.parse(withPlaceholders, { async: true });
	const rendered = await Promise.all(diagrams);
	rendered.forEach((svg, i) => {
		html = html.replace(`<p> DIAGRAM${i} </p>`, svg).replace(` DIAGRAM${i} `, svg);
	});
	return html;
}
