## Interpreted languages (JS, Python)
Basically, can just `import` from a custom file path

- [[vscode]] has extensions
	- https://code.visualstudio.com/api/advanced-topics/extension-host
- [[obsidian.plugins]]

## [[csharp|C\#]]
Compiling a DLL, can be loaded with reflection, and cast to interface

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
- [ ] read about https://nullderef.com/blog/plugin-tech/
- [ ] https://docs.rs/libloading/latest/libloading/

## C
Can use OS-native functionality i.e. LoadLibrary