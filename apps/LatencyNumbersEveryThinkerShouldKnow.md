#ai-slop

> *Every programmer has seen [the table](https://gist.github.com/jboner/2841832). Nobody has one for their own brain.*

The 2012 latency table changed how engineers reason about systems: you see the 100x cliff between L2 and main memory and you *know* your inner loop can't touch DRAM. The same table exists for human cognition — your brain has a memory hierarchy, the tiers have roughly predictable latency and capacity, and workloads that thrash across the cliffs (like switching between 15 browser tabs every 3 minutes) die the same death.

This page maps CPU architecture to cognitive architecture, builds a reference table for the brain's numbers, and asks what a compiler would do if it had to optimize for *this* hardware.

---

## The Reference Numbers

| Operation | Latency | Ratio |
|---|---|---|
| L1 cache reference | 0.5 ns | 1x |
| L2 cache reference | 7 ns | 14x L1 |
| Main memory reference | 100 ns | 200x L1 |
| SSD random 4K read | 150 us | 300,000x L1 |
| Disk seek | 10 ms | 20Mx L1 |

The insight isn't any single number — it's the *shape*: 10x–1000x cliffs between adjacent tiers, with capacity inversely proportional to speed. Programs that accidentally cross a tier boundary in a hot loop collapse. Cache-aware data structures exist because the cliff is real.

---

## Your Brain Runs on the Same Architecture

Cognitive science uses different vocabulary, but the tiers map cleanly. [Baddeley (1974, 2000)](https://en.wikipedia.org/wiki/Baddeley%27s_model_of_working_memory) described working memory as a multi-component system; [Cowan (2001)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2864034/) measured its capacity. The latency ranges below synthesize established findings with order-of-magnitude estimates.

**Registers — working memory.** The things you're actively holding right now. ~4 independent chunks ([Cowan](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2864034/), revising Miller's 7±2 once rehearsal and chunking were controlled for). Sub-second access. This is what you lose when someone says "quick question."

A "chunk" isn't a fixed-size unit — it's compression-dependent. An expert chess player's chunk is a whole board state; a novice's is one piece ([Chase & Simon 1973](https://en.wikipedia.org/wiki/Chunking_(psychology)#Chess)). Expertise is partly the ability to compress more information into fewer register slots, which is why [[Chunking|naming concepts well]] is a genuine cognitive superpower. A good name — "cache invalidation," "leaky abstraction," "confirmation bias" — is a pointer to a rich structure that fits in one slot.

**L1/L2 cache — primed context.** What you were just working on, recoverable in 1–10 seconds if cued. Psych calls this *activated long-term memory* or *the region of direct access* ([Cowan's embedded-processes model](https://en.wikipedia.org/wiki/Cowan%27s_model_of_working_memory)). Capacity: tens of chunks. You experience this as the "tip of your tongue" feeling, or the ease of picking a conversation back up after a 10-second aside. A 30-second interruption can flush most of it.

**Main memory — long-term declarative.** Huge capacity, highly variable latency. Well-practiced facts: 1–5 seconds. Weakly encoded: 10–60 seconds, with a fat tail that includes "never, even though it's definitely in there." Unlike RAM, you don't *load* a record — you *reconstruct* it from associations. Reads can return corrupted data without signaling an error ([Bartlett 1932](https://en.wikipedia.org/wiki/Bartlett%27s_schema_theory), confirmed extensively since). The same fact is sub-second (your mother's name) or minutes (your college roommate's phone number that you definitely once knew) based entirely on cue quality, not "which tier it lives in."

**Cold storage — things not accessed in years.** Retrieval may take minutes of active effort, or fail entirely. [[BrainGC]] observes ~4–6 years without activation and a memory is effectively garbage collected. This aligns with [Ebbinghaus's forgetting curve](https://en.wikipedia.org/wiki/Forgetting_curve) extrapolated to long timescales, but the specific year-count is **anecdotal**, not from controlled studies.

Baddeley's model further decomposes working memory into sub-components: a phonological loop (your inner voice rehearsing a phone number), a visuospatial sketchpad (mentally rotating a shape), a central executive (allocating attention), and an episodic buffer (binding them together). From an architecture standpoint: your "register file" isn't homogeneous — it has specialized functional units. But for the latency table, the ~4-chunk total capacity is the bottleneck that matters.

---

## All Registers Are Caller-Saved

On ARM64, x19–x28 are callee-saved: the called function preserves them and your parent frame's state survives the call. The brain has no such convention. **Every register is caller-saved, and you forgot to push.**

Every context switch — reading a Slack message, answering a question, chasing a tangent in a debug session — puts all working memory at risk. There's no hardware guarantee that your parent frame survives. The variable you were holding, the hypothesis you hadn't yet tested, the sentence you were about to type — potentially clobbered.

Task-switching research confirms the cost: simple lab tasks ~200–500ms to switch ([Monsell 2003](https://doi.org/10.1016/S1364-6613(03)00028-7)), but real knowledge-work re-engagement takes ~23 minutes ([Mark et al. 2008](https://www.ics.uci.edu/~gmark/chi08-mark.pdf)). That 23 minutes is a full register reload from warm cache. If the cache has gone cold, it's worse.

**The calling-convention framing is my analogy, not established psych.** Cognitive psychology uses "task-set reconfiguration" and "proactive interference" for similar phenomena. But the register metaphor makes a specific prediction those frameworks don't emphasize: *depth* matters. Getting interrupted while already two subproblems deep should cost more than getting interrupted at the top level, because you have to restore multiple stack frames. This matches day-to-day experience but is **not directly tested** in the literature I've found.

**Corollary: a [[Law of Leaky Abstractions|leaky abstraction]] costs multiple register slots.** If your mental model of an API is "it just works," it occupies one chunk. If it's leaky — if you must simultaneously hold the high-level interface *and* the failure modes it was supposed to hide — you're burning 2–3 of your ~4 registers on one concept. This is why bad abstractions feel *heavy*: they literally crowd out other thoughts.

**The brain's execution model is flat, not recursive.** Lambda calculus evaluation involves unbounded recursion. Thinking doesn't feel like that. It feels iterative: hold a few things, operate, swap something in, operate again. With only ~4 slots and no callee-saved registers, you can't maintain more than 2–3 levels of call depth before you're thrashing. The brain is a shallow-stack machine that compensates by externalizing deep state — which is exactly what paper is for.

---

## Browser Tabs Are a Leaky Page Table

You're debugging a service. 12 tabs open: logs, runbook, PR, config, Slack thread, Jira. You get pulled into a meeting. You come back 40 minutes later.

The tabs are still there. *You* are not.

Each tab is an entry in your externalized page table. It holds the data. But your *mapping* — why you opened it, what you were looking for, which part matters — has been evicted from working memory. You need to reconstruct intent from the artifact. This is a TLB miss: the virtual-to-physical translation (intent-to-artifact) is gone, and a page walk through the tab is required.

The cost scales predictably:
- **Time away.** 5 minutes → warm cache hit, cheap. 40 minutes → cold, full reconstruction. Next morning → you're `mmap`-ing from swap.
- **Number of open contexts.** 5 tabs is fine (fits in primed context). 30 tabs is paralysis, not because you can't *find* the right tab, but because reconstructing the intent mapping for each one is O(n) against cold memory.
- **Whether you saved state before leaving.** A note, a TODO comment, a draft message. This is `push` before `call`. Without it, you did a `jmp` and hoped the registers would survive. They didn't.

**The highest-leverage micro-habit:** before context-switching, spend 30 seconds writing a *continuation* — what you were doing, what the next step is, what you were unsure about. Save registers to the stack. When you `ret`, you `pop` instead of re-deriving from a cold page walk.

---

## Inlining Knowledge vs. Extracting to a Runbook

A compiler inlines small, hot functions: call/return overhead exceeds the cost of code duplication. It extracts large, cold functions: inlining them would blow the instruction cache.

The same tradeoff applies to what you memorize vs. what you write down.

**Inline (memorize / make automatic) when:**
- Used multiple times per day — lookup overhead (finding the doc, switching context to read it) exceeds the cost of occupying a chunk
- Small enough to fit in one chunk — a keyboard shortcut, a git incantation, a regex pattern
- Errors are expensive — a safety check, a deployment gate, a "never do X"
- Stable — won't change next quarter

**Extract (write a runbook / wiki page) when:**
- Used less than weekly — keeping it resident wastes a register on cold data
- Complex enough that memory-corruption on read is likely — multi-step procedure, exact config values, version-specific commands
- Changes frequently — endpoints, team conventions, infrastructure that rotates
- Shared — other people need the same procedure; shared source of truth beats N stale inlined copies

**The antipattern: inlining something unstable.** If you memorize a deployment procedure that changes quarterly, you'll execute the stale cached version. Every inlined call site is now running dead code. This is how incidents happen: someone does the procedure "from memory" because last time they checked, it was the same. It wasn't.

**[Spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) is a hardware prefetcher.** It identifies facts at risk of eviction from long-term memory and re-activates them just before garbage collection. The result: retrieval latency for practiced items drops from cold storage (10+ seconds, high failure rate) to warm cache (sub-second, reliable). Use it for the small set of things you want permanently inlined — the 200 facts, commands, and patterns that should be at your fingertips without a lookup.

---

## Tools Reshape the Architecture

Each tool modifies a different tier's effective spec:

| Tool                                | Tier modified     | Effect                                                                                                             |
| ----------------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| Paper / whiteboard                  | Registers         | Non-volatile "registers" that survive interruption                                                                 |
| Searchable notes (Obsidian, etc.)   | Warm cache        | Converts recall (generative, error-prone) to recognition (fast, reliable); Ctrl+F in 2s beats 30s of memory search |
| Checklists / templates              | Call stack        | Installs a calling convention — callee-saved registers for repeatable procedures                                   |
| Spaced repetition (Anki)            | LTM → warm cache  | Prefetches facts before eviction; permanently reduces retrieval latency                                            |
| Semantic search / [[RAG]] sidebar   | Cueing            | Surfaces related context without requiring you to formulate the right query                                        |
| Continuation notes before switching | Registers → stack | `push` before `call`; makes `ret` cheap instead of a cold page walk                                                |

The most effective stack: **searchable notes + continuation notes + SRS for the hot 200 facts**. The equivalent of good caches, a reliable calling convention, and hardware prefetch.

A personal RAG sidebar — your accumulated notes surfaced automatically alongside whatever you're working on — is the newest tool in this category. It turns "do I remember writing about this?" into "the system already found three related notes." The win isn't storage (your notes were always there); it's *cueing*. The system generates better retrieval probes than you can conjure under cognitive load.

---

## The Table

Order-of-magnitude heuristics. The brain has no clock; retrieval is cue-dependent; individual variation is massive. Treat these the way you treat "disk seek ~10ms" — wrong for any specific hardware, useful for architecture decisions.

| Cognitive operation | Latency | Capacity | CPU analogy |
|---|---|---|---|
| Recognize a familiar pattern | ~100 ms | — | L1 hit |
| Retrieve from working memory | ~200–500 ms | ~4 chunks | Register file read |
| Switch between two active tasks | ~500 ms – 2 s | ~2 task sets | Save/restore registers |
| Retrieve recently primed concept | ~1–5 s | tens of chunks | L2/L3 hit |
| Recall a well-practiced LTM fact | ~1–10 s | hundreds–thousands | Main memory (TLB hit) |
| Recall a weakly encoded LTM fact | ~10–60 s | vast, variable | Main memory (TLB miss, page walk) |
| Fully re-engage after interruption | ~5–25 min | — | Full process context switch |
| Retrieve something not accessed in years | minutes → failure | — | Page fault from swap |
| Learn a concept to "chunk" fluency | hours–days | — | `apt install` + compile |
| Make a skill automatic (procedural) | weeks–months | — | JIT compile to native |

**Sources and confidence:**
- Pattern recognition ~100ms: well-established ([Thorpe et al. 1996](https://doi.org/10.1038/381520a0))
- Working memory ~4 chunks: consensus ([Cowan 2001](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2864034/))
- Task-switching ~200–500ms for simple tasks: established ([Monsell 2003](https://doi.org/10.1016/S1364-6613(03)00028-7))
- Full re-engagement ~23 min: one widely-cited study ([Mark et al. 2008](https://www.ics.uci.edu/~gmark/chi08-mark.pdf)); **replication status unclear**
- LTM retrieval latencies: rough consensus, but the specific second ranges are **my interpolation**, not direct measurements
- "Years without access → GC'd": forgetting-curve extrapolation + personal observation; **anecdotal**

---

## Where the Analogy Breaks

**Reads are reconstructive, not loads.** RAM returns the exact bits stored. The brain regenerates memories from fragments and fills gaps with plausible confabulation ([Bartlett 1932](https://en.wikipedia.org/wiki/Bartlett%27s_schema_theory)). Your `memcpy` can silently corrupt data. There's no ECC.

**Latency depends on query, not address.** CPU memory latency depends on which tier holds the data. Brain latency depends on how good the *cue* is — the right association can make a "cold" memory feel instant. It's closer to [content-addressable memory](https://en.wikipedia.org/wiki/Content-addressable_memory) where probe quality determines hit rate, not a flat address space. This is why a smell can instantly retrieve a 20-year-old memory that no deliberate effort could surface.

**Reads are writes.** Every retrieval strengthens the pathway used ([Bjork & Bjork 1992](https://doi.org/10.1016/S0079-7421(08)60016-9); the "testing effect"). Accessing a memory modifies it. CPUs don't do this. The act of remembering is training — and the act of misremembering trains the wrong thing.

---

## Related

- [[Chunking]] — the unit of working memory; expertise compresses more into fewer chunks
- [[BrainGC]] — the brain's garbage collection and memory-promotion cycles
- [[LLM AI are like System One thinking]] — System 1 (automatic, fast) vs [[Thinking in Symbols|System 2]] (deliberate, serial); this page is about System 2's hardware constraints
- [[Law of Leaky Abstractions]] — leaky abstraction = holding both the handle and its internals, consuming extra register slots
- [[RocksAreConscious]] — if a CPU is a rock we taught to think, what does the memory hierarchy say about the thinking?
- [Latency Numbers Every Programmer Should Know](https://gist.github.com/jboner/2841832) — the original reference table
- [The Cost of Interrupted Work (Mark et al. 2008)](https://www.ics.uci.edu/~gmark/chi08-mark.pdf) — the ~23-minute re-engagement figure
