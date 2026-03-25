`jq` is great, but the indented format isn't the most readable. It also can't handle comments!

## Mutating JSONC in-place (preserving comments and formatting)

Standard JSON parsers normalize/reformat and strip comments. Use `jsonc-cli` (wraps VS Code's own [`jsonc-parser`](https://github.com/microsoft/node-jsonc-parser)) for surgical in-place edits:

```bash
npm install --global jsonc-cli
jsonc modify .vscode/settings.json python.defaultInterpreterPath '"/path/to/python"'
```

Implemented in [[vscode_python_interpreter.py]].

**Strategies (worst to best):**
- Regex on raw text — brittle but works if assumptions are documented
- Python `json5`/`commentjson` — parses but discards byte offsets, can't preserve formatting
- `jsonc-cli` / `jsonc-parser` (Node) — preserves comments, whitespace, ordering; adds key if missing

## fractured-json
Starting with this JSON5:
```json5
{
    /*
     * Multi-line comments
     * are fun!
     */
    "NumbersWithHex": [
          254 /*00FE*/,  1450 /*5AA*/ ,     0 /*0000*/, 36000 /*8CA0*/,    10 /*000A*/,
          199 /*00C7*/, 15001 /*3A99*/,  6540 /*198C*/
    ],
    /* Elements are keen */
    "Elements"      : [
        { /*Carbon*/   "Symbol": "C",  "Number":  6, "Isotopes": [11, 12, 13, 14] },
        { /*Oxygen*/   "Symbol": "O",  "Number":  8, "Isotopes": [16, 18, 17    ] },
        { /*Hydrogen*/ "Symbol": "H",  "Number":  1, "Isotopes": [ 1,  2,  3    ] },
        { /*Iron*/     "Symbol": "Fe", "Number": 26, "Isotopes": [56, 54, 57, 58] }
        // Not a complete list...
    ],

    "Beatles Songs" : [
        "Taxman",          // George
        "Hey Jude",        // Paul
        "Act Naturally",   // Ringo
        "Ticket To Ride"   // John
    ]
}
```

We can use [FracturedJson](https://github.com/j-brooke/FracturedJson/wiki) to remove comments, and see how JQ formats it:
`$x | uvx fractured-json --comment-policy REMOVE - | jq`
```json
{
  "NumbersWithHex": [
    254,
    1450,
    0,
    36000,
    10,
    199,
    15001,
    6540
  ],
  "Elements": [
    {
      "Symbol": "C",
      "Number": 6,
      "Isotopes": [
        11,
        12,
        13,
        14
      ]
    },
    {
      "Symbol": "O",
      "Number": 8,
      "Isotopes": [
        16,
        18,
        17
      ]
    },
    {
      "Symbol": "H",
      "Number": 1,
      "Isotopes": [
        1,
        2,
        3
      ]
    },
    {
      "Symbol": "Fe",
      "Number": 26,
      "Isotopes": [
        56,
        54,
        57,
        58
      ]
    }
  ],
  "Beatles Songs": [
    "Taxman",
    "Hey Jude",
    "Act Naturally",
    "Ticket To Ride"
  ]
}
```

But even better is to use FracturedJson's formatting, which handles comments beautifully and space-pads "tables" (lists of objects with similar keys).
`$x | uvx fractured-json --comment-policy PRESERVE -`
```json
{
    /*
     * Multi-line comments
     * are fun!
     */
    "NumbersWithHex": [
          254 /*00FE*/,  1450 /*5AA*/ ,     0 /*0000*/, 36000 /*8CA0*/,    10 /*000A*/,   199 /*00C7*/, 15001 /*3A99*/,
         6540 /*198C*/
    ],
    /* Elements are keen */
    "Elements"      : [
        { /*Carbon*/   "Symbol": "C",  "Number":  6, "Isotopes": [11, 12, 13, 14] },
        { /*Oxygen*/   "Symbol": "O",  "Number":  8, "Isotopes": [16, 18, 17    ] },
        { /*Hydrogen*/ "Symbol": "H",  "Number":  1, "Isotopes": [ 1,  2,  3    ] },
        { /*Iron*/     "Symbol": "Fe", "Number": 26, "Isotopes": [56, 54, 57, 58] }
        // Not a complete list...
    ],
    "Beatles Songs" : [
        "Taxman",          // George
        "Hey Jude",        // Paul
        "Act Naturally",   // Ringo
        "Ticket To Ride"   // John
    ]
}
```

## `fx` is `less` for JSON5
- [ ] Try https://fx.wtf/getting-started
```
echo '{"name": "world"}' | fx 'x => x.name' 'x => `Hello, ${x}!`'

# Interactively select only a specific part of the JSON and save it to a file:
curl -i https://fx.wtf/example.json | fx > output.json
```
### Navigating
> use arrow keys 
> `.` to adjust the current path. Press `TAB` or `.` to accept the current suggestion.
> `@` to start a fuzzy search of JSON paths and jump to the first match.
> `[` or `]` to jump to the previous location or to the next location in history.
