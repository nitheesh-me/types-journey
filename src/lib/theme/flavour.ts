import { browser } from '$app/environment';
import { writable } from 'svelte/store';

export const FLAVOURS = ['latte', 'frappe', 'macchiato', 'mocha', 'contrast'] as const;
export type Flavour = (typeof FLAVOURS)[number];

/** `null` means "follow the system", which is the default. */
export type FlavourChoice = Flavour | null;

export const FLAVOUR_LABELS: Record<Flavour, string> = {
	latte: 'Latte',
	frappe: 'Frappé',
	macchiato: 'Macchiato',
	mocha: 'Mocha',
	contrast: 'High contrast'
};

const STORAGE_KEY = 'catppuccin-flavour';

const asFlavour = (value: string | null): FlavourChoice =>
	FLAVOURS.includes(value as Flavour) ? (value as Flavour) : null;

function read(): FlavourChoice {
	if (!browser) return null;
	// `?flavour=mocha` wins, so a deck can be linked in a given flavour.
	const fromUrl = asFlavour(new URLSearchParams(location.search).get('flavour'));
	return fromUrl ?? asFlavour(localStorage.getItem(STORAGE_KEY));
}

function apply(choice: FlavourChoice) {
	if (!browser) return;
	if (choice) {
		document.documentElement.dataset.flavour = choice;
		localStorage.setItem(STORAGE_KEY, choice);
	} else {
		delete document.documentElement.dataset.flavour;
		localStorage.removeItem(STORAGE_KEY);
	}
}

export const flavour = writable<FlavourChoice>(read());

/** Call once from the root layout; keeps `<html data-flavour>` in step. */
export function initFlavour() {
	return flavour.subscribe(apply);
}
