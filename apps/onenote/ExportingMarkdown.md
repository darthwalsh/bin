I'm working on exporting the majority of my OneNote to Markdown. This is the summary of this process, and the problems I ran into.

## Technology solutions
I looked for other tools in the top google search result. [Let me know](https://github.com/darthwalsh/bin/issues/new) if I missed one!

For each tool, I documented the high-level of which combination of tools were used, and tried running them against my [[#Special OneNote Formatting]] notebook to create a branch in the [diff-onenote-export](https://github.com/darthwalsh/diff-onenote-export/branches/all) repo. 

Note: to compare solutions, you can use github compare with `..` e.g. https://github.com/darthwalsh/diff-onenote-export/compare/docx-pandoc_no_num..onenote2md
### OneNote.Publish() COM API -> DOCX -> pandoc -> MD
https://github.com/darthwalsh/diff-onenote-export/tree/docx-pandoc/Section1

Many existing tools all call the [`OneNote.Publish` COM API](https://learn.microsoft.com/en-us/office/client-developer/onenote/application-interface-onenote#publish-method) to create a DOCX Microsoft Word file, then use [pandoc](https://pandoc.org/) to convert to HTML:
- [onenote-to-markdown-python](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert.py#L79)
- [onenote-to-markdown](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert3.ps1#L28)
- [OneNote-to-MD.md](https://gist.github.com/heardk/ded40b72056cee33abb18f3724e0a580#file-onenote-to-md-md)
- [ConvertOneNote2MarkDown](https://github.com/theohbrothers/ConvertOneNote2MarkDown/blob/179c8ecda8f14b1c6713102d80a92d1f646ab4aa/ConvertOneNote2MarkDown-v2.ps1#L134)
- [onenote-md-exporter](https://github.com/alxnbl/onenote-md-exporter/blob/d2cd4094ded11530b24423a446ec99590e95af86/src/OneNoteMdExporter/Services/Export/ExportServiceBase.cs#L121)
- [owo](https://github.com/alopezrivera/owo/blob/ac5e1114acaf8ce3675a4ed26aa2176f8ec7bd18/src/OneNote/OneNote-Retrieve.psm1#L65)

#### Trying different COM params
There are different [publish formats](https://learn.microsoft.com/en-us/office/client-developer/onenote/enumerations-onenote-developer-reference#odc_PublishFormat) in the COM API parameter, to allow exporting other formats than DOCX:
* I tried `pfHTML=7` and that didn't work
* `pfEMF` sounded interesting, but EMF is an image format
* `pfPDF` sounded interesting, but that is a step backwards (note that pandoc can't export PDF to markdown)

I didn't look into using pandoc option `-t gfm+hard_line_break` to prevent word-wrap.

### Recurse through OneNote COM document object model
In addition to `.Publish()` the OneNote COM API exposes each page document as an object model, so it's possible to write the markdown as the app reads through the DOM.

#### Separate C# App
https://github.com/darthwalsh/diff-onenote-export/tree/onenote2md/Section1

[ChristosMylonas/onenote2md](https://github.com/ChristosMylonas/onenote2md) skips the DOCX and pandoc, and is [called out](https://github.com/ChristosMylonas/onenote2md/pull/3#issue-806857343) for that!
(But, you need to compile the C# app from source.)

#### OneNote Extension
https://github.com/darthwalsh/diff-onenote-export/tree/onemore/Section1

[OneMore](https://onemoreaddin.com/commands/File%20Commands.htm) can export markdown, by [looping through the document object model](https://github.com/stevencohn/OneMore/blob/8586b2b3b4af1884e6cc4665e0b45e56215407b3/OneMore/Commands/File/Markdown/MarkdownWriter.cs#L275).
You can select all pages in a section for bulk export, but I don't see an option to export multiple sections at once.

There is another option to archive an entire section/notebook into a ZIP of HTML, which has great visual fidelity! If you just needed read-only browser-access to your notes without the OneNote app, this tool would be my first pick.

### Microsoft Graph API
The above solution with COM are Windows-only. On macOS the only solution is to use the Microsoft Graph API at  `https://graph.microsoft.com/`.

#### Obsidian Importer
https://github.com/darthwalsh/diff-onenote-export/tree/obsidian-importer/Section1

The [obsidian-importer](https://github.com/p3rid0t/obsidian-importer) community plugin [uses](https://github.com/p3rid0t/obsidian-importer/blob/df9c53a5b24b31c73cd798e1ae08fbf5caf9a849/src/formats/onenote.ts#L128) the Graph API for importing OneNote sections.
1. Gets HTML form the Graph API
2. Creates [`HTMLElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement) 
3. Converts `data-tag` with special-case for checkboxes
4. Gets attachments
5. Converts OneNote's custom styles to semantic HTML
    1. also finds font=Consolas and creates code block
6. Finds internal links with `onenote:` and creates relative link
7. For drawings, inserts callout that page contained drawing
8. Calls built-in [`obisdian.htmlToMarkdown()`](https://github.com/obsidianmd/obsidian-api/blob/23947b58d372ea02225324308e31d36b4aa95869/obsidian.d.ts#L2021) that internally uses [turndown](https://github.com/mixmark-io/turndown) converter

- [x] ⏫ Research the https://help.obsidian.md/import/html; does it use the same HTML->markdown framework? maybe easier to test
    - [x] Uses same htmlToMarkdown()
- [ ] Migrate some of below to [[obsidian.plugin.dev]] 🔼 
- [ ] Research other obsidian plugins; do any have `npm test`?
    - (not a plugin) HTML -> MD test cases: https://github.com/kkew3/html2obsidian/tree/master/test_cases and [python test runner](https://github.com/kkew3/html2obsidian/blob/master/test_convert_html.py)
    - Nothing in core at https://github.com/orgs/obsidianmd/repositories?language=&q=&sort=stargazers&type=all seems to have tests, but they don't have many open-source plugins
    - [ ] Look at top community plugins
    - [ ] Look through Discord [plugin-dev/plugin-testing](https://discord.com/channels/686053708261228577/962362830642905148) to see other examples?
- [ ] Add tracing / network debugging / diagnostic level console writes?
- [ ] move this stuff to [[obsidian.plugin.dev]]

- [ ] My goal is to get https://github.com/darthwalsh/diff-onenote-export/compare/manual..obsidian-importer diffs to be smaller

- [x] [PR](https://github.com/obsidianmd/obsidian-importer/pull/270) for fixing notebook lastModified time
- [x] [PR](https://github.com/obsidianmd/obsidian-importer/pull/277) for page creation date fix
- [ ] Next PR for one of the issues below?

Other issues from github to try fixing next:
- [ ] [Lists have line breaks before every indentation](https://github.com/obsidianmd/obsidian-importer/issues/262)
- [ ] [Import sometimes writes files to wrong folder](https://github.com/obsidianmd/obsidian-importer/issues/249)
- [ ] importing table causes empty first row (no issue as of 2024-09-23)

#### Converting HTML using markdownify
https://github.com/darthwalsh/diff-onenote-export/tree/html_markdownify/Section1

[This blog](https://www.ssp.sh/blog/how-to-take-notes-in-2021/#how-did-i-export-my-10-of-onenote-to-markdown) explains the process, but basically it [downloads the page HTML](https://gist.github.com/sspaeti/8daab59a80adc664fa8cbcba707ea21d#file-onenote_export-py-L234) for each page, then uses [python-markdownify](https://github.com/matthewwithanm/python-markdownify) to convert HTML -> markdown.
I needed a [couple patches](https://gist.github.com/darthwalsh/c0f2a53634c76d15567ef440f59053c1/revisions) to support the Exportable notebook.

#### Exporting HTML -> ENEX -> MD
https://sspeiser.github.io/onenote-export/ app [gets the HTML](https://github.com/sspeiser/onenote-export/blob/70843e98e6475628eb93fee5d44d44ee1fdac43a/src/OneNoteSource.tsx#L74), writes to Evernote's ENEX format, which can be imported and exported by other apps...
But now their Microsoft Graph API [isn't working](https://github.com/sspeiser/onenote-export/issues/8), so the website doesn't function.

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

### Tools that don't actually export from OneNote
After exporting the markdown, there are some other tools you can you 

[Obsidian Forums mention](https://forum.obsidian.md/t/new-tool-for-migration-from-onenote-updated-and-improved-version/3055/83?u=darthwalsh) a [cleanup script](https://gist.github.com/juanbretti/9dcc81b55323d59c8d36938e111c2e75) which changes the first markdown lines to be better markdown YAML frontmatter tags, but I can't tell which markdown export process it is hardcoded to be used with.

I haven't settled on any markdown linter or auto-formatter, but it might be interested to revisit using some [linter](markdown.linter.md) to decrease the git diffs between the branches.

## Special OneNote Formatting

I created a small OneNote notebook with various problematic formatting that I've probably used in some notes: https://1drv.ms/u/s!Ar1janwBQRu4iNc_xOhR-aFOOobSnQ

My ideal version of how to represent these in GFM and/or Obsidian markdown is: https://github.com/darthwalsh/diff-onenote-export/tree/manual/Section1

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
	* these are called [Alerts in GFM](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)
* Important: `> [!important]` (alias for `tip`)

*Note: This is quite similar to GithubFlavoredMarkdown Alerts, see https://github.com/orgs/community/discussions/16925 -- just maybe different keywords?*
```markdown
> [!IMPORTANT]  
> Crucial information necessary for users to succeed.
```


I used to use some other tags, but I scrubbed using Tags Summary search:
* password: moved secrets to 1PW, created custom link
* Idea: Basically everything in my notes is ideas :P
* To Do Priority 2: I don't even finish all my P1 ideas

### Ordering Notes
Obsidian notes by default are displayed in alphabetical order.
Exported markdown files can be ordered using number prefix in Markdown file: `01_note_a.md`, `02_b.md` etc
Could also use YAML frontmatter tag with [obsidian-custom-sort extension](https://github.com/SebastianMC/obsidian-custom-sort).
A few of my pages I care about the order, but for those I've often named the notes in a sortable order like `YYYY-MM-DD` -- (but maybe that metadata belongs in YAML frontmatter...?)

### Creation / Modification dates
Many of the tools above don't export creation and modifications dates from OneNote.

It's *possible* to use the underlying sync technology to store dates. OneNote will sync file creation/modified time metadata across different systems. With git, the filesystem metadata is ignored, but you can fake the creation and modified time by creating one commit in the past for creation, then another for last-modified: https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---dateltdategt

A more [[KISS]] option is to put the metadata in the YAML Frontmatter.
There doesn't seem to be consensus about what the field names should be, but I like `created` and `modified`, and can use date or datetime ISO string format.

#### *Aside:* Metadata using YAML Frontmatter
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

### SubPages for [[hierarchies]]
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

Generally you'd assume that "Project Locations.md" should be in a "Meta/" folder, but what happens to the "Meta.md" page's content if it's nonempty?

The GitHub website would encourage putting that folder content in a `README.md` file:
```
Timeline.md
Meta/README.md
Meta/Project Locations.md
Meta/Windows/README.md
Meta/Windows/PC.md
Meta/Windows/Laptop.md
```

There are a couple other reasonable choices other than using `README.md` as the special name for subfolders:
- using the default page index.html from web servers: `index.md` 
- repeat the folder name: `Meta/Meta.md`

#### Dendron has flat list of files
There's also the flat naming style without any folders, which the [Dendron app uses](https://www.kevinslin.com/notes/3dd58f62-fee5-4f93-b9f1-b0f0f59a9b64/#finding-the-truth)
```
Meta.md
Meta.Project Locations.md
Meta.Windows.md
Meta.Windows.PC.md
```

#### Johnny Decimal has forced folders
One other popular file/folder scheme is [Johnny Decimal file-folder naming](../Johnny%20Decimal%20file-folder%20naming.md) but that would involve restructuring my entire OneNote organization structure, so I'm not seriously looking into that.

