Goal: find more subtle typos like https://github.com/stakx/ecma-335/pull/17/files from [[PDF]] files

I've been thinking about how I'd find diffs of big chunks of text, and decided today is the day to sit down and figure it out!
1. Downloaded https://www.ecma-international.org/wp-content/uploads/ECMA-335_6th_edition_june_2012.pdf
2. Printed [my WIP HTML render of stakx/ecma-335](https://github.com/stakx/ecma-335/issues/10#issuecomment-1531808437) at https://carlwa.com/ecma-335/ to PDF.
3. Came up with these commands after reading https://superuser.com/a/651406/282374 

```bash
# brew install poppler 
pdftotext -raw ECMA-335.pdf - | grep -v 'Ecma International 2012' > ecma.txt

pdftotext -layout stakx-ecma-335.pdf - | tr -d '\f' > stakx.txt

norm() {
  sed -e 's/[“”]/"/g' -e "s/[‘’]/'/g" -e "s//→/g" -e "s///g"
}

dwdiff -c <(<ecma.txt norm) <(<stakx.txt norm) | less -R
```

Worked pretty well, except some things I had to work around:
- needed to normalize smart quotes and some other unicode 
- some wide tables got cut off in print-to-pdf
- word wrapping inside table cells rendered on different lines
- if print-to-pdf split a table across pages, the headers were duplicated to the next page
- for some reason, the print-to-pdf step doubled hyperlinks
- for every diff that found a typo in the markdown, there were 2 showing typos fixed from the original PDF!


In hindsight, probably should have used `pandoc` to convert MD to TXT, instead of MD to HTML to PDF to TXT.

🎉 Created PR https://github.com/stakx/ecma-335/pull/22

*Later update!* Figured out how to put the diff on the web in [PasteBinForDiffs](PasteBinForDiffs.md).

---
Also, some notes on other tools I tried:

- Tried pdfminer and pdfplumber
	- [pdf2txt](https://pdfminersix.readthedocs.io/en/latest/reference/commandline.html#api-pdf2txt) command is another CLI for converting to text
	- Might be interesting to come back to, if they are able to output intra-document links
	- funny discovery: The ECMA-335 PDF has a dozen links to the author's local file e.g. II.4.2 ` file:///C:/Users/Joel%20Marcey/Documents/My%20Dropbox/TwinRoots/CLI/Partitions/Partition%20V%20Annexes.doc%23_Sample`
	- Extracting plain text from HTML seems like a solved problem, but how to do the diff?
- Tried https://soft.rubypdf.com/software/diffpdf
	- this Windows build is different than commercial version: https://www.qtrac.eu/diffpdf.html
	- Can't get it to match same text that happens to be on a different page
- Tried using `pdfjam` to merge the 500 pages to 1 huge page
	- in [[manjoro]] WSL, installed `extra/texlive-binextra`
	- ran script https://gist.github.com/timabell/9616807b2fe3fa60f234
	- but multiple problems trying to use this in diffpdf GUI:
	- as I scroll down the two locked views become more and more out of alignment
	- can't select-copy text from the selection to easy find markdown to change
	- different (fixedwidth?) formatting reported as a difference
	- workable with 10-page sample, but scaling to all 500 pages is ***far*** too zoomed out
- Tried using vscode to text diff the `.txt` above. It timed out, and wasn't able to do the line-unaware smart diff the other tools could.
- Tried `wdiff` tool first which seems more widely supported
	- Didn't have color, have to work around like: `wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'`
