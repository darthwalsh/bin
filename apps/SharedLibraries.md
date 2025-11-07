#ai-slop
How do you compile your Rust/Go/C++ into a `.dll`/`.so`/`.dylib` that exposes a C-compatible API?

## When do you need this?
- Replacing legacy C libraries with memory-safe alternatives
- Creating [[lang.plugin|plugins]] for applications expecting C APIs

## Language Comparison

| Language           | Runtime & GC           | Initialization                      | Binary Size | Best Use Case                        |
| ------------------ | ---------------------- | ----------------------------------- | ----------- | ------------------------------------ |
| **Rust**           | ✅ No GC               | ✅ Instant (~1ms)                   | Small       | Memory safety + performance critical |
| **Go**             | ✅ Bundled             | ✅ Auto (~10ms)                     | Medium      | Fast development, easy concurrency   |
| **C/C++**          | ✅ No runtime          | ✅ Instant (no runtime)             | Smallest    | Maximum control, legacy C++ code     |
| **C# (NativeAOT)** | ⚠️ .NET 6+ only        | ✅ Auto (tens of ms)                | Larger      | Existing .NET codebase               |
| **C# (CLR Host)**  | ❌ External dependency | ❌ Manual `ICLRRuntimeHost2` (high) | Smaller DLL | Legacy .NET, avoid if possible       |
| **Python/Java**    | ❌ Not suitable        | ❌ Complex / High overhead          | N/A         | Might be posible with GraalVM Native Image |

### Rust

**Tutorial**: [The Rust FFI Omnibus](https://jakegoulding.com/rust-ffi-omnibus/) - comprehensive guide with examples

**Quick example**:
```rust
#[no_mangle]
pub extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

```toml
# Cargo.toml
[lib]
crate-type = ["cdylib"]
```

**Why Rust?**
- No garbage collector = predictable performance
- Zero-cost abstractions
- Smallest binaries after C/C++
- Best FFI story among memory-safe languages

**Header files**: Manual or use [`cbindgen`](https://github.com/mozilla/cbindgen) to auto-generate from Rust code.

**Gotcha**: Borrow checker is conservative about allowing mutations.

### Go

**Tutorial**: [Building shared libraries in Go: Part 1](https://darkcoding.net/software/building-shared-libraries-in-go-part-1/)

**Quick example**:
```go
package main

import "C"

//export Add
func Add(a, b C.int) C.int {
    return a + b
}

func main() {} // Required but not called
```

```bash
go build -buildmode=c-shared -o libadd.so
```

**Why Go?**
- Runtime **auto-initializes** when DLL loads - no manual setup needed
- Embedded GC and scheduler included in the binary
- Great for concurrent workloads (goroutines)
- Faster to write than Rust

**Header files**: Automatically generated! Building creates both the `.so` and `.h` files.

**Gotchas**:
- Can't safely call Go from arbitrary OS threads

### C++

**Tutorial**: [Creating and Using Shared Libraries](https://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html) - The Linux Documentation Project

**Quick example**:
```cpp
// Must use extern "C" to prevent name mangling
extern "C" {
    __declspec(dllexport)
    int add(int a, int b) { 
        return a + b;
    }
}
```

```bash
# Linux
g++ -shared -fPIC -o libadd.so add.cpp

# macOS
clang++ -dynamiclib -o libadd.dylib add.cpp


# Windows
cl /LD add.cpp
```

**Why C++?**
- Full control over ABI
- Existing C++ codebases

**Header files**: Write the `.h` file manually.

**Gotcha**: Remember `extern "C"` or C won't find your symbols (name mangling).

### ⚠️ C#

**Tutorial**: [Native exports with NativeAOT](https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/) - Official Microsoft docs

**Requires .NET 6+ and NativeAOT**:
```csharp
using System.Runtime.InteropServices;

public class Exports
{
    [UnmanagedCallersOnly(EntryPoint = "Add", CallConvs = new[] { typeof(CallConvCdecl) })]
    public static int Add(int a, int b) => a + b;
}
```

```bash
dotnet publish -r win-x64 -c Release -p:PublishAot=true -p:NativeLib=Shared
```

**Header files**: Write the `.h` file manually declaring your exported functions. ([Feature requested](https://github.com/dotnet/runtime/issues/100747))

**Why not C# usually?**
- NativeAOT is still maturing
- Only works with .NET 6+

**When C# makes sense**: You already have a large C# codebase and need to expose a few functions.
#### ❌ Without NativeAOT

You must manually host the CLR using the [CLR Hosting API](https://learn.microsoft.com/en-us/dotnet/core/tutorials/netcore-hosting). This is complex and error-prone!

## Gotchas

### String Handling
All languages use different string representations:
- **C**: `char*` (null-terminated)
- **Rust**: `&str` (UTF-8 slice) or `String` (owned) → Use `CString` for FFI
- **Go**: `string` (similar to Rust) → Use `C.CString()` for FFI
- **C#**: `string` (UTF-16) → Use `Marshal.PtrToStringUTF8()` for FFI
    - Don't use `[MarshalAs(UnmanagedType.LPStr)]` that's for P/Invoke

### Threading
- **Go**: Recent Go runtime attaches the calling thread
    - In the past, it was important not to call Go functions from arbitrary native threads
- **Rust**: Safe by default - ownership prevents data races
- **C++**: Your problem to solve

### Callbacks from C into Your Language
- **Rust**: ✅ Works naturally with function pointers
- **Go**: *On Windows* ⚠️ Complex - requires `syscall.NewCallback()` and limitations
- **C#**: ⚠️ Use `[UnmanagedFunctionPointer]` and be careful with GC

### Freeing Memory
Always free memory using the same runtime that allocated it.
See [Allocating and freeing memory across module boundaries - The Old New Thing](https://devblogs.microsoft.com/oldnewthing/20060915-04/?p=29723)
