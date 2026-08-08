import { browser } from '$app/environment';
import { writable } from 'svelte/store';

export type NotesTab = 'notes' | 'presenter';

/*
 * The parameter is `panel`, not `notes`: reveal.js's own notes plugin opens
 * its speaker window when it finds `notes` anywhere in the query string, and
 * a blocked popup there throws before the deck finishes initialising.
 */
const panel = browser ? new URLSearchParams(location.search).get('panel') : null;

/**
 * Whether the side panel is showing. Shared by every slide's panel.
 * `?panel=notes` or `?panel=presenter` opens it on load, so a slide can be
 * linked with its notes already up.
 */
export const notesOpen = writable(panel === 'notes' || panel === 'presenter');

/** Which of the two markdown bodies is on top. */
export const notesTab = writable<NotesTab>(panel === 'presenter' ? 'presenter' : 'notes');
