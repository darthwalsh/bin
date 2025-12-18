// ==UserScript==
// @name         Add-to-Album Hotkeys (for Google Photos)
// @namespace    https://github.com/darthwalsh/bin
// @version      1.1.0
// @description  Keyboard shortcuts to quickly add photos to albums in Google Photos (unofficial)
// @author       Carl Walsh
// @match        https://photos.google.com/*
// @homepageURL  https://github.com/darthwalsh/bin
// @supportURL   https://github.com/darthwalsh/bin/issues
// @updateURL    https://raw.githubusercontent.com/darthwalsh/bin/main/AddToAlbumHotkeys.user.js
// @downloadURL  https://raw.githubusercontent.com/darthwalsh/bin/main/AddToAlbumHotkeys.user.js
// @grant        GM_getValue
// @grant        GM_setValue
// ==/UserScript==

/*
#ai-slop -- I read over every line of gpt-5.1-codex-max output, but didn't refactor the code much.

One-keystroke album add: numbers map to album names via user-configured shortcuts.

This automates: press [1] key → clicks "Create or add to album" → chooses "Album" → types album name → clicks best match.

One risk: DOM selectors are brittle; if Google changes aria-labels, update the selectors inside addToAlbum.

After developing, run smoke test: select photos, press mapped key, confirm album toast; verify missing-album error logs in console.
*/

'use strict';

const STORAGE_KEY = 'AddToAlbum.shortcuts';
const MAX_MAPPINGS = 50;
let albumShortcuts = {};
const legendRoot = document.createElement('div');

legendRoot.style.display = 'flex';
legendRoot.style.alignItems = 'center';
legendRoot.style.gap = '8px';
legendRoot.style.padding = '6px 8px';
legendRoot.style.border = '1px solid rgba(255,255,255,0.2)';
legendRoot.style.borderRadius = '8px';
legendRoot.style.background = 'rgba(0,0,0,0.55)';
legendRoot.style.color = '#fff';
legendRoot.style.fontSize = '12px';
legendRoot.style.lineHeight = '1.4';
legendRoot.style.flexWrap = 'wrap';
legendRoot.style.alignSelf = 'flex-start';
legendRoot.style.marginTop = '6px';
legendRoot.style.maxWidth = '100%';

console.debug('[AddToAlbum] Script loaded');

init().catch(err => console.error('[AddToAlbum] Init failed', err));

async function init() {
  albumShortcuts = await loadShortcuts();
  console.debug('[AddToAlbum] Shortcuts loaded:', albumShortcuts);
  renderLegend();
  attachSelectionObserver();
}

async function loadShortcuts() {
  try {
    const stored = await Promise.resolve(GM_getValue(STORAGE_KEY, {}));
    return normalizeMapping(stored);
  } catch (err) {
    console.warn('[AddToAlbum] Failed to load shortcuts from storage; using empty set', err);
    return {};
  }
}

async function saveShortcuts(nextMap) {
  await Promise.resolve(GM_setValue(STORAGE_KEY, nextMap));
}

function normalizeMapping(raw) {
  const output = {};
  if (!raw || typeof raw !== 'object') {
    return output;
  }
  for (const [key, value] of Object.entries(raw)) {
    const k = String(key).trim();
    const v = typeof value === 'string' ? value.trim() : '';
    if (!k || !v) continue;
    output[k] = v;
    if (Object.keys(output).length >= MAX_MAPPINGS) break;
  }
  return output;
}

function parseMappingText(text) {
  const lines = text.split('\n');
  const parsed = {};
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const firstSpace = trimmed.indexOf(' ');
    if (firstSpace <= 0) {
      throw new Error(`Invalid line (expected "key name"): "${trimmed}"`);
    }
    const key = trimmed.slice(0, firstSpace).trim();
    const name = trimmed.slice(firstSpace + 1).trim();
    if (!key || !name) {
      throw new Error(`Invalid line (missing key or name): "${trimmed}"`);
    }
    parsed[key] = name;
    if (Object.keys(parsed).length > MAX_MAPPINGS) {
      throw new Error(`Too many mappings; max ${MAX_MAPPINGS}`);
    }
  }
  return parsed;
}

function createButton(label, onClick) {
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.textContent = label;
  Object.assign(btn.style, {
    padding: '4px 8px',
    borderRadius: '6px',
    border: '1px solid rgba(255,255,255,0.35)',
    background: 'rgba(255,255,255,0.12)',
    color: '#fff',
    cursor: 'pointer',
    fontSize: '12px'
  });
  btn.addEventListener('click', onClick);
  return btn;
}

