Green Threads and Async are two ways to achieve [[Concurrency]]. 
## Green Threads
[Green thread on Wikipedia](https://en.wikipedia.org/wiki/Green_thread#Green_threads_in_the_Java_Virtual_Machine) has various implementation details

Go: leads to challenges about with each thread's stack space: in order to grow, need to move pointers to stack objects?
[Green threads vs Async - The Rust Programming Language Forum](https://users.rust-lang.org/t/green-threads-vs-async/42159/4?u=darthwalsh)
> Go doesn't have this problem, not because there's no AsyncGo but actually there's no SyncGo.
> In Go, every IO calls are made asynchronous underneath. What it actually do is to hide the `await` keyword to make it looks more like synchronous code. Cons? We can't put future combinators like join and select on it. Instead in Go we put 2 additional goroutines and combine them with a channel, which is suboptimal.

#ai-slop
Goroutines start with a small stack (2KB). The compiler inserts checks before function calls, and a guard page triggers `morestack` when the stack boundary is crossed. When growth is needed, the runtime pauses the goroutine, allocates a larger contiguous block (typically doubling), copies the entire stack contents to the new location, updates all pointers, frees the old stack, and resumes execution. Stacks can also shrink dynamically when usage decreases.
### Java (Project Loom)
If an old library uses sync calls, it could just slow down a virtual-threaded program: every blocking call inside native code will block one platform thread.


**Native Calls from Virtual Threads:** When a virtual thread calls native code (JNI, Panama), the JVM automatically mounts it onto a platform thread with a normal native stack. The native code runs exactly as if it were called from a traditional Java thread—stack pointers, TLS, and pthread behavior all work normally. On return to Java, the virtual thread is unmounted and returns to segmented stack execution. The segmentation is completely hidden at the boundary; from the C side everything looks normal, and from Java it's just another method call.

### Failed Efforts to Add Green Threads

#### C# / .NET: The "Green Thread Experiment" (2023)
Inspired by Java's Project Loom, the .NET team launched an official experiment to add Green Threads to C#. They wanted to make existing synchronous code "just work" asynchronously without using `async` and `await` keywords everywhere.

**Why they rejected it:**
- **The "Colored Function" Problem:** .NET already had a massive ecosystem of `async/await` code. Introducing Green Threads created a "Red/Blue" function problem where users wouldn't know which model to use.
- **Sync-over-Async Deadlocks:** To make it work, they effectively had to pause blocking calls, which led to dangerous "sync-over-async" deadlocks that are notoriously hard to debug in .NET.
- **Complexity:** The interaction between green threads and the existing async model was too complex.

**The Verdict:** They decided to kill the Green Thread experiment and instead focus on making their existing `async/await` model faster (e.g., `ValueTask`, State Machine optimizations).

#### Rust: The "Removal" (2014)
Before Rust hit version 1.0, it had green threads. It supported an "M:N" threading model (similar to Go), where many lightweight tasks ran on a few OS threads.

**Why they killed it:**
- **The "Zero-Cost" Rule:** Rust's philosophy is "you don't pay for what you don't use." Forcing a heavy runtime on embedded developers or systems programmers (who need to manually manage memory or write OS drivers) was a dealbreaker.
- **C Compatibility:** Calling into C code (FFI) from a segmented green stack is expensive because you have to switch to a "normal" stack to satisfy C's requirements.

**The Verdict:** Replaced it with a `Future`-based system (async/await), which compiles down to state machines with **no runtime overhead**.

#### C++: The "Stackless vs. Stackful" War
For years, C++ committees debated adding fibers (green threads) versus coroutines.

**The Struggle:**
- **Pointers:** C++ has a unique problem with raw pointers. In Go, if the runtime moves a stack to grow it, the runtime also updates all pointers to that stack. In C++, you can have raw pointers pointing anywhere. If the runtime moved a stack, it would invalidate those pointers and crash the program.

**The Verdict:** C++20 settled on **Stackless Coroutines**. Unlike Go (which has "Stackful" coroutines that grow), C++ coroutines effectively freeze their state on the heap. It is efficient but much harder to write manually than Go's simple blocking code.

**The Main Lesson:** You cannot easily "bolt on" Green Threads later if the language wasn't designed with a movable stack and a heavy runtime from day one.


## Coroutines
Generally, abstract the 'function call' model to changing control at different times
How it's like async
blog post from simon tathum(?) building it up

[Coroutines in C by Simon Tatham](https://www.chiark.greenend.org.uk/~sgtatham/coroutines.html)
Builds up framework using macros
```c
#define crBegin static int state=0; switch(state) { case 0:
#define crReturn(i,x) do { state=i; return x; case i:; } while (0)
#define crFinish }
int function(void) {
    static int i;
    crBegin;
    for (i = 0; i < 10; i++)
        crReturn(1, i);
    crFinish;
}
```

>Of course, this trick violates every coding standard in the book

>relies on `static` variables and so it fails to be re-entrant or multi-threadable

[Philosophy of coroutines by Simon Tatham](https://www.chiark.greenend.org.uk/~sgtatham/quasiblog/coroutines-philosophy/#textMulti2Dparadigm20is20the20One20True20Way2C20because20itE28099s20the20only20way20that20doesnE28099t20insist20that20thereE28099s20a20One20True20Way)
>Multi-paradigm is the One True Way, because it’s the only way that doesn’t insist that there’s a One True Way!

## Async
Kind of a specific kind of coroutine
[Building a mental model for async programs](https://rainingcomputers.blog/dist/building_a_mental_model_for_async_programs.md) 

One consideration is an async task should avoid doing CPU-heavy work before the first context switch, which would synchronously block the caller.
- [ ] Related? see the C++ coroutine feature, which allows for coroutines to be created in stopped/started state?

[[CSharp|C#]] uses `async` in GUI apps where the main UI thread must be used for certain AI--[StackOverflow](https://stackoverflow.com/a/18098557/771768) and [blog](https://devblogs.microsoft.com/pfxteam/await-synchronizationcontext-and-console-apps/) and  [FAQ](https://devblogs.microsoft.com/dotnet/configureawait-faq/)--so you often see `task.ConfigureAwait(false)` for performance if you don't need to capture the execution context.)

Async as a language feature leads to [[FunctionColor]] problem, where sync methods *cannot* call Async ones. Now changing one function to be async might require updating dozens of places!
