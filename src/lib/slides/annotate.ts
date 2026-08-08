/**
 * Draws the bracket-and-arrow that connects an `<Annotation target="...">`
 * label to the `\htmlId{...}{...}` group it names inside a KaTeX formula.
 *
 * This has to run after KaTeX has laid the formula out, so the layout calls it
 * on `ready` and on every `slidetransitionend`. Slides that have already been
 * annotated are marked and skipped.
 */
const SVG_NS = 'http://www.w3.org/2000/svg';
const ROOT_CLASS = 'visualizer-annotation';
const DONE_CLASS = 'visualizer-has-annotation';

export type AnnotationConfig = {
	/** Put the label under the target rather than above it. */
	below: boolean;
	/** Grow the label to the left of the target rather than to the right. */
	left: boolean;
	color: string;
	strokeWidth: number;
	/** Height of the vertical leg running from the target to the label. */
	extension: number;
	verticalPad: number;
	arrowHeight: number;
};

const DEFAULTS: AnnotationConfig = {
	below: false,
	left: true,
	color: 'var(--ctp-teal)',
	strokeWidth: 4,
	extension: 50,
	verticalPad: 5,
	arrowHeight: 8
};

let markerSerial = 0;

class AnnotationVisualizer {
	private readonly root: HTMLDivElement;
	private readonly svg: SVGSVGElement;

	constructor(
		private readonly target: HTMLElement,
		private readonly label: HTMLElement,
		private readonly config: AnnotationConfig
	) {
		this.root = document.createElement('div');
		this.svg = document.createElementNS(SVG_NS, 'svg');
		this.svg.style.position = 'absolute';
		this.label.style.position = 'absolute';

		if (this.target.parentElement) {
			this.svg.style.overflow = 'visible';
			this.svg.style.zIndex = '10';
			this.target.insertAdjacentElement('afterbegin', this.root);
		}

		this.drawArrow();

		this.root.style.position = 'relative';
		this.root.classList.add(ROOT_CLASS);
		this.root.appendChild(this.svg);
		this.root.appendChild(this.label);
	}

	/** Position everything relative to the (now laid out) target. */
	show() {
		const { color, below, left, extension, verticalPad, arrowHeight, strokeWidth } = this.config;

		this.target.style.background = `color-mix(in srgb, ${color}, transparent 70%)`;
		this.target.style.display = 'inline-block';
		this.svg.style.display = 'inline-block';
		this.svg.style.position = 'absolute';
		this.label.style.color = color;
		this.label.style.position = 'absolute';

		if (below) {
			this.svg.style.top = `${this.target.offsetHeight + arrowHeight / 2}px`;
			this.label.style.top = `${this.target.offsetHeight + extension + verticalPad}px`;
		} else {
			this.svg.style.top = `${-arrowHeight / 2}px`;
			this.label.style.bottom = `${strokeWidth + extension + verticalPad}px`;
		}

		if (left) {
			this.label.style.right = `${this.target.offsetWidth / 2}px`;
		} else {
			this.label.style.left = `${this.target.offsetWidth / 2}px`;
		}
	}

	private drawArrow() {
		const { color, extension, strokeWidth } = this.config;
		const signX = this.config.left ? -1 : 1;
		const signY = this.config.below ? 1 : -1;

		// Each annotation needs its own marker: `url(#id)` resolves document
		// wide, so a shared id would paint every arrowhead the first one's colour.
		const markerId = `annotation-head-${markerSerial++}`;

		const defs = document.createElementNS(SVG_NS, 'defs');
		const marker = document.createElementNS(SVG_NS, 'marker');
		marker.setAttribute('id', markerId);
		marker.setAttribute('orient', 'auto');
		marker.setAttribute('markerWidth', '3');
		marker.setAttribute('markerHeight', '4');
		marker.setAttribute('refX', '1');
		marker.setAttribute('refY', '2');

		const head = document.createElementNS(SVG_NS, 'path');
		head.setAttribute('d', 'M0,0 V4 L2,2 Z');
		// These live inside `.katex`, whose stylesheet sets `stroke`/`fill` on
		// `svg path`. A CSS rule beats a presentation attribute, so paint
		// inline or the connectors come out invisible.
		head.style.fill = color;
		marker.appendChild(head);
		defs.appendChild(marker);
		this.svg.appendChild(defs);

		// Along the label, then down the leg, then into the target.
		const labelWidth = this.label.offsetWidth;
		const path = document.createElementNS(SVG_NS, 'path');
		path.setAttribute(
			'd',
			`M${signX * labelWidth},${signY * extension} 0,${signY * extension} 0,0`
		);
		path.setAttribute('marker-end', `url(#${markerId})`);
		path.style.fill = 'none';
		path.style.stroke = color;
		path.style.strokeWidth = `${strokeWidth}`;
		this.svg.appendChild(path);
	}
}

/**
 * Draws every annotation on `slide` whose target is already in the DOM.
 * Returns how many are still waiting for one — KaTeX loads from a CDN and
 * typesets after `ready`, so the targets often do not exist on the first call.
 */
export function drawAnnotations(slide: Element | null | undefined): number {
	if (!slide) return 0;

	let pending = 0;
	for (const label of Array.from(slide.getElementsByClassName('annotation'))) {
		const targetId = label.getAttribute('data-target');
		if (!targetId) continue;

		const target = document.getElementById(targetId);
		if (target == null) {
			pending += 1;
			continue;
		}
		if (target.classList.contains(DONE_CLASS)) continue;

		const visualizer = new AnnotationVisualizer(target, label as HTMLElement, {
			...DEFAULTS,
			below: label.hasAttribute('data-below'),
			left: label.hasAttribute('data-left'),
			color: label.getAttribute('data-color') || 'currentColor'
		});
		target.classList.add(DONE_CLASS);
		visualizer.show();
	}
	return pending;
}

/**
 * Draws the slide's annotations, retrying until its formulas have been
 * typeset (or `timeoutMs` elapses). Cheap on slides with no annotations:
 * the first call reports nothing pending and no retry is scheduled.
 */
export function annotateWhenReady(slide: Element | null | undefined, timeoutMs = 5000) {
	const deadline = Date.now() + timeoutMs;
	const attempt = () => {
		if (drawAnnotations(slide) > 0 && Date.now() < deadline) {
			requestAnimationFrame(attempt);
		}
	};
	attempt();
}
