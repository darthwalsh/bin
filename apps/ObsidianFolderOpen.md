Context: for [vscode](https://code.visualstudio.com/) there is a `code` CLI command. `code somefile.txt` will open a file in a the best vscode window whose workspace contains that file, OR will open the file external to the workspace of some existing vscode window. `code someDir/` will open a new code window for this folder.

**Problem: Often from the CLI I want to open Obsidian for a MD file / folder but I have never created a vault in this project**

**TL;DR** - I re-implemented a bare-bones version of [Obsidian Everywhere](https://gitlab.com/BvdG/obsidian-everywhere) cross-platform: [[obslink.ps1]]

On my mac/PC, I'll have `~/notes` full of symlinks:
```
bin -> /Users/walshca/code/bin
Shared_Notes -> /Users/walshca/Library/CloudStorage/OneDrive-Personal/PixelShare/C_E/Shared_Notes/
MyNotes -> /Users/walshca/Library/CloudStorage/OneDrive-Personal/PixelShare/MyNotes/
OneDrive -> /Users/walshca/OneDrive - Work/notes
```

- [x] Try this on Windows PC

## Obsidian URI can't create vaults

https://help.obsidian.md/Concepts/Obsidian+URI

- [ ] add url param `paneType=tab&...` to open in new tab

> - `obsidian://open?vault=my%20vault`  
>     This opens the vault `my vault`. If the vault is already open, focus on the window.
> - `obsidian://open?vault=my%20vault&file=my%20note`  
>     This opens the note `my note.md` in the vault `my vault`, assuming the file exists.
> - `obsidian://open?path=%2Fhome%2Fuser%2Fmy%20vault%2Fpath%2Fto%2Fmy%20note`  
>     This will look for any vault that contains the path `/home/user/my vault/path/to/my note`. Then, the rest of the path is passed to the `file` parameter. For example, if a vault exists at `/home/user/my vault`, then this would be equivalent to `file` parameter set to `path/to/my note`.

Con: none of these can create a new vault

There's also Obsidian Advanced URI plugin, but it also doesn't seem to have a way to *create* a new vault:
https://vinzent03.github.io/obsidian-advanced-uri/actions/miscellaneous

- [ ] Seems to not work well in Windows
  - Command prompt keeps running, and CTRL+C quits the obsidian instance
  - check, maybe obisidian.exe is compiled as a console app instead of a Windowed app?
  - https://stackoverflow.com/q/66335217/771768 to launch in background?
  - maybe related: https://forum.obsidian.md/t/unexpected-results-with-obsidian-uri-at-windows-10-command-prompt/19124?u=darthwalsh
- [ ] See how this is implemented, and debug how it works 🔼 
	- [ ] https://yakitrak.github.io/obsidian-cli-docs/docs/install/windows
	- [ ] https://yakitrak.github.io/obsidian-cli-docs/docs/commands/open-note
	- [ ] https://github.com/Yakitrak/obsidian-cli/blob/848cb3a4c1559f5f846adaf1f301891b2f9fa426/pkg/actions/open.go#L22

## `obs` CLI can't create vaults
https://github.com/Yakitrak/obsidian-cli is pretty powerful!
> You are currently able to open, search, move, create, update and delete notes.

But: https://github.com/Yakitrak/obsidian-cli/issues/23#issuecomment-1750796695
> "obs ." to open the current directory
> This is not currently in scope of the tool as its purpose is to open vaults which are already recognise by Obsidian (the tool reads from the Obsidian config itself which stores vault path).

# [Obsidian Everywhere](https://gitlab.com/BvdG/obsidian-everywhere) solves the problem, for macOS
Good summary of the problem:
> The cross-platform application [Obsidian](https://obsidian.md/) is a tool for _Personal Knowledge Management_ (PKM): ordering your thoughts, gathering information, structuring varied knowledge. It uses [Markdown](https://spec.commonmark.org/current/) as the syntax for the content files. By happy accident, Obsidian (with the _Advanced Tables_ plugin) turns out to be a fantastic Markdown editor, and people like me would like to use it not just for PKM but as an editor for all Markdown files.
> 
> That is [not on the development agenda](https://forum.obsidian.md/t/have-obsidian-be-the-handler-of-md-files-add-ability-to-use-obsidian-as-a-markdown-editor-on-files-outside-vault-file-association/314) for the application. Obsidian is meant to limit itself to files inside its "vault", a folder on the user's computer. You can have more than one vault, but no files outside them can be opened.
> 
> This script is a workaround for that: it allows users to open all Markdown files in Obsidian. _**Disclaimer**_: like all workarounds, it is far from perfect and has many limitations. I hope that the ability to edit any file will eventually be added to Obsidian.

I'll copy some basic functionality into: [[obslink.ps1]]

I don't think I need the default-app association, because I can drop to the command line instead of figuring out getting both macOS/Windows to work like I want.

- [ ] Maybe ask BvdG to review changes in logic
# Feature Request threads
Opening markdown files that aren't an any Obsidian vault: https://forum.obsidian.md/t/open-and-edit-standalone-markdown-files/14977

CLI: https://forum.obsidian.md/t/command-line-interface-to-open-files-folders-in-obsidian-from-the-terminal/860
- best approach: https://gitlab.com/BvdG/obsidian-everywhere

File manager support too: https://forum.obsidian.md/t/open-folder-as-a-vault-like-vs-code-via-file-manager-and-terminal/46435

Default file association: https://forum.obsidian.md/t/have-obsidian-be-the-handler-of-md-files-add-ability-to-use-obsidian-as-a-markdown-editor-on-files-outside-vault-file-association/314/1
- Links to https://github.com/Chaoses-Ib/ObsidianShell for Windows: which either opens MD if in vault, or fallsback to default markdown editor: pretty good compromise
- Ditto for macOS: https://forum.obsidian.md/t/make-obsidian-a-default-app-for-markdown-files-on-macos/22260/12

## Will this work on mobile?
I'm not sure how making symlinks works on Android; will it work inside every normal place you'd store your Vault folder?
- [ ] Try https://android.stackexchange.com/a/203992/206137 to make symlink on #android 
