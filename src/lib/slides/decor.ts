/**
 * Per-slide decorations that are drawn *outside* the deck.
 *
 * The character and the notes panel used to render inside their slide with
 * `position: fixed`. That resolves against reveal's transformed `.slides` box
 * rather than the viewport, which meant a "closed" panel was only pushed out
 * of the 960px slide box and stayed visible in the margin beside it, and a
 * percentage-height sprite jumped when reveal applied its transform.
 *
 * So the slide only *registers* what it wants drawn, keyed by its own
 * `<section>`, and the deck layout renders one of each against the viewport.
 */
import { writable } from 'svelte/store';

export type SpriteDecor = {
	/** File stem under /sprite, e.g. `programmer-right`. */
	file: string;
	ratio: number;
	side: 'left' | 'right';
	accent: string;
	alt: string;
};

export type NotesDecor = {
	notes: string;
	presenter: string;
};

const sprites = new Map<Element, SpriteDecor>();
const notes = new Map<Element, NotesDecor>();

export const currentSprite = writable<SpriteDecor | null>(null);
export const currentNotes = writable<NotesDecor | null>(null);

/** The slide the deck is showing, so late registrations can catch up. */
let activeSlide: Element | null = null;

export function showFor(slide: Element | null | undefined) {
	activeSlide = slide ?? null;
	currentSprite.set(activeSlide ? (sprites.get(activeSlide) ?? null) : null);
	currentNotes.set(activeSlide ? (notes.get(activeSlide) ?? null) : null);
}

function refresh(slide: Element) {
	// A component may mount after the deck is ready (or its props may change);
	// if it belongs to the slide on screen, publish it straight away.
	if (slide === activeSlide) showFor(slide);
}

export function registerSprite(slide: Element, decor: SpriteDecor) {
	sprites.set(slide, decor);
	refresh(slide);
}

export function registerNotes(slide: Element, decor: NotesDecor) {
	notes.set(slide, decor);
	refresh(slide);
}

export function unregister(slide: Element) {
	sprites.delete(slide);
	notes.delete(slide);
}

/** The `<section>` a component sits in — the unit reveal calls a slide. */
export function slideOf(node: Element | null): Element | null {
	return node?.closest('section') ?? null;
}
