/**
 * Mermaid, themed from the live Catppuccin variables so diagrams change
 * flavour with everything else. Shared by the notes panel and by `Diagram`
 * on a slide; imported lazily, because mermaid is large and most decks never
 * draw one.
 */

function ctp(name: string): string {
	return getComputedStyle(document.documentElement).getPropertyValue(`--ctp-${name}`).trim();
}

let mermaidPromise: Promise<typeof import('mermaid').default> | null = null;
/** The flavour the loaded mermaid was themed for. */
let themedFor: string | null = null;

async function getMermaid() {
	if (!mermaidPromise) {
		mermaidPromise = import('mermaid').then((m) => m.default);
	}
	const mermaid = await mermaidPromise;

	const flavour = document.documentElement.dataset.flavour ?? 'auto';
	if (themedFor !== flavour) {
		mermaid.initialize({
			startOnLoad: false,
			securityLevel: 'loose',
			// A concrete font: mermaid measures label widths at render time, and
			// `inherit` resolves against the document rather than the container.
			fontFamily: 'system-ui, sans-serif',
			theme: 'base',
			flowchart: { useMaxWidth: true, htmlLabels: true, padding: 8 },
			themeVariables: {
				background: ctp('mantle'),
				primaryColor: ctp('surface0'),
				primaryTextColor: ctp('text'),
				primaryBorderColor: ctp('mauve'),
				secondaryColor: ctp('surface1'),
				tertiaryColor: ctp('surface2'),
				lineColor: ctp('overlay1'),
				textColor: ctp('text'),
				noteBkgColor: ctp('surface0'),
				noteTextColor: ctp('text'),
				noteBorderColor: ctp('lavender'),
				mainBkg: ctp('surface0'),
				nodeBorder: ctp('mauve'),
				clusterBkg: ctp('mantle'),
				clusterBorder: ctp('surface2'),
				edgeLabelBackground: ctp('mantle')
			}
		});
		themedFor = flavour;
	}
	return mermaid;
}

let serial = 0;

export type MermaidResult = { ok: true; svg: string } | { ok: false; message: string };

async function render(source: string): Promise<MermaidResult> {
	try {
		const mermaid = await getMermaid();
		const { svg } = await mermaid.render(`mermaid-${serial++}`, source.trim());
		return { ok: true, svg };
	} catch (error) {
		return { ok: false, message: error instanceof Error ? error.message : String(error) };
	}
}

/*
 * `mermaid.render` keeps global state and a shared scratch element, so
 * concurrent calls interfere with each other — a deck that mounts ten
 * diagrams at once ends up with ten empty figures. Renders are queued.
 */
let queue: Promise<unknown> = Promise.resolve();

/** Renders one mermaid source. Never throws — a bad diagram reports itself. */
export function renderMermaid(source: string): Promise<MermaidResult> {
	const result = queue.then(() => render(source));
	queue = result.catch(() => undefined);
	return result;
}
