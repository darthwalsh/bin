I'd like to extract all the internal links in the ECMA-335.pdf.

Started with https://stackoverflow.com/q/27744210/771768, but that is about hyperlinks opened in the browser.
- [ ] If I figure out a good tool for this, post a new question+self-answer to stackoverflow


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
...which isn't very helpful. It looks like `Outlines` is not the PDF data we need.


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
