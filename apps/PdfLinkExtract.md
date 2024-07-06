I'd like to extract all the internal links in the ECMA-335.pdf.

I started with https://stackoverflow.com/q/27744210/771768, but that is about hyperlinks opened in the browser.
### Resolving target page of ToC `Outlines` entries
The pdfminer cookbook https://pdfminersix.readthedocs.io/en/latest/howto/toc_target_page.html#how-to-resolve-the-target-page-of-toc-entries should work?
However
```
    for (level, title, dest, a, se) in document.get_outlines():
        print("Level", level, "Title", title, "Dest", dest, "A", a, "SE", se)
```
prints:
```
Level 1 Title Ecma Standard 2nd page with registered logo 2012.pdf Dest [None, 0.0, 0.0, 1.0] A None SE None
Level 2 Title OLE_LINK6 Dest [None, /'XYZ', 68, 756, 0] A None SE None
Level 2 Title OLE_LINK7 Dest [None, /'XYZ', 68, 756, 0] A None SE None
Level 2 Title DDHeadingPage1 Dest [None, /'XYZ', 342, 756, 0] A None SE None
Level 2 Title DDOrganization Dest [None, /'XYZ', 342, 756, 0] A None SE None
Level 2 Title LibEnteteISO Dest [None, /'XYZ', 342, 756, 0] A None SE None
Level 2 Title LIBTypeTitreISO Dest [None, /'XYZ', 342, 756, 0] A None SE None
Level 2 Title DDTITLE4 Dest [None, /'XYZ', 342, 756, 0] A None SE None
```
...which isn't very helpful. It looks like `Outlines` is not the PDF data we need!

### Resolving link locations using pdfplumber
pdfminer is used by a library `pdfplumber==0.10.4` which makes this easier:
```python
pdf_file_path = "C:/Users/cwalsh/Downloads/ECMA-335.pdf"
def extract3():
    with pdfplumber.open(pdf_file_path) as pdf:
        objid_to_pagenum = {page.page_obj.pageid: page_num for page_num, page in enumerate(pdf.pages, 1)}

        total_height = sum(page.height for page in pdf.pages)
        height = round(total_height / len(pdf.pages))

        # pages = pdf.pages
        pages = [pdf.pages[49]] # Hardcode just page 49 for testing

        seen = set()        
        for l in (annot for p in pages for annot in p.annots):
            # Seeing dumplicate annots
            key = tuple(l["data"]["Rect"])
            if key in seen: continue
            seen.add(key)

            # for d in l["data"]["Dest"]:
            #     print("!", d)
            dest = extract_dest(l["data"]["Dest"], objid_to_pagenum, height)
            print(json.dumps(l["top"], indent=4, default=str), " => ", dest)


def extract_dest(dest, objid_to_pagenum, height):
    # print(dest)
    obj_ref, _name, _x, y, _z = dest
    id = obj_ref.objid

    return objid_to_pagenum[id] + y / height
```
1. Create a mapping from pageid to page numbers
2. Get the typical height of any page
3. Discard duplicate annots
4. `.data.Dest` has an id reference, and /XYZ locations so compute the fractional height of the link

## From nodeJS
It should be possible to get these same `Dest` Annotations from node JavaScript, but it wasn't simple to find a good library for it.

This post indicates the best solution is paid software: https://stackoverflow.com/q/57248230/771768

PDF.js https://github.com/mozilla/pdf.js is the gold-standard library, but this [2013 article](https://www.codeproject.com/Articles/568136/Porting-and-Extending-PDFJS-to-NodeJS) says there are many steps involved with porting various browser APIs into nodeJS. In [pdf2json](https://github.com/modesty/pdf2json) by the article author, there's a vendered copy of PDF.js in but the API with those ports applied. However, it's public API doesn't give access to the destinations that PDF.js parses.

After some more searching, I found [this example](https://github.com/mozilla/pdf.js/blob/master/examples/node/getinfo.mjs) using pdfjs-dist. I got text parsing and desination lookup working with `pdfjs-dist@4.2.67`
```js
import { getDocument } from "pdfjs-dist/legacy/build/pdf.mjs";
import fs from "fs";

// First run curl https://www.ecma-international.org/wp-content/uploads/ECMA-335_6th_edition_june_2012.pdf -o /tmp/ecma.pdf
const path = "/tmp/ecma.pdf";
const dataBuffer = new Uint8Array(fs.readFileSync(path));
const pdfDocument = await getDocument({ data: dataBuffer }).promise;

const page = await pdfDocument.getPage(49);
const texts = await page.getTextContent();
for (const item of texts.items) {
  const x = item.transform[4], y = item.transform[5]; // https://dev.opera.com/articles/understanding-the-css-transforms-matrix/
  // For some reason, y=0 at bottom of page, and increases as we go up

  // Some heuristics to find the right text
  if (x > 91) continue;
  if (!item.str.length) continue;
  if (item.str.includes("©")) continue;
  console.log(y.toFixed(2), item.str);
}
console.log()
const seen = new Set();
for (const annot of await page.getAnnotations()) {
  if (annot.subtype !== "Link") throw new Error(annot.subtype);
  const key = JSON.stringify(annot.rect);
  if (seen.has(key)) continue;
  seen.add(key);

  const [x, y, _w, _h] = annot.rect;
  const [ref, _name, dx, dy, _dz] = annot.dest;
  const destPage = await pdfDocument.getPageIndex(ref);
  console.log(`from ${[x, y]} to page ${destPage+1} ${[dx, dy]}`);
}
```
prints
```
683.62 I.8.2.5.2
464.47 I.8.3
331.37 I.8.3.1
261.74 I.8.3.2

from 367.43,271.14 to page 60 87,521
from 442.69,92.152 to page 98 87,680
```
which is correct for page 49 of the PDF!
The second annotation dest is duplicated so need to be removed.
The first link is to "§I.8.7", which happens to be on page 60, running the script at the page, confirms the header text I.8.7 is at y=511.03!

It will be quite non-trivial to extract the **link's text-content** from the page, for example, the last link text "§I.12.1" going to page 97 has the textContent:
```
  {
    str: 'Some coercion is built directly into the VES operations on the built-in types (see §I.12.1). All',
    dir: 'ltr',
    width: 374.24660000000006,
    height: 9.96,
    transform: [ 9.96, 0, 0, 9.96, 114.97999999999985, 94.55999999999995 ],
    fontName: 'g_d0_f2',
    hasEOL: true
  },
```
At location 114.98,94.56 and 374 wide, which contains the text in annoation at 442.69,92.152
In order to get the text, you would need to know the x location of each glyph within the text...
See WontFixed issue: https://github.com/mozilla/pdf.js/issues/7396 and https://github.com/mozilla/pdf.js/issues/7996
