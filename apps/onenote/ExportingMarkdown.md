I'm working on exporting the majority of my OneNote to Markdown. This is the summary of this process, and the problems I ran into.

- [ ] Create branch in https://github.com/darthwalsh/diff-onenote-export for my preferred markdown style, maybe checking with some [linter](markdown.linter.md)
  - [ ] Then create more github issues or linter fixes fir diffs
- [x] Try using Obsidian [obsidian-importer](https://github.com/p3rid0t/obsidian-importer) community plugin, update section below
- [x] Export Sharable OneNote notebook, and DOCX, generated MD, and expected MD to different branches of github repo like [PastebinForDiffs](../PastebinForDiffs.md)
	- See Special OneNote Formatting below

## Technology solutions

### Just Copy-Pasting content from each page
In a pinch you can always copy-paste content from each OneNote page. One of the best paste-rich-format-into-markdown tools I have found is Obsidian. Here is the result of pasting some formatted OneNote pages:
#### macOS OneNote app
- Paste loses indent
- Code blocks become become individual lines of inline code
- Tags become `data:image/png;base64` monstrous images
#### Windows Store App "OneNote for Windows 10"
- Paste loses indent
- Code blocks become become individual lines of inline code
- Tags are lost
#### Windows Office "OneNote for Microsoft 365"
- Paste loses indent
- Code blocks become become individual lines of inline code
- Tags are lost
#### OneNote WebApp in Chrome
- Just pastes plaintext of tags/blocks

### OneNote.Publish() -> DOCX -> pandoc -> MD
Many existing tools all call the [`OneNote.Publish` COM API](https://learn.microsoft.com/en-us/office/client-developer/onenote/application-interface-onenote#publish-method) to create a docx, then use [pandoc](https://pandoc.org/) to convert to HTML:
- [onenote-to-markdown-python](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert.py#L79)
- [onenote-to-markdown](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert3.ps1#L28)
- [OneNote-to-MD.md](https://gist.github.com/heardk/ded40b72056cee33abb18f3724e0a580#file-onenote-to-md-md)
- [ConvertOneNote2MarkDown](https://github.com/theohbrothers/ConvertOneNote2MarkDown/blob/179c8ecda8f14b1c6713102d80a92d1f646ab4aa/ConvertOneNote2MarkDown-v2.ps1#L134)
- [onenote-md-exporter](https://github.com/alxnbl/onenote-md-exporter/blob/d2cd4094ded11530b24423a446ec99590e95af86/src/OneNoteMdExporter/Services/Export/ExportServiceBase.cs#L121)
- [owo](https://github.com/alopezrivera/owo/blob/ac5e1114acaf8ce3675a4ed26aa2176f8ec7bd18/src/OneNote/OneNote-Retrieve.psm1#L65)

There are different [publish formats](https://learn.microsoft.com/en-us/office/client-developer/onenote/enumerations-onenote-developer-reference#odc_PublishFormat) in the COM API:
* I tried `pfHTML=7` and that didn't work
* `pfEMF` sounded interesting, but EMF is an image format
* `pfPDF` sounded interesting, but that is a step backwards (even pandoc can't export PDF to markdown)

- [ ] Try using pandoc option `-t gfm+hard_line_break` to prevent word-wrap?  
### Recurse through OneNote COM document object model
[ChristosMylonas/onenote2md](https://github.com/ChristosMylonas/onenote2md)  skips the DOCX and pandoc, and is [called out](https://github.com/ChristosMylonas/onenote2md/pull/3#issue-806857343) for that!
(But, you need to build the C# from source.)

- [x] Run this and look for results
	- https://github.com/darthwalsh/diff-onenote-export/tree/onenote2md/Section1
- [x] Diff against the pandoc approach
	- https://github.com/darthwalsh/diff-onenote-export/compare/docx-pandoc_no_num..onenote2md
- [x] Maybe, can generate MD twice, using one app, then next app, and use git diff editor to pick best?

I looked for other tools in the top google search results, and didn't find anything. Let me know if I missed one!

### Microsoft Graph API
The [obsidian-importer](https://github.com/p3rid0t/obsidian-importer) community plugin [uses](https://github.com/p3rid0t/obsidian-importer/blob/df9c53a5b24b31c73cd798e1ae08fbf5caf9a849/src/formats/onenote.ts#L128) the `https://graph.microsoft.com/` API for importing OneNote sections.

- https://github.com/darthwalsh/diff-onenote-export/tree/obsidian-importer/Section1

Created [one PR](https://github.com/obsidianmd/obsidian-importer/pull/270) for this tool, might make more!

Other issues from github to try fixing:
- [ ] [Lists have line breaks before every indentation](https://github.com/obsidianmd/obsidian-importer/issues/262)
- [ ] [Import sometimes writes files to wrong folder](https://github.com/obsidianmd/obsidian-importer/issues/249)


- [ ] try [this cleanup script](https://forum.obsidian.md/t/new-tool-for-migration-from-onenote-updated-and-improved-version/3055/83?u=darthwalsh) too

## Special OneNote Formatting

I created a small OneNote notebook with various problematic formatting that I've probably used in some notes: https://1drv.ms/u/s!Ar1janwBQRu4iNc_xOhR-aFOOobSnQ

- [x] Text formats
- [x] Blocks of styles/tables
- [x] Links:
	- [x] bare HTTPS url, and formatted hyperlink
	- [x] file:// links?
	- [x] pages in another section
	- [x] subpage with a munged subfolder-path
	- [x] links to subheadings within a page
- [x] Tags including mixed checkbox/bullets
- [x] Page created/modified date
- [x] Attached files, inline images and printouts
- [x] Notes with `/\` etc. in title
- [x] Parent/Subpages
- [-] Doesn't have any h-rule horizontal line
	- (*Not supported in onenote!*)

### Block quotations vs code fence problem
The main problem I'm running into using the DOCX->pandoc solution above is the generated MD has block quotes, when I expected code fences.

Pandoc has both [block quotations](https://pandoc.org/MANUAL.html#block-quotations)
```
>block
>quotations
```

and [fenced code blocks](https://pandoc.org/MANUAL.html#fenced-code-blocks)
~~~
```
some code
```
~~~

#### Pandoc Parses DOCX blockquote
There have been some relatively recent pandoc PRs that adjust how DOCX is parsed, and when to avoid blockquote format:
- https://github.com/jgm/pandoc/pull/7606
- https://github.com/jgm/pandoc/commit/938d55784486f42d80cc4c2fcfe6ae905be382cd

I'm using a very recent build of pandoc.exe so not having those patches shouldn't be a problem here.

#### Pandoc Parses DOCX code style
There's an [open pandoc issue](https://github.com/jgm/pandoc/issues/5971#issuecomment-1162238592) for this. This seems a little too magic:
> Pandoc is looking for a style with the _name_ `Source Code`, not a style with the id (or name) `SourceCode`.

Implemented by [this commit](https://github.com/jgm/pandoc/commit/c113ca6717d00870ec10716897d76a6fa62b1d41). (It looks like the style just has to inherit from a style named `Source Code`?)

In my Microsoft Word (Version 2212 Build 16.0.15928.20196), opening a new document, I don't have a style named `Source Code`. But I downloaded some of the [test DOCX](https://github.com/jgm/pandoc/blob/main/test/docx/adjacent_codeblocks.docx) used in pandoc tests, and they did have a style with this name.

On StackOverflow, [somebody asked about this](https://stackoverflow.com/a/27549401/771768), and the answer was edit your DOCX to use this style.

> [!info]- style vs. rstile
> I'm not sure what the difference between `w:rStyle` or just `style` is in the XML, but maybe it doesn't matter? I [think](https://python-docx.readthedocs.io/en/latest/dev/analysis/features/styles/character-style.html) `rstyle` is "run style" which sounds like HTML `span`.

[ConvertOneNote2MarkDown](https://github.com/theohbrothers/ConvertOneNote2MarkDown) has a config about "existing `.docx`", maybe it's possible to munge the style of the exported DOCX?


#### Dead end technology solutions
###### Pandoc filters
Pandoc works with the concept of [filters](https://pandoc.org/filters.html). There is native haskell functionality for reading native files into JSON representation, the filters further transform the JSON into new JSON before a pandoc writer creates the output file.

**Cons**: The information about code style was already lost during the DOCX parsing.

###### pandoc debug output
I thought the[ pandoc `--verbose` flag](https://pandoc.org/MANUAL.html) should print output to show how the DOCX is parsed, but I never saw any output. *Maybe only the TeX writer uses logging?*


### OneNote Tags
OneNote has a concept of [tags](https://support.microsoft.com/en-us/office/apply-a-tag-to-a-note-in-onenote-908c7b92-6ed0-498d-bc7d-1b44e6827d05) which are somewhat like hashtags/labels. 

They are not exported in the DOCX->pandoc->markdown tools above, because OneNote doesn't even export them!
(They are rendered in the OneNote PDF printout, but [parsing PDFs](PDFLinkExtract.md) is quite non-trivial.) 

Tags I've used, that I want exported to markdown:
* ToDo: `- [ ]` 
	* Can also be in Completed state `- [x]`
* Question: can use the [obsidian question callout syntax](https://help.obsidian.md/Editing+and+formatting/Callouts#Supported%20types): `> [!question]`
* Important: `> [!important]` (alias for `tip`)

I used to use some other tags, but I scrubbed using Tags Summary search:
* password: moved secrets to 1PW, created custom link
* Idea: Basically everything in my notes is ideas :P
* To Do Priority 2: I don't even finish all my P1 ideas

### Ordering Notes
Obsidian notes by default are displayed in alphabetical order.
Exported markdown files can be ordered using number prefix in Markdown file: `01_note_a.md`, `02_b.md` etc
Could also use YAML frontmatter tag with [obsidian-custom-sort extension](https://github.com/SebastianMC/obsidian-custom-sort).
A few of my pages I care about the order, but for those I've often named the notes in a sortable order like `YYYY-MM-DD` -- (but maybe that metadata belongs in YAML frontmatter...)

### Creation / Modification dates
It would be nice to export creation and/modifications dates from OneNote, in YAML frontmatter.
There doesn't seem to be consensus about what the field names should be, but I like `created` and `modified`.

Or, it's possible to use the underlying sync technology to store dates. OneNote will sync file creation/modified time metadata across different systems. With git, the filesystem metadata is ignored, but you can fake the creation and modified time by creating one commit in the past for creation, then another for last-modified: https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---dateltdategt

#### Metadata using YAML Frontmatter

In order to add metadata to a markdown file (URL aliases, blog tags, author details) tools often use a [YAML frontmatter](https://jekyllrb.com/docs/front-matter/) block at the top of the file:

```yaml
---
layout: post
title: Blogging Like a Hacker
---
...Markdown content starting here...
```

Obsidian supports this, called Properties: https://help.obsidian.md/Editing+and+formatting/Properties
Remark has a plugin for it: https://github.com/remarkjs/remark-frontmatter



### Hierarchies
I make heavy use of OneNote [subpages](https://support.microsoft.com/en-au/office/create-a-subpage-in-onenote-2dd0fbd9-5e2f-4162-b53b-66d0c41b0873) as another layer of hierarchy.

If I have Pages/Subpages:
```
Timeline
Meta
└  Project Locations
└  Windows
   └  PC
   └  Laptop
```

Generally you'd assume that "Project Locations" should be in a "Meta" folder, but what happens if the Meta parent page is nonempty?

That could generate files:
```
Timeline.md
Meta/README.md
Meta/Project Locations.md
Meta/Windows/README.md
Meta/Windows/PC.md
Meta/Windows/Laptop.md
```

There are a couple other reasonable choices other than using `README.md` (github's default name for a folder default-page) as the special name for subfolders:
-  using the default page index.html from web servers: `index.md` 
-  repeat the folder name:  `Meta/Meta.md`

#### Dendron has flat list of files
There's also the flat naming style without any folders, which the [Dendron app uses](https://www.kevinslin.com/notes/3dd58f62-fee5-4f93-b9f1-b0f0f59a9b64/#finding-the-truth)
```
Meta.md
Meta.Project Locations.md
Meta.Windows.md
Meta.Windows.PC.md
```

#### Johnny Decimal has forced folders

One other file/folder scheme is [Johnny Decimal file-folder naming](../Johnny%20Decimal%20file-folder%20naming.md) but that would involve restructuring my entire OneNote organization structure...

