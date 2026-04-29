# PLAN: PowerShell RAII / Scope Cleanup Without Extra Nesting

## Problem

C# 8 has `using var` declarations — cleanup runs at enclosing scope exit, no extra braces:

```csharp
void Foo() {
    using var guard = new ScopedDir(path);  // pushd
    DoWork();                               // flat, no nesting
    Console.WriteLine("Done");
}   // guard.Dispose() called here — no try/finally visible
```

The desired PowerShell equivalent:

```powershell
function foo {
    using $guard = Scoped-Location "/tmp"   # pushd /tmp, return scope guard
    Do-Work                                 # flat — no extra braces
    echo "Done"
}   # on scope exit: popd
```

**What I want:** resource acquisition + automatic cleanup registration in one statement, with the rest of the function body flat (no scriptblock nesting, no manual paired calls).

**What PowerShell has today:** no way to do this. Every existing solution either (a) wraps the body in a scriptblock (`Use-Location $path { ... }`), or (b) requires manually writing paired setup/cleanup in separate locations.

## Prior Art in PowerShell

### `clean` block (PowerShell 7.3+, shipped)

[RFC #207](https://github.com/PowerShell/PowerShell-RFC/pull/207) added a [`clean` block](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods?view=powershell-7.5#clean) — a peer to `begin`, `process`, `end` that runs on scope exit (normal, error, Ctrl+C, `Select-Object -First`):

```powershell
function foo {
    end {
        Push-Location "/tmp"
        Do-Work
        echo "Done"
    }
    clean {
        Pop-Location
    }
}
```

**What this solves:** scope-exit hook exists; cleanup runs even on terminating errors.

**What it doesn't solve:**
- Setup and cleanup are decoupled — `Push-Location` in `end`, `Pop-Location` in `clean`, violating the RAII principle of pairing acquisition with cleanup at the declaration site
- Requires wrapping body in `end {}` (once you use any named block, *all* code must be in named blocks)
- Multiple resources need manual reverse ordering in `clean`
- No automatic Dispose of IDisposable objects

### Issue [#9886](https://github.com/PowerShell/PowerShell/issues/9886) (closed, no activity)

Requested C#-style `using` keyword. Discussion ran 2019-2023, closed by bot for inactivity. Key takeaways:
- @BrucePay (PowerShell team): "the `using` discussion comes up every couple of years and fades away... hard to sustain energy around this issue"
- @markekraus showed nested IDisposable code as motivation (multiple try/finally blocks for TcpClient + SslStream)
- @SeeminglyScience noted safety issues with cmdlet-based `using` (pipeline stop exceptions can fire before assignment completes; keyword would let compiler generate safer code)
- **No RFC was written; no design was agreed on**

### The `using` keyword is already taken

PowerShell uses `using` for `using namespace`, `using module`, `using assembly`. A `using var` declaration would need to coexist with these — feasible (C# did the same) but adds parser complexity.

## Gap Analysis

| Requirement | `try/finally` | `Use-Location { }` | `clean` block | Desired `using var` |
|---|---|---|---|---|
| Cleanup on throw | Yes | Yes | Yes | Yes |
| No extra nesting | No | No | Partial (need `end {}`) | Yes |
| Setup+cleanup paired | Yes (manual) | Yes (in helper) | No (decoupled) | Yes |
| Multiple resources in LIFO order | Manual | Nested helpers | Manual | Automatic |
| Works for arbitrary IDisposable | Yes (manual) | No (per-resource helper) | Yes (manual) | Yes |

---

## Solution Approaches

### Approach 1: `clean` block + scope guard convention (no tooling, works today)

Use `clean` block with a helper that pairs setup and cleanup in a single call, storing guards in a list:

```powershell
$script:_guards = [System.Collections.Generic.Stack[scriptblock]]::new()

function Register-ScopeGuard([scriptblock]$Cleanup) {
    $script:_guards.Push($Cleanup)
}

function foo {
    end {
        Push-Location "/tmp"
        Register-ScopeGuard { Pop-Location }
        Do-Work
    }
    clean {
        while ($script:_guards.Count -gt 0) { & $script:_guards.Pop() }
    }
}
```

**Tradeoffs:**
- (+) Works today on pwsh 7.3+, no tooling
- (+) LIFO ordering is automatic (stack)
- (-) Still decoupled: `Push-Location` and `Register-ScopeGuard` are two statements
- (-) Boilerplate `clean` block in every function
- (-) `$script:_guards` scope leaks across nested calls (need per-call-frame isolation)

### Approach 2: Source-to-source preprocessor (like [[python.option-chaining-extension.PLAN|Python `?.` extension]])

Write a transpiler that rewrites `using $guard = <expr>` into equivalent PowerShell. The transformation:

```powershell
# Input (.ps1w or custom extension)
function foo {
    using $guard = Scoped-Location "/tmp"
    using $stream = [IO.FileStream]::new($path, 'Open')
    Do-Work $stream
    echo "Done"
}

# Output (.ps1)
function foo {
    end {
        $guard = Scoped-Location "/tmp"
        $stream = [IO.FileStream]::new($path, 'Open')
        Do-Work $stream
        echo "Done"
    }
    clean {
        if ($null -ne $stream -and $stream -is [System.IDisposable]) { $stream.Dispose() }
        if ($null -ne $guard -and $guard -is [System.IDisposable]) { $guard.Dispose() }
    }
}
```

**Transformation rules:**
1. Collect all `using $var = <expr>` statements from the function body
2. Strip the `using` keyword, leaving `$var = <expr>` in place
3. Generate a `clean` block with `Dispose()` calls in reverse declaration order
4. If function already has named blocks (`begin`/`process`/`end`), insert into the appropriate block
5. If function body has no named blocks, wrap body in `end {}`

**Tooling required** (modeled after the [[python.option-chaining-extension.PLAN|Python `?.` plan]]):

| Component | Effort | Notes |
|---|---|---|
| Token-level rewriter | Medium | PowerShell's `[Parser]::ParseInput()` gives AST; `tokenize` gives token stream. `using` *already parses* as a keyword, which is both helpful (easy to find) and problematic (parser may reject unrecognized `using` forms) |
| CLI tool (`pswu compile`) | Low | Wrapper around the rewriter |
| Import hook / dot-sourcing proxy | Medium | `$ExecutionContext.InvokeCommand` or custom module loader to compile-on-import |
| Editor support | High | See below |
| PSScriptAnalyzer rule | Low | Custom rule to warn on `using $var =` in uncompiled files |

**Tradeoffs:**
- (+) Achieves exact desired syntax
- (+) Output is standard PowerShell (debuggable, compatible)
- (-) New file extension or pragma needed (`.ps1w`, `#requires -UsingDeclarations`, etc.)
- (-) Editor tooling gap: IntelliSense, debugging, Go-to-Definition all operate on `.ps1` — custom extension needs LSP proxy or pre-compilation step
- (-) Source maps needed for debugging (breakpoints hit compiled code, not source)
- (-) Maintenance burden: must track PowerShell parser changes across versions

### Approach 3: PSScriptAnalyzer custom rule + auto-fix (code transform, not runtime)

Write a PSScriptAnalyzer rule that:
1. Detects paired patterns (e.g., `Push-Location` without matching `Pop-Location` in `finally`/`clean`)
2. Offers a code fix that generates the `clean` block

This doesn't give new *syntax* — it's a linter/auto-fixer for the existing `clean` block pattern.

**Tradeoffs:**
- (+) No custom parser, no new file format
- (+) Integrates with existing editor tooling (VS Code PowerShell extension uses PSScriptAnalyzer)
- (-) Doesn't achieve the desired syntax — just makes existing patterns easier to apply
- (-) Can only detect known paired patterns (Push/Pop-Location, IDisposable), not arbitrary guards

### Approach 4: PowerShell class implementing IDisposable + hope for language evolution

Write `ScopedLocation` as a PowerShell class implementing `IDisposable`:

```powershell
class ScopedLocation : System.IDisposable {
    [string]$Previous
    ScopedLocation([string]$path) {
        $this.Previous = (Get-Location).Path
        Set-Location $path
    }
    [void] Dispose() { Set-Location $this.Previous }
}
```

Then lobby for `using var` syntax in a future PowerShell RFC.

**Tradeoffs:**
- (+) The IDisposable class is useful regardless
- (+) If PowerShell ever adds `using var`, the class "just works"
- (-) No timeline — issue #9886 was closed for inactivity, PowerShell team called it "meh"
- (-) Meanwhile, you're stuck with `try/finally` or `clean` block

---

## Risks

**Parser conflict with `using` keyword**: PowerShell already parses `using` for namespace/module/assembly. A `using $var = ...` form might be parseable (distinct from `using namespace ...` by the `$` sigil), but this is **unverified** — the parser might reject it before any preprocessor can intercept.

Mitigation: if the PowerShell parser rejects `using $var =`, the preprocessor must operate at the *token* level (before parsing), or use a different keyword (`defer`, `scoped`, `guard`).

**`clean` block limitations**: `clean` runs after the pipeline ends, not at arbitrary scope boundaries. It's *function-scoped*, not *block-scoped*. You can't `using` a resource inside an `if` or loop and have it clean up at that inner scope's exit — only at the function's exit.

**Debugging**: source-to-source transforms mean breakpoints, stack traces, and error messages reference the compiled output, not the source. Without source maps, this is confusing.

**Community adoption**: a custom PowerShell dialect (`.ps1w`) has near-zero chance of community adoption. The Python `?.` plan has the same risk but PEP 505 provides social proof; PowerShell has no equivalent RFC momentum.

## Ecosystem Comparison

| | Python `?.` (PEP 505) | PowerShell `using var` |
|---|---|---|
| Language proposal exists | Yes (PEP 505, deferred) | Issue #9886 (closed, no RFC) |
| Parser rejects new syntax | Yes (`?.` is invalid Python) | Uncertain (`using $var =` may or may not parse) |
| Token-level rewrite viable | Yes (`tokenize` module) | Yes (`[Parser]::Tokenize()`) |
| AST available post-rewrite | Yes (`ast` module) | Yes (`[Parser]::ParseInput()`) |
| Import hook mechanism | Yes (`sys.meta_path`) | Possible (`$ExecutionContext` / module loader) |
| Editor story | VS Code + extension | VS Code PowerShell extension (single dominant editor) |
| Community size for custom dialects | Very small | Effectively zero |

## Recommendation

**Short-term (today):** Use Approach 1 — `clean` block + `ScopedLocation` class. Accept the `end {} / clean {}` boilerplate. It works, it's safe, and other PowerShell devs can read it.

**Medium-term (if the itch persists):** Prototype Approach 2 — a minimal preprocessor. Start with the token rewriter only (no import hook, no editor support). Test whether `using $var =` even tokenizes. If the parser rejects it, try `scoped $var =` or a `#pragma using-declarations` opt-in.

**Long-term:** An RFC for `using var` in PowerShell has better leverage than a custom dialect. The `clean` block (shipped in 7.3) proves the team cares about the scope-exit side; the missing piece is *automatic Dispose registration at declaration*. An RFC building on #9886 + `clean` has a credible story.

## Unresolved Questions

- [ ] Does `[Parser]::Tokenize()` accept `using $var = expr` or reject it? (determines whether preprocessor can work at token level vs needs raw text manipulation)
- [ ] Could a PSReadLine handler or profile hook intercept `using $var =` at the REPL level before the parser sees it?
- [ ] Is there appetite in the PowerShell team to reopen the `using` discussion now that `clean` block exists as the scope-exit primitive?

## Related

- [[programming.meta]] — taxonomy of macro/metaprogramming approaches; this is a Category 1 (token-level) or Category 2 (AST) transform
- [[python.option-chaining-extension.PLAN]] — same engineering shape: custom syntax → token rewrite → standard output
- [[pwsh]] — general PowerShell notes
- [PowerShell #9886](https://github.com/PowerShell/PowerShell/issues/9886) — original `using` statement request
- [PowerShell RFC #207](https://github.com/PowerShell/PowerShell-RFC/pull/207) — `clean` block RFC (merged, shipped in 7.3)
