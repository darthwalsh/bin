#ai-slop

# SPA Build Tools

See [[web]] layers: A build tool transforms source (TS, JSX, CSS, Markdown, images) into browser-ready assets and runs a local dev server during development.

## Features to care about

### Common requirements

**TypeScript + JSX** — Nearly universal now. All major tools handle this; the difference is *how* (transpiler only vs. full type-check vs. SWC vs. esbuild).

**Static SPA output** — Emits a `dist/` folder of HTML/JS/CSS that can be served from any CDN or static host with no server runtime required.

**Hot Module Replacement (HMR)** — On save, only the changed module updates in the browser without a full reload. Quality varies; some tools preserve component state, others don't.

**Dev server cold start** — How long from `npm run dev` to first page load. Matters more as the project grows past ~1k modules.

**Production build speed** — How long a CI build takes. Rust-based tools (SWC, esbuild) are 10–100x faster than JS-based equivalents.

**Plugin ecosystem** — How many community plugins exist. Vite's is the largest; Webpack-compatible tools (Rspack) reuse that older ecosystem.

### Niche / differentiating requirements

**Local HTTPS** — Required for testing Service Workers, Secure Cookies, and browser APIs that block on non-secure origins. Some tools have a one-flag solution; others need an external tool (`mkcert`).

**Error overlays / compile errors** — The quality of "something broke" feedback. Best tools show exact line, link to docs, suggest fixes. Worst tools show a raw stack trace or freeze the browser tab during error state.

**Markdown → HTML** — Importing `.md` files as components or HTML strings. Useful for docs sites or content-heavy SPAs. Ranges from first-class to "find a plugin."

**Windows support** — Rust-based native binaries can have path normalization bugs or missing feature parity on Windows/NTFS. Worth checking if the team is cross-platform.

**Framework-agnostic** — Some tools are tightly coupled to a meta-framework (Turbopack = Next.js). Using them outside that context means fighting the tool.

**Webpack migration path** — Teams with large existing Webpack configs need a drop-in or near-drop-in replacement, not a rewrite.

**Dev/prod parity** — Some tools use different engines for dev vs. production (e.g. Vite: esbuild dev + Rollup prod), which can produce "works in dev, breaks in build" surprises.

**Ownership / governance risk** — Venture-backed tools face exit pressure; features may be paywalled or pivoted toward the backer's platform. Community-led tools have no single point of failure but smaller R&D budgets.

---

## Tool summary

#ai-slop

| Tool                 | Static SPA                      | TS/JSX          | HMR quality              | Cold start (large)        | Local HTTPS                   | Error overlay                                | Markdown→HTML                             | Windows                    | Framework-agnostic       | Ownership                              |
| -------------------- | ------------------------------- | --------------- | ------------------------ | ------------------------- | ----------------------------- | -------------------------------------------- | ----------------------------------------- | -------------------------- | ------------------------ | -------------------------------------- |
| **Vite**             | ✅                               | ✅ esbuild       | ✅ fast, state-preserving | ⚠️ slows past ~5k modules | ⚠️ plugin or mkcert           | ✅ best-in-class, actionable                  | ⚠️ plugin                                 | ✅ stable                   | ✅                        | Community (independent)                |
| **Turbopack**        | ⚠️ via Next.js `output: export` | ✅ SWC           | ✅ very fast              | ✅ incremental Rust cache  | ✅ `--experimental-https` flag | ✅ good                                       | ⚠️ JS MDX plugins blocked in Rust context | ✅ Next.js normalizes paths | ❌ Next.js only           | Corporate — Vercel ($300M+)            |
| **Rspack / Rsbuild** | ✅                               | ✅ SWC           | ✅ fast                   | ✅ consistent at scale     | ✅ configurable                | ⚠️ good but Edge source maps can be slow     | ⚠️ `@rsbuild/plugin-mdx`                  | ✅                          | ✅ Webpack-compatible     | Corporate — ByteDance (internal infra) |
| **Parcel 2**         | ✅                               | ✅ auto-detected | ✅ good                   | ✅ aggressive cache        | ✅ `--https` flag, auto-cert   | ✅ server-side source maps, no browser freeze | ✅ first-class `.parcelrc`                 | ✅ native watcher           | ✅                        | Open source (sponsor-supported)        |
| **Farm**             | ✅                               | ✅ SWC           | ✅ ~10ms                  | ✅ best at scale           | ⚠️ plugin                     | ✅ good                                       | ⚠️ plugin                                 | ⚠️ less tested             | ✅ Vite-plugin compatible | Community (young)                      |
| **Bun**              | ✅                               | ✅ built-in      | ✅ fast                   | ✅                         | ⚠️ manual                     | ⚠️ basic                                     | ⚠️ `bun-plugin-markdown`                  | ⚠️ catching up             | ✅                        | Corporate — Oven (venture-backed)      |

### When to pick which

- **Default new SPA** → Vite. Largest ecosystem, best docs, most community answers.
- **Content-heavy / docs site** → Parcel. Native HTTPS + Markdown, minimal config.
- **Migrating from Webpack** → Rspack/Rsbuild. Keep existing loaders, get 10x speedup.
- **Already in Next.js** → Turbopack. Don't fight it.
- **Huge monorepo, speed is everything** → Farm or Rspack. Rust incremental cache wins at scale.
- **Avoid** if governance matters → Turbopack (Vercel), Bun (Oven) have exit-pressure risk.

### Things to watch

- Vite's **Rolldown** transition will replace both esbuild (dev) and Rollup (prod) with a single Rust engine, eliminating dev/prod divergence.
- **Snowpack** and **WMR** were once popular; both are now effectively abandoned — a reminder that fast-moving ecosystems leave tools behind.
