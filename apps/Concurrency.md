*note: Concurrency [is different](https://en.wikipedia.org/wiki/Parallel_computing#:~:text=In%20computer%20science%2C%20parallelism%20and%20concurrency) than Parallelism: single-threaded nodejs has just concurrency, while SIMD instructions is just parallel.*

Different Concurrent Models:

## Multi-process
Server creates new child process on-demand.
## Pre-fork
Main server process spawns fixed pool of child processes. Each child handles one request at a time in isolated process, then is re-used.
## Multi-threaded
Each thread handles a separate request, in the same process.
## Event-Driven / Async
Normally single-threaded, using non-blocking I/O and an event loop. Can use callbacks or [[Green Threads and Coroutines#Async]].
(But, still common for some APIs that don't support async to run in background thread pool, which blocks the whole event loop if you mix contexts.)
