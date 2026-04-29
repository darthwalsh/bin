#ai-slop

## The Problem

Neither Windows Search nor SharePoint/OneDrive index the *contents* of `.md` files by default — only filenames. This is a repeated pattern across Microsoft products: both systems rely on registered file-type handlers (IFilters on Windows, crawl parsers in SharePoint) to extract text, and Markdown has no handler in either.

Discovered this when Windows Search couldn't find content inside `.md` notes; same limitation applies to OneDrive for Business / SharePoint Online. The workaround at the time: use [[Omnisearch]] plugin inside Obsidian instead of relying on OS/cloud search.

- [ ] Try Windows 11 search indexing of `.md` contents; windows team announced March 2026 that search would improve? #windows 🛫 2026-07-03
- [ ] Try a plugin for PowerToys Run search

## Why It Happens

**Windows Search**: indexes only file types with a registered [IFilter](https://en.wikipedia.org/wiki/IFilter) — a COM plugin that extracts text. `.md` has no built-in IFilter, so content is skipped. You can browse supported types at [Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/search/-search-3x-wds-included-in-index).

**SharePoint / Microsoft Graph**: similarly, Graph's content fetch reliably works for `.docx`, `.pdf`, `.txt`, `.pptx` — but returns empty for `.md`, `.org`, `.rst`. There's no tenant-level admin toggle to fix this; it's a platform limitation, not a permissions issue. Confirmed on [Stack Overflow](https://stackoverflow.com/questions/73855076/sharepoint-365-doesnt-search-by-content-markdown-files).

No amount of re-indexing or search schema changes will add Markdown parsing.

## Workarounds

### Windows Search
- **IFilter (best, if available)**: installing a third-party Markdown IFilter registers `.md` as a parseable type. No widely-shipped one exists yet.
- **Rename to `.txt`**: Windows indexes plain text natively. Loses Markdown rendering in Explorer.
- **Third-party search tools**: [Everything](https://www.voidtools.com/) or Agent Ransack build their own indexes and search `.md` content regardless of Windows Search. [Reddit discussion](https://www.reddit.com/r/ObsidianMD/comments/1mi8x4a).
- **[[Omnisearch]] plugin**: searches vault content inside Obsidian, bypassing OS indexing entirely.

### SharePoint / OneDrive for Business
- **Dual-file mirror** (`*.md` → `*.txt`): keep `.md` as source of truth, auto-generate `.txt` copies for SharePoint indexing. Automatable with Power Automate or a local sync script.

```python
# Mirror a folder tree, renaming .md → .txt so SharePoint indexes the content.
# Idempotent; preserves directory structure and file metadata.
from pathlib import Path
import shutil

def mirror_md_as_txt(src_root: str, dst_root: str) -> None:
    src_root = Path(src_root).expanduser().resolve()
    dst_root = Path(dst_root).expanduser().resolve()
    if not src_root.is_dir():
        raise ValueError(f"Source path is not a directory: {src_root}")
    for src_path in src_root.rglob("*"):
        if src_path.is_dir():
            continue
        rel_path = src_path.relative_to(src_root)
        if src_path.suffix.lower() == ".md":
            rel_path = rel_path.with_suffix(".txt")
        dst_path = dst_root / rel_path
        dst_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_path, dst_path)
```

Note: does not prune files deleted from source. Add mtime/hash check to skip unchanged files.

- **Store Markdown in Git instead**: GitHub / Azure DevOps Repos render and search Markdown natively. Use SharePoint only for summaries/exports.
- **Copilot for M365 / Syntex**: neither ingests `.md` content well as of early 2026 — same Graph limitation applies.

## Summary Table

| System | Problem | Admin fix? | Best workaround |
|---|---|---|---|
| Windows Search | No IFilter for `.md` | No | Everything / Omnisearch / rename `.txt` |
| SharePoint Search | No Markdown crawler | No | Mirror to `.txt` or use Git |
| Microsoft Graph | Empty fetch for `.md` | No | Convert to `.docx` / `.txt` |
