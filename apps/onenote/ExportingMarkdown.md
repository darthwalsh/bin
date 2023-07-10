The problem I'm running into is the generated MD has block quotes, when I expected code fences.

### OneNote.Publish() -> DOCX -> pandoc -> MD
These existing tools all call the [`OneNote.Publish` COM API](https://learn.microsoft.com/en-us/office/client-developer/onenote/application-interface-onenote#publish-method) to create a docx, then use [pandoc](https://pandoc.org/) to convert to HTML:
- [onenote-to-markdown-python](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert.py#L79)
- [onenote-to-markdown](https://github.com/pagekeytech/onenote-to-markdown/blob/192fe9ec303f30e77d4e3609ea7aafc05578c28e/convert3.ps1#L28)
- [OneNote-to-MD.md](https://gist.github.com/heardk/ded40b72056cee33abb18f3724e0a580#file-onenote-to-md-md)
- [ConvertOneNote2MarkDown](https://github.com/theohbrothers/ConvertOneNote2MarkDown/blob/179c8ecda8f14b1c6713102d80a92d1f646ab4aa/ConvertOneNote2MarkDown-v2.ps1#L134)
- [onenote-md-exporter](https://github.com/alxnbl/onenote-md-exporter/blob/d2cd4094ded11530b24423a446ec99590e95af86/src/OneNoteMdExporter/Services/Export/ExportServiceBase.cs#L121)
- [owo](https://github.com/alopezrivera/owo/blob/ac5e1114acaf8ce3675a4ed26aa2176f8ec7bd18/src/OneNote/OneNote-Retrieve.psm1#L65)

There are different [publish formats](https://learn.microsoft.com/en-us/office/client-developer/onenote/enumerations-onenote-developer-reference#odc_PublishFormat):
* I tried `pfHTML=7` and that didn't work.
* `pfEMF` sounded interesting, but EMF is an image format
* `pfPDF` sounded interesting, but pandoc can't export PDF to markdown

### Alternates

[ChristosMylonas/onenote2md](https://github.com/ChristosMylonas/onenote2md)  skips the DOCX and pandoc, and is [called out](https://github.com/ChristosMylonas/onenote2md/pull/3#issue-806857343) for that!
(But, you need to build the C# from source.)

> [!todo] Run this and look for results
> Diff against the pandoc approach
> Maybe, can generate MD twice, using one app, then next app, and use git diff editor to pick best?


### Block quotations vs code fence problem
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




> [!TODO] Include example
> Export obsidian one-page notebook, and DOCX, and MD.
> Include screenshots of each.


### Pandoc Parses DOCX blockquote

There have been some relatively recent pandoc PRs adjust how DOCX is parsed, and when to avoid blockquote format:
- https://github.com/jgm/pandoc/pull/7606
- https://github.com/jgm/pandoc/commit/938d55784486f42d80cc4c2fcfe6ae905be382cd

I'm using a very recent build of pandoc.exe so not having those patches shouldn't be a problem here.

### Pandoc Parses DOCX code style
There's an [open pandoc issue](https://github.com/jgm/pandoc/issues/5971#issuecomment-1162238592) for this. This seems a little too magic:
> Pandoc is looking for a style with the _name_ `Source Code`, not a style with the id (or name) `SourceCode`.

Implemented by [this commit](https://github.com/jgm/pandoc/commit/c113ca6717d00870ec10716897d76a6fa62b1d41). (It looks like the style just has to inherit from a style named `Source Code`?)

In my Microsoft Word (Version 2212 Build 16.0.15928.20196), opening a new document, I don't have a style named `Source Code`. But I downloaded some of the [test DOCX](https://github.com/jgm/pandoc/blob/main/test/docx/adjacent_codeblocks.docx) used in pandoc tests, and they did have a style with this name.

On StackOverflow, [somebody asked about this](https://stackoverflow.com/a/27549401/771768), and the answer was edit your DOCX to use this style.

> [!info]- style vs. rstile
> I'm not sure what the difference between `w:rStyle` or just `style` is in the XML, but maybe it doesn't matter? I [think](https://python-docx.readthedocs.io/en/latest/dev/analysis/features/styles/character-style.html) `rstyle` is "run style" which sounds like HTML `span`.

[ConvertOneNote2MarkDown](https://github.com/theohbrothers/ConvertOneNote2MarkDown) has a config about "existing `.docx`", maybe it's possible to munge the style of the exported DOCX?

### Dead end solutions
##### Pandoc filters
Pandoc works with the concept of [filters](https://pandoc.org/filters.html). There is native haskell functionality for reading native files into JSON representation, the filters further transform the JSON into new JSON before a pandoc writer creates the output file.

**Cons**: The information about code style was already lost during the DOCX parsing.

##### pandoc debug output
I thought the[ pandoc `--verbose` flag](https://pandoc.org/MANUAL.html) should print output to show how the DOCX is parsed, but I never saw any output. *Maybe only the TeX writer uses logging?*

