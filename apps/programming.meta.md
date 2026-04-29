#ai-slop
# Metaprogramming

Metaprogramming = programs that manipulate other programs (or themselves). Classify by **what representation you manipulate** and **when it happens**.

## 8-Category Taxonomy

### 1. Text/token-level generation

Manipulation: raw source text or token stream, no structural awareness.

Examples: C preprocessor (`#define`), template engines (Jinja, Mustache), codegen from schemas (OpenAPI, protobuf, gRPC), scripts that emit code.

Pros: simple, language-agnostic. Cons: brittle — no hygiene, no type awareness, easy to generate syntactically invalid output.

### 2. AST macros and syntactic extensions

Manipulation: the parsed syntax tree, with language-level support.

Examples: Lisp/Scheme `defmacro`, Rust `macro_rules!` + proc-macros, Elixir macros, Julia macros, Nim macros/templates.

This is the sweet spot for user-defined syntactic sugar. See [[#Language macro capability survey]] for which languages support what.

### 3. Type-level / compile-time computation

Manipulation: the type system itself; "programs" run inside the typechecker.

Examples: C++ templates (Turing-complete), Haskell type families and GADTs, Scala 3 inline/metaprogramming, dependent types (Idris, Lean).

### 4. Compile-time evaluation / staging

Manipulation: values known at build time; generates specialized code.

Examples: C++ `constexpr`, Zig `comptime`, D `CTFE`, multi-stage programming (MetaML), Rust [`crabtime`](https://docs.rs/crabtime) (compile-time fn execution that emits code, inspired by `comptime`; distinct from `macro_rules!` pattern matching and proc-macro token manipulation).

Distinct from (3): you're evaluating *expressions*, not types.

### 5. Reflection and runtime metaprogramming

Manipulation: live objects and program structure at runtime.

Examples: Java/C# reflection, Python metaclasses, Ruby `method_missing`, dynamic proxy generation, JVM bytecode emission (ASM, ByteBuddy), JIT specialization.

### 6. Compiler metaprogramming

Manipulation: the compiler's internal representations (AST, IR, backend).

Sub-categories:
- **Frontend transforms** — macros, desugaring, syntactic sugar lowering
- **IR passes** — optimizations, instrumentation (sanitizers, profiling), analysis
- **Backends/codegen** — target-specific lowering, instruction selection
- **Compiler plugins** — custom linting, domain checks, code rewriting (Clang plugins, GHC plugins, Kotlin compiler plugins)
- **Source-to-source compilers** — transpilers (TypeScript → JS, Babel, CoffeeScript)

### 7. Proof/verification as programming

Manipulation: proof terms and logical propositions; "runtime" is a logic engine/checker.

Examples: Lean, Coq, Isabelle tactic scripts; SMT-based verification (Dafny, F*); extracting executable code from proofs (Curry-Howard correspondence).

Not a lesser kind of programming — full control flow, abstraction, termination concerns, and performance issues. Different *semantic domain* (logic instead of effects).

### 8. Language workbenches and DSL pipelines

Manipulation: a grammar + semantics definition; output is an interpreter, compiler, or code generator.

Examples: ANTLR, MPS, Xtext; Racket `#lang`; a knitting-pattern DSL compiled to SVG; SQL as a DSL compiled to a query plan; shaders as DSLs compiled to GPU bytecode.

Key insight: DSL pipelines are *everywhere* — SQL, shaders, IaC (Terraform, Ansible), regex, proof scripts, ML compute graphs. The "knitting DSL" mental model generalizes broadly.

---

## Language Macro Capability Survey

The two key axes for user-defined syntactic sugar:

- **A. Token-stream rewrite** — can you intercept and rewrite the raw token stream before parsing? (i.e., extend the grammar without sigils/markers at each use)
- **B. Non-local AST rewrite** — can you rewrite a whole function body from a single annotation? (e.g., `using cleanup();` statements get wrapped into nested `try/finally` by the macro)

| Language | Token-stream rewrite (A) | Non-local AST rewrite (B) |
|---|---|---|
| **Common Lisp / Racket** | Yes — reader macros extend the reader/parser | Yes — `defmacro` can rewrite entire forms |
| **Scheme (portable)** | Mostly no (implementation-specific reader hacks) | Yes — `syntax-rules`, `syntax-case` |
| **Raku (Perl 6)** | Yes — grammar rules are first-class and user-extensible | Yes |
| **Nim** | Approximately — flexible surface syntax; templates/macros can feel keyword-like, but not truly arbitrary token rewriting | Yes — macros can rewrite whole proc bodies |
| **Elixir** | No — macro call sites still need to parse as valid Elixir | Yes — macros can rewrite whole `do...end` blocks; can redefine `def` at the module level |
| **Julia** | No — `@macro` sigil required at each use | Yes — `@macro function ... end` rewrites the whole body |
| **Rust** | No — `macro!()` sigil or `#[attr]` required | Yes — proc-macro attribute (`#[my_attr]`) rewrites the whole function. [`crabtime`](https://docs.rs/crabtime) adds a third mode: inline compile-time fn execution (cat. 4), not AST rewriting |
| **Scala** | No — no user keywords | Yes — macro annotations (Scala 2) or `inline`/Quotes (Scala 3) can rewrite method bodies |
| **Haskell** | No — quasiquotes are delimited forms | Partially — GHC plugins can, but that's outside normal "language feature" path |
| **C# (Roslyn)** | No | No — source generators *add* code; they don't rewrite existing AST |
| **Ruby** | No — no grammar extension | No — DSLs via methods only (very expressive, but no AST rewriting) |

**Bottom line:** only Common Lisp, Racket, and Raku can honestly claim "new keyword with no per-site marker" because they expose the reader/tokenizer pipeline. Everyone else needs *some* sigil, attribute, or marker.

### Concrete capability comparison

Three test cases, rated per language:

| | New keyword (`until` → `while (!)`) | Arbitrary grammar tweak (e.g. trailing comma) | `using` keyword wrapping block in `try/finally` |
|---|---|---|---|
| Common Lisp | Yes | N/A (no commas) | Yes |
| Racket | Yes | N/A (no commas) | Yes |
| Raku | Yes | Yes (grammar rules) | Yes |
| Nim | Yes (keyword-like via templates) | Yes (believed supported) | Yes |
| Elixir | Yes (macro can define `until ... do ... end`) | Unspecified | Yes (macro expands to `try/after`) |
| Rust | No (`using!()` sigil needed) | Yes (already allowed) | No (can do `using!(...)`, not a keyword) |
| Julia | No (`@using` sigil needed) | Yes (believed supported) | No (`@using ...` not a keyword) |
| Scala | No | Yes (Scala 3) | No |
| C# | No | Yes (already allowed) | No |
| Ruby | No | Yes (already allowed) | No |

### PoC implementations

For the four languages of interest (Common Lisp, Rust, Nim, Scala), showing: (1) token-stream rewrite where supported, (2) non-local AST rewrite for RAII-via-`using`.

**Common Lisp** — reader macro + `defun/using` that rewrites leading `(using ...)` statements into LIFO `unwind-protect`:

```lisp
; Run: sbcl --script poc.lisp
(set-macro-character #\[ (get-macro-character #\())  ; [ reads as (
(set-macro-character #\] (get-macro-character #\)))

(defmacro until (test &body body)
  `(loop while (not ,test) do (progn ,@body)))

(defmacro defun/using (name args &body body)
  (labels ((using-form-p (x) (and (consp x) (eq (car x) 'using)))
           (unwrap-using (x) (cadr x)))
    (let ((guards '()) (rest body))
      (loop while (and rest (using-form-p (car rest))) do
        (push (unwrap-using (pop rest)) guards))
      (let ((core `(progn ,@rest)))
        (dolist (gexpr guards core)
          (let ((g (gensym "GUARD-")))
            (setf core `(let ((,g ,gexpr)) (unwind-protect ,core (funcall ,g)))))))
      `(defun ,name ,args ,core))))
```

**Rust** — `#[using]` proc-macro attribute rewrites function body; leading `using!(expr);` statements become `let _guardN = expr;` (drop order is reverse = LIFO RAII):

```rust
// in proc-macro crate: scan leading using!(...) stmts, rewrite to let _guardN = ...
#[proc_macro_attribute]
pub fn using(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let mut f = parse_macro_input!(item as ItemFn);
    let mut guards: Vec<Expr> = Vec::new();
    // collect leading `using!(expr);`, replace with `let _guardN = expr;`
    // ...
}

// usage
#[using]
fn foo() {
    using!(cleanup("a"));
    using!(cleanup("b"));
    println!("work");
    // expands to: let _guard0 = cleanup("a"); let _guard1 = cleanup("b"); ...
    // drop order: _guard1 then _guard0 (LIFO)
}
```

**Nim** — `usingProc` macro rewrites the proc body; Nim's deterministic destruction (`=destroy`) handles LIFO cleanup automatically:

```nim
# Run: nim c -r poc.nim
import macros

template until(cond: untyped, body: untyped) =
  while not(cond):
    body

macro usingProc(p: untyped): untyped =
  # collect leading `using <expr>` -> `let _uN = <expr>`; rest of body unchanged
  # Nim's `=destroy` called in reverse declaration order automatically
  ...

usingProc:
  proc foo() =
    using cleanup("a")
    using cleanup("b")
    echo "work"
    # destroy b, then destroy a
```

**Scala 2** — `@using` macro annotation rewrites method body; leading `using(cleanup())` calls become `val __uN = ...` + `try { rest } finally { __u1.close(); __u0.close() }`:

```scala
// Scala 2 + paradise plugin / -Ymacro-annotations
class using extends StaticAnnotation {
  inline def apply(defn: Any): Any = meta {
    // split stats into leading `using(x)` calls and the rest
    // emit: val __uN = x; try { rest } finally { closes in reverse }
  }
}

@using
def foo(): Unit = {
  using(cleanup("a"))
  using(cleanup("b"))
  println("work")
}
```

---

## Related

- [[programming.environments]] — the 6-axis framework; metaprogramming fits into Axis E (toolchain / "when is computation")
- [[lang.plugin]] — plugin *system* mechanisms (shared libs, IPC, embedded runtimes) — distinct from in-language macros
- [[pwsh.raii.PLAN]] — PowerShell's closest equivalent patterns
- [[python.option-chaining-extension.PLAN]] - Extending python syntax
