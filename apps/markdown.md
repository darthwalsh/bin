## Linting indents

- [ ] Fix any pages that use **both** spaces and tabs for indents.
- [ ] Check that indent-depth is consistent (probably don't use 2 spaces for lists?)

## Linting links

- [ ] Try using `markdown-link-check` to lint links.
- [ ] Add github action to find newly broken network links
- https://github.com/tcort/markdown-link-check
- Does both local and network URLs, doesn't seem to be a way to turn off network
- Asserts [anchor links](https://github.com/tcort/markdown-link-check/issues/91) for URL fragments on local links
- Recursively searching files is [tricky](https://github.com/tcort/markdown-link-check/issues/78) -- could run `markdown-link-check (git ls-files -- *.md)`

URLs that are links: `[https://example.com](https://example.com)` should just be turned to plaintext link: `https://example.com`
...if it links to any other URL, don't fix but should be lint error. (Ignore the fragment instead of erroring though.)
