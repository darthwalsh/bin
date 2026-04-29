#ai-slop
# Programming Environments

A "programming environment" conflates three distinct notions:

1. **Where code runs** (execution host / substrate)
2. **How code gets there** (packaging, deployment, trust model)
3. **How you express computation** (language + toolchain + programming model)

Docker vs WSL2 is mostly (2). "Pure functional" is mostly (3). Web frontend is a genuinely different (1) + (2) + (3).

## 6-Axis Classification

Any programming situation can be located as a point in this space:

**A. Execution host** — what actually executes your code
- Bare metal (CPU resets into your code; no OS)
- Kernel/privileged mode (ring 0, drivers, hypervisor)
- Userland process (normal OS process)
- Managed VM (JVM, CLR, BEAM, Lua VM)
- Embedded interpreter (scripting engine inside a larger program)
- Sandbox runtime (browser, WASM/WASI, plugin sandbox, TEE enclave)
- Data engine (SQL/query engine, spreadsheet calc engine)
- Accelerator (GPU/TPU/NPU/FPGA fabric)
- Consensus VM (smart contracts, deterministic replicated execution)

**B. Capability/trust model** — what your code is allowed to do
- Full machine privileges vs sandboxed
- Capability-based permissions (mobile, browser extensions, cloud IAM)
- Determinism required (blockchains, some simulations)
- Resource metering (gas, time quotas, memory quotas, no syscalls)

**C. Trigger model** — how code runs
- Batch/CLI
- Interactive REPL
- Request/response (HTTP, RPC)
- Event loop callbacks (browser/UI)
- Streaming (pub/sub, reactive)
- Real-time control loop (robotics/RTOS)
- Transactional (DB triggers/procedures)
- Distributed consensus step (blockchain)
- Scheduled jobs / cron / workflow DAG

**D. State model** — where state lives
- Purely in-memory ephemeral
- Local persistent (files, keychain, registry)
- Shared durable store (DB, object store)
- Append-only log/event sourcing
- Replicated state machine (blockchains)
- Snapshot/image-based world (Smalltalk/Lisp Machine style)

**E. Toolchain / "when is computation"**
- Interpretation (runtime)
- AOT compilation (build time)
- JIT (runtime compilation)
- Synthesis/Place-and-route (FPGA)
- Graph compilation (ML/XLA/TVM style)
- Proof checking/verification (typechecker + proof engine)
- Code generation (build-time generators)

**F. Deployment topology**
- Single device/process
- Client-server
- Microservices/service mesh
- Edge + cloud
- P2P
- HPC cluster
- Air-gapped / high-assurance

### Quick classification checklist

When encountering something new:
1. What executes it? (CPU? VM? DB engine? browser? consensus VM? FPGA fabric?)
2. What's the capability/sandbox model? (files? network? syscalls? determinism? quotas?)
3. How is it triggered? (event loop, request, schedule, transaction, real-time loop)
4. Where does state live? (files, DB, chain state, image, ephemeral)
5. When does computation happen? (build time, runtime, compile time, proof time, synthesis)
6. How does it scale/distribute? (single host, cloud, edge, P2P, cluster)
7. What are the dominant constraints? (latency, throughput, safety, battery, gas, memory, certification)

---

## 15 Regions (by execution host)
- [ ] These regions should be classified into a tighter abstractions

### 1. Bare-metal, firmware, and tiny embedded

Examples: microcontrollers (Arduino, STM32), bootloaders, BIOS/UEFI, TI-BASIC, RTOS tasks.

Distinct because: no OS services, strict memory/CPU, hardware registers, interrupts, often real-time.

### 2. Kernel, drivers, and privileged instrumentation

Examples: kernel modules, hypervisors, eBPF programs, DTrace probes, security/EDR agents hooking via trampolines.

Distinct because: privilege level, stability constraints, strict ABI, difficult debugging.

Note: "hooking via trampolines" is a *technique* (instrumentation + trust boundary), not its own environment.

### 3. Userland native apps

Examples: Windows/macOS/Linux/Pi, CLI tools, daemons, desktop GUIs.

The "Pi vs Mac vs Windows" feeling is mostly POSIX vs Win32 ABIs + tooling differences — all in the same broad region.

### 4. Containers, WSL2, VMs, dev environments

Examples: Docker, Podman, WSL2, Nix shells, devcontainers.

Mostly *packaging, isolation, reproducibility*. Code is still in region 3 — what changes is the delivery and isolation layer.

