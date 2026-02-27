See [[PluginPhilosophy]] for evaluation criteria.

## Language-Agnostic Approaches

I came across [NullDeref's plog post about Rust](https://nullderef.com/blog/plugin-tech/) which discussed various non-language-specific ways:

- **Embedding a Runtime:** The host application embeds an scripting language interpreter (Lua/Python/JavaScript) or WebAssembly (WASM)
- **OS-Native Dynamic Loading:** Loading [[SharedLibraries]] (`.dll`, `.so`, `.dylib`) at runtime via `LoadLibrary` (Windows) or `dlopen` (*nix)
- **External Process IPC:** Start subprocess, then communicate via OS primitives: Sockets / Pipes / Shared Memory
- **Executable Prefixes:** Run tool following a specific naming convention (e.g. prefix: `git-standup`, `cargo-expand`).
    - Maybe not a plugin because has limited interaction, more for command discovery?

### Embedding a Runtime

#ai-slop

| Runtime | Binary Size Added | Startup Time | Notes |
|---------|:-----------------:|:------------:|-------|
| [Lua](https://www.lua.org/) | Very Low | Very Low | Core is famously tiny; exact size depends on stdlib included and strip flags; used in Neovim, WoW |
| [mruby](https://mruby.org/) | Low | Low | Ruby semantics, designed for embedding; size scales with which mrbgems you include |
| [QuickJS](https://bellard.org/quickjs/) | Low | Low | Lightweight JS engine, no JIT; size depends on unicode/bignum features |
| [V8](https://v8.dev/) | High | Medium | Full JIT; snapshots, i18n, and debug symbols can dramatically change size; used in Node/Electron |
| [CPython](https://www.python.org/) | High | High | libpython alone can be large; stdlib and extension modules add more |
| WASM micro-runtime ([wasm3](https://github.com/wasm3/wasm3), [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime)) | Very Low | Low | Interpreter-only, designed for constrained/embedded environments; language-agnostic plugins |
| WASM full runtime ([Wasmtime](https://wasmtime.dev/), [Wasmer](https://wasmer.io/)) | High | Low | JIT + full WASI support; release artifacts are in the 10–100+ MB range depending on distribution |

*Binary size and startup time vary a lot with: static vs dynamic linking, build flags (LTO/strip), enabled features, and platform.*

## Interpreted Languages (JS, Python)

These languages can often evaluate code from a custom file path, making basic plugin systems straightforward to implement.

- **[[vscode]] extensions:** Run in a separate extension host process and communicate with the main editor via an API. (See: [Extension Host](https://code.visualstudio.com/api/advanced-topics/extension-host))
- **[[obsidian.plugins]]:** Also based on JS, running in same nodeJS/WebView.
## [[CSharp|C#]]
Compile a DLL referencing interfaces defined by the host. The host then loads the DLL using Reflection.
## [[golang|go]]
Has a built-in [`plugin` package](https://pkg.go.dev/plugin) that supports loading shared object (`.so`) files. But it's pretty brittle: the plugin and host be compiled with the *exact same version* of the Go toolchain, build tags, flags, env vars, and dependencies, which can make it brittle.

```go
// plugin.go built with `go build -buildmode=plugin`
package main
import "fmt"

var V int
func F() { fmt.Printf("Hello, number %d\n", V) }

// host.go
import "plugin"

p, err := plugin.Open("plugin_name.so")
v, err := p.Lookup("V")
f, err := p.Lookup("F")
*v.(*int) = 7
f.(func())() // prints "Hello, number 7"
```
## Rust
https://docs.rs/libloading/latest/libloading/ makes Dynamic Loading easier.
## C/C++
See [[#Language-Agnostic]]
