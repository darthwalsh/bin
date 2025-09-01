[Exception handling (programming) - Wikipedia](https://en.wikipedia.org/wiki/Exception_handling_(programming))

## Exception types according to Lippert
[Vexing exceptions | Fabulous adventures in coding](https://ericlippert.com/2008/09/10/vexing-exceptions/)
- **Fatal** – unrecoverable system failures (e.g., out of memory, forced termination)
	- Best to let the program fail fast
- **Boneheaded** – caused by programmer mistakes (e.g., null reference, array index, bad logic)
	- Should be fixed in code, not caught
- **Vexing** – thrown in expected, non-exceptional situations (e.g., parsing user numeric input)
	- Often require frequent catching; better APIs could avoid this
- **Exogenous** – triggered by external factors (e.g., file locks, network issues)
	- Can’t be predicted; must be handled gracefully

## App vs Libraries
Apps can decide what exception model they have:
- for a script or batch job: it's reasonable to assume *all* exceptions are unrecoverable and let the OS clean up
- for a long-running service: you'll usually still want cleanup code for vexing, and sometimes strategic error recovery to keep serving requests

Libraries *cannot* decide an error is fatal; they need to raise the problem to the app.

## Resources to be cleaned up
[[CSharp]] marks these as `IDisposable` interface and has `using` statement, other languages often have naming patterns.

Some resources are always cleaned up at process exit:
- Memory
- Open files
- Network connections
- Process Handles
- Locks
  - Unnamed/private mutexes
  - Process-local semaphores
  - Thread-local condition variables

Other resources would be leaked forever:
- Temp files
- Child processes in background
- MySQL queries
- Locks
  - Named/shared mutexes
  - System-wide semaphores
  - Shared memory condition variables
  - File-based locks
  - Distributed network locks

## C
C doesn't have a language feature for cleanup, but also lacks exceptions.
```C
void query() {
  int success = sql_init(&mysql);
  if (success != 0) return;

  success = sql_connect(&mysql, "localhost"); // No try-catch needed on this line
  if (success != 0) return; // ⚠️ OOPS! Missed sql_close

  sql_close(&mysql);
}
```
If you return early from a function, you might miss some cleanup. Instead, you often `goto` to the cleanup code.

`longjmp` allows you to jump to a different point in the code, which can enable code patterns like `try/catch` blocks but without the stack unwinding and overhead. It is considered hacky though.

C famously will often not raise errors on mistakes, but instead enter Undefined Behavior. Newer languages are "safe" in they promise to raise an exception for incorrect memory access, but C doesn't have a runtime that can detect mistakes in pointer arithmetic or reinterpreting memory as different data types. 
## C++
[CPP wiki on exceptions](https://en.cppreference.com/w/cpp/language/exceptions)
C++ adds exceptions for i.e. out of memory errors, but *some apps turn them off* for various reasons: this would mean needing to check if `new` returned `nullptr`.

C++ has [[RAII]] idiom, which uses objects to manage resources. This ensures cleanup on early return, or a thrown exception.
A new gotcha is that destructors shouldn't throw exceptions.
## Java has checked exceptions
[[Java]] tried to add exceptions to the type system, with the carve-out that `RuntimeException` is unchecked. This leads to a problem similar to [[FunctionColor]] with async, where if an API wants to add `throws IOException` to a method, all callers need to either handle the exception or add the `throws IOException` to their own method signature.

In order to clean up any resource, now any throwing code must go into `try` blocks.

Avoid `return`ing from a `finally` block, because that overrides the current `return`ed value. 
## C# worker threads
[[CSharp|.NET]] Framework 1.1 [follows](https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/performance/exceptions-cause-apps-quit) the same behavior as Java: If a worker Thread raised an unhandled exception, it was ignored.
.NET 2.0 changed that to exit the process.
## Rust uses errors-as-values
In [[Rust]] returning `Result<T, E>` has an associated [operator](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#a-shortcut-for-propagating-errors-the--operator): ending an expression with `?` will either return the value from the `Ok` variant, or return an error from the `Err` variant (converted to the expected type).
## Go has the worst of both worlds
[[golang]] starts with the simple idea that errors should be returned as values, preventing complex control flow.
But as the [Go is still not good](https://blog.habets.se/2025/07/Go-is-still-not-good.html) blog post points out,
```go
    f.mutex.Lock()
    f.bar() // ⚠️ OOPS! Should defer unlock first
    f.mutex.Unlock()
```
...is unsafe because if `f.bar()` *panics* the locked mutex is leaked and the process could be in a bad state. If your app always tears down on panic that's probably fine, but most HTTP server frameworks will `defer()` to continue execution. A **panic-safe** (a.k.a. panic-resilient) library author writes code that handles an "exception" being thrown from any function call, even if they have no occasion to panic themselves.

Additionally, a go library starting a goroutine needs to defer any panics when starting a new goroutine to ensure panics don't crash the app.

Errors in resource cleanup are also complicated. Adding just `defer f.Close()` will swallow any returned error; to return the error can assign to the `err` variable that's the **named** return value:
```go
func writeFile(path string) (err error) {
    f, err := os.Create(path)
    if err != nil {
        return err
    }

    defer func() {
        if cerr := f.Close(); cerr != nil {
            err = errors.Join(err, cerr)
        }
    }()
    
    // ⚠️ From here on, *DO NOT* redeclare `err := ` which shadows the named return
    _, err = f.Write([]byte("hello"))
    return err
}
```
