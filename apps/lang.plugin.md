I'm interested in comparing how you can write plugins in different language.

## Language-Agnostic
I came across [NullDeref's plog post about Rust](https://nullderef.com/blog/plugin-tech/)  which discussed various non-language-specific ways:
- Embedding a scripting language
	- Something trivial like lua
	- WebAssembly is closer to a bytecode intepreter
- OS-native IPC primitives:
	- sockets
	- pipes
	- shared memory
- OS-native dynamic loading, i.e. `LoadLibrary` or `dlopen`
- Execute command with fixed prefix, e.g. `cargo-expand` or `gh-copilot` or `git-standup`
## Interpreted languages (JS, Python)
Basically, can just `import` from a custom file path

- [[vscode]] has extensions
	- https://code.visualstudio.com/api/advanced-topics/extension-host
- [[obsidian.plugins]]
## [[CSharp|C#]]
Compiling a DLL, can be loaded with Reflection, and cast to interface
## [[golang|go]]
https://pkg.go.dev/plugin
>using exactly the same version of the toolchain, the same build tags, the same values of certain flags and environment variables.
>Build with `go build -buildmode=plugin`

```go
// plugin.go
package main
import "fmt"

var V int
func F() { fmt.Printf("Hello, number %d\n", V) }

// host
p, err := plugin.Open("plugin_name.so")
v, err := p.Lookup("V")
f, err := p.Lookup("F")
*v.(*int) = 7
f.(func())() // prints "Hello, number 7"
```
## Rust
https://docs.rs/libloading/latest/libloading/ makes Dynamic Loading easier.
## C
See [[#Language-Agnostic]]