function renderLegend() {
  legendRoot.replaceChildren();
  const count = Object.keys(albumShortcuts).length;

  const summary = document.createElement('span');
  summary.textContent = `${count} mapping${count === 1 ? '' : 's'}`;
  legendRoot.appendChild(summary);

  const editBtn = createButton('Edit shortcuts', openEditor);
  legendRoot.appendChild(editBtn);

  if (count === 0) {
    const hint = document.createElement('span');
    hint.textContent = 'Add entries like: 1 LifeAtADSK';
    hint.style.opacity = '0.8';
    legendRoot.appendChild(hint);
    return;
  }

  const list = document.createElement('div');
  list.style.display = 'flex';
  list.style.flexWrap = 'wrap';
  list.style.gap = '6px';

  for (const [key, name] of Object.entries(albumShortcuts)) {
    const pill = document.createElement('span');
    pill.textContent = `[${key}]: ${name}`;
    pill.style.padding = '2px 6px';
    pill.style.borderRadius = '6px';
    pill.style.background = 'rgba(255,255,255,0.1)';
    pill.style.border = '1px solid rgba(255,255,255,0.2)';
    list.appendChild(pill);
  }

  legendRoot.appendChild(list);
}

function findSelectionToolbar() {
  return document.querySelector('[jscontroller="Z3H37c"]');
}

function ensureLegendMounted() {
  const toolbar = findSelectionToolbar();
  if (!toolbar) {
    return;
  }

  const container = toolbar.querySelector('.c9yG5b') || toolbar;
  if (legendRoot.parentElement !== container) {
    legendRoot.remove();
    container.appendChild(legendRoot);
  }
}

function attachSelectionObserver() {
  const observer = new MutationObserver(() => {
    ensureLegendMounted();
    if (legendRoot.parentElement) {
      observer.disconnect();
    }
  });
  observer.observe(document.body, { childList: true, subtree: true });
  ensureLegendMounted();
  if (legendRoot.parentElement) {
    observer.disconnect();
  }
}

function openEditor() {
  if (document.getElementById('gph-editor-overlay')) {
    return;
  }

  const overlay = document.createElement('div');
  overlay.id = 'gph-editor-overlay';
  Object.assign(overlay.style, {
    position: 'fixed',
    inset: '0',
    background: 'rgba(0,0,0,0.65)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 999999
  });

  const panel = document.createElement('div');
  Object.assign(panel.style, {
    background: '#121212',
    color: '#fff',
    padding: '16px',
    borderRadius: '10px',
    width: 'min(480px, 90vw)',
    boxShadow: '0 6px 30px rgba(0,0,0,0.35)',
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
    border: '1px solid rgba(255,255,255,0.12)'
  });

  const title = document.createElement('div');
  title.textContent = 'Edit album shortcuts (one per line: key albumName)';
  title.style.fontWeight = '600';
  panel.appendChild(title);

  const textarea = document.createElement('textarea');
  const existing = Object.entries(albumShortcuts)
    .map(([k, v]) => `${k} ${v}`)
    .join('\n');
  const template = '1 YourFirstAlbum\n2 Another';
  textarea.value = existing || template;
  Object.assign(textarea.style, {
    minHeight: '180px',
    width: '100%',
    background: '#1e1e1e',
    color: '#fff',
    border: '1px solid rgba(255,255,255,0.2)',
    borderRadius: '8px',
    padding: '10px',
    fontSize: '13px',
    fontFamily: 'monospace'
  });
  panel.appendChild(textarea);

  const errorRow = document.createElement('div');
  errorRow.style.color = '#ffb3b3';
  errorRow.style.minHeight = '18px';
  errorRow.style.fontSize = '12px';
  panel.appendChild(errorRow);

  const actions = document.createElement('div');
  actions.style.display = 'flex';
  actions.style.gap = '8px';
  actions.style.justifyContent = 'flex-end';

  const cancelBtn = createButton('Cancel', () => overlay.remove());
  const saveBtn = createButton('Save', async () => {
    try {
      const parsed = parseMappingText(textarea.value);
      albumShortcuts = parsed;
      await saveShortcuts(albumShortcuts);
      renderLegend();
      ensureLegendMounted();
      overlay.remove();
    } catch (err) {
      errorRow.textContent = err instanceof Error ? err.message : String(err);
    }
  });

  actions.append(cancelBtn, saveBtn);
  panel.appendChild(actions);

  overlay.appendChild(panel);
  document.body.appendChild(overlay);
}

document.addEventListener('keydown', async e => {
  const isTyping = e.target.tagName === 'INPUT' ||
                   e.target.tagName === 'TEXTAREA' ||
                   e.target.isContentEditable;
  
  if (isTyping) {
    console.debug('[AddToAlbum] Ignoring keydown - user is typing in', e.target.tagName);
    return;
  }

  if (!albumShortcuts || Object.keys(albumShortcuts).length === 0) {
    return;
  }

  console.debug('[AddToAlbum] Key pressed:', e.key, 'Shift:', e.shiftKey);

  const albumName = albumShortcuts[e.key];
  if (albumName) {
    console.log(`[AddToAlbum] Triggering: Add to "${albumName}"`);
    try {
      await addToAlbum(albumName);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      showToast(`Album add failed: ${message}`, err);
    }
    e.preventDefault();
  }
  // Don't implement SHIFT+A for archive: it's built in to Google Photos
});

