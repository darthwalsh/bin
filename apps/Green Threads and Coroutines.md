Green Threads and Async are two ways to achieve [[Concurrency]]. 
## Green Threads
[Green thread on Wikipedia](https://en.wikipedia.org/wiki/Green_thread#Green_threads_in_the_Java_Virtual_Machine) has various implementation details

Go: leads to challenges about with each thread's stack space: in order to grow, need to move pointers to stack objects?
[Green threads vs Async - The Rust Programming Language Forum](https://users.rust-lang.org/t/green-threads-vs-async/42159/4?u=darthwalsh)
> Go doesn't have this problem, not because there's no AsyncGo but actually there's no SyncGo.
> In Go, every IO calls are made asynchronous underneath. What it actually do is to hide the `await` keyword to make it looks more like synchronous code. Cons? We can't put future combinators like join and select on it. Instead in Go we put 2 additional goroutines and combine them with a channel, which is suboptimal.
> Unlike Go, Rust can't drop the sync version of code as it defeats the original purpose of the language - to replace libraries written in C.

New Java: How does it work if you use library A that expects green threads, but library B expects old sync calls? (or async?)

Experiment in dotnet, result: not going to make the change
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