### 5. Managed runtimes and language VMs

Examples: JVM, .NET CLR, BEAM (Erlang/Elixir), Node/Deno, Python/Ruby interpreters.

Distinct because: GC, reflection, dynamic loading, different concurrency models (actors, green threads), portability. BEAM's supervision trees and Haskell's purity model make the runtime shape the programming model strongly.

### 6. Browser and web sandbox

Examples: JS/TS frontend, WASM in-browser, Service Workers, Chrome extensions, WebGPU shaders.

Distinct because: origin-based security model, event loop + async-by-default, capability-mediated APIs (no arbitrary file/network), code delivered over the network.

This is a *special case of region 8* (code inside other programs), but browsers are an unusually opinionated, standardized, and security-heavy host.

### 7. Mobile app platforms

Examples: iOS/Android apps, background services, mobile UI frameworks.

Distinct because: forced lifecycle control (suspension, app death) is a real programming model constraint, not just an ops constraint. Beyond battery/network restrictions — tight sandbox, code signing, distribution model.

### 8. Code inside other programs (plugin and scripting hosts)

Examples: CAD plugins, Photoshop plugins, game engine scripting (Lua, C#, GDScript), Excel/VBA, Emacs Lisp, embedded Python in apps.

The "OS" is the host application: it defines APIs, object models, lifecycle, and constraints. See [[lang.plugin]] for plugin mechanisms.

### 9. Databases and query engines

Examples: SQL stored procedures, triggers, UDFs, Redis Lua scripts, analytic SQL, GraphQL resolvers.

Distinct because: transactional semantics, concurrency control, execution plans, set-based thinking, data locality. Code runs *inside the engine*.

### 10. Cloud-managed compute

Examples: serverless functions, managed containers, edge workers, workflow services, message queue consumers.

Not just "Linux userland somewhere else" — ephemeral instances, IAM-based capabilities, managed observability, cold starts, and statelessness requirements change how code is written.

Axis to add: **who owns and operates the hardware** (affects trust model, observability, failure assumptions, upgrade control).

### 11. Distributed systems and HPC

Examples: MPI programs, job schedulers, map-reduce, distributed actor frameworks, scientific workflows.

Distinct because: failure is normal, time is non-deterministic, data movement dominates, debugging is different. HPC adds vectorization, memory bandwidth, and topology constraints.

### 12. Accelerators: GPU, FPGA, AI accelerators

Examples: CUDA/OpenCL kernels, GLSL/HLSL shaders, Verilog/VHDL + HLS, ML graph compilers (XLA, TVM).

Distinct because: separate memory spaces and transfer costs, SIMT thinking, special compilation (PTX, synthesis/P&R). FPGA is *hardware structure description*, not sequential instructions.

### 13. Blockchains and consensus VMs

Examples: Ethereum smart contracts, Bitcoin Script, other chain VMs.

Distinct because: deterministic execution replicated across nodes, strong constraints (gas/fees, no network/filesystem/time), public persistent state, unusual upgrade/governance model.

### 14. Formal systems: proofs, specs, solvers

Examples: Lean, Coq, Isabelle, TLA+, SMT encodings, verified compilers.

The "runtime" is a logic engine/checker. Output is a *proof object* rather than runtime behavior. These are programs — with control flow, abstraction, reuse, termination concerns, performance. Different semantic domain (logic instead of effects), not a lesser kind of programming.

### 15. Image-based / "live" systems

Examples: Lisp Machines, Smalltalk images, modern Lisps with strong REPL workflows.

Distinct because: the environment is a *persistent living world* (image), code/data separation blurs, development is interactive and incremental, the "OS" is often integrated with the language.

---

## Commonly Misclassified

**"CMake / Ansible are interpreted like Python"** — half-right, misleading. They're DSLs with different semantics:
- CMake runs at configure/generate time; its language produces build graphs
- Ansible is declarative orchestration with idempotence semantics
- Better: **orchestration DSLs for dependency/desired-state engines**

**"Web sandbox is a special case of code inside other programs"** — correct abstraction, but the browser is a dominant, highly-standardized, security-heavy instance worth calling out separately.

**"Mobile is just *nix with battery/network restrictions"** — same kernel substrate, but the lifecycle model (forced suspension, background death) is a genuine programming model constraint.

## Related

- [[programming.meta]] — taxonomy of metaprogramming approaches
- [[lang.plugin]] — plugin system mechanisms (shared libs, IPC, embedded runtimes)