function showToast(message, err) {
  console.error(`[AddToAlbum] ${message}`, err || '');
  
  const toast = document.createElement('div');
  toast.textContent = message;
  Object.assign(toast.style, {
    position: 'fixed',
    left: '0',
    bottom: '0',
    width: '100%',
    height: '25vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    textAlign: 'center',
    padding: '24px',
    boxSizing: 'border-box',
    background: '#ff2d55',
    color: '#0b0b0b',
    fontSize: '18px',
    fontWeight: '600',
    zIndex: 999999,
    pointerEvents: 'none'
  });
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}

async function waitForElement(selector, timeout = 5000) {
  console.debug('[AddToAlbum] Waiting for element:', selector);
  const startTime = Date.now();
  while (Date.now() - startTime < timeout) {
    const element = document.querySelector(selector);
    if (element) {
      console.debug('[AddToAlbum] Element found:', selector);
      return element;
    }
    await new Promise(r => setTimeout(r, 100));
  }
  console.warn('[AddToAlbum] Element not found within timeout:', selector);
  return null;
}

async function pollUntil(conditionFn, checkInterval = 10, timeout = 5000) {
  return new Promise((resolve, reject) => {
    const intervalId = setInterval(() => {
      const result = conditionFn();
      if (result) {
        clearInterval(intervalId);
        clearTimeout(timeoutId);
        resolve(result);
      }
    }, checkInterval);

    const timeoutId = setTimeout(() => {
      clearInterval(intervalId);
      reject(new Error('Polling timeout'));
    }, timeout);
  });
}

async function addToAlbum(albumName) {
  console.debug('[AddToAlbum] addToAlbum called with:', albumName);
  
  console.debug('[AddToAlbum] Step 1: Looking for "Add to album" button');
  const btn = await waitForElement('[aria-label="Create or add to album"]');
  if (!btn) {
    showToast('No "Add to album" button. Are photos selected?');
    throw new Error('"Add to album" button missing');
  }
  console.debug('[AddToAlbum] Step 1: Clicking "Add to album" button');
  btn.click();

  console.debug('[AddToAlbum] Step 2: Waiting for menu and clicking "Album" item');
  const albumMenuItem = await pollUntil(() => {
    return document.querySelector('[role="menuitem"][aria-label="Album"]');
  }).catch(err => {
    showToast('Album menu did not appear', err);
    throw err;
  });
  console.debug('[AddToAlbum] Step 2: Clicking "Album" menu item');
  albumMenuItem.click();
  
  console.debug('[AddToAlbum] Step 3: Waiting for album search input');
  const input = await pollUntil(() => {
    const allInputs = Array.from(document.querySelectorAll('input[type="text"], input[placeholder]'));
    const found = allInputs.find(inp => {
      const placeholder = inp.getAttribute('placeholder')?.toLowerCase() || '';
      return placeholder.includes('search or create') || placeholder.includes('album');
    });
    return found || null;
  }).catch(err => {
    showToast('Album search input not found', err);
    throw err;
  });
  console.debug('[AddToAlbum] Step 3: Found input, placeholder:', input.getAttribute('placeholder'));
  input.focus();
  input.value = albumName;
  input.dispatchEvent(new Event('input', { bubbles: true }));
  input.dispatchEvent(new Event('change', { bubbles: true }));
  
  console.debug('[AddToAlbum] Step 4: Waiting for album options');
  const options = await pollUntil(() => {
    const opts = Array.from(document.querySelectorAll('[role="option"]'));
    return opts.length > 0 ? opts : null;
  }).catch(err => {
    showToast('Album options did not load', err);
    throw err;
  });
  console.debug('[AddToAlbum] Step 4: Found', options.length, 'options');
  
  const option = options.find(o => {
    const text = o.textContent.trim();
    const matches = text === albumName || text.includes(albumName);
    if (matches) {
      console.debug('[AddToAlbum] Step 4: Matched option with text:', text);
    }
    return matches;
  });
  
  if (!option) {
    showToast(`Album not found: ${albumName}`);
    throw new Error('Album option not found');
  }
  
  console.debug('[AddToAlbum] Step 4: Clicking album option');
  option.click();
  
  console.debug('[AddToAlbum] Step 5: Checking for Done button (shouldnt exist');
  try {
    await pollUntil(() => {
      return document.querySelector('div[role="button"][aria-label="Done"], button[aria-label="Done"]');
    }, 3, 10);
    console.warn('[AddToAlbum] Step 5: Done button found, but clicking Done / pressing Enter is not implemented');
  } catch (error) {
    // Done button not found, which is expected
  }
  
  console.log('[AddToAlbum] addToAlbum completed for:', albumName);
}
