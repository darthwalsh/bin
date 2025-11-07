#ai-slop
## AWS Lambda execution model
AWS Lambda runs each invocation on a single thread, but *may reuse* the execution environment (container) across multiple sequential invocations for performance. This means:
- No concurrent requests on the same container (unlike a traditional web server with thread pool)
- But global state persists between invocations unless cleared
- If you use `async/await`, multiple coroutines can be active in the same invocation

This is similar to a **synchronous** Python web framework like Flask or Django in WSGI mode (one request per thread), but different from **async** frameworks like FastAPI or aiohttp (multiple concurrent requests per event loop).

## The problem: propagating request context
Each Lambda invocation has a `request_id` available in the handler:
```python
def lambda_handler(event, context):
    request_id = context.aws_request_id
    # but how do I get this deep in my code?
```

When logging from deep in your call stack, you need the `request_id` to correlate logs. 
Three approaches:

### 1. Pass it as a parameter
```python
def lambda_handler(event, context):
    request_id = context.aws_request_id
    process_data(event['data'], request_id)

def process_data(data, request_id):
    logger.info(f"[{request_id}] Processing: {data}")
```
Safe but tedious. Every function in the call chain needs the parameter.

### 2. Global variable (❌ broken)
```python
request_id = None

def lambda_handler(event, context):
    global request_id
    request_id = context.aws_request_id  # ⚠️ OOPS! Could leak to next invocation
    process_data(event['data'])

def process_data(data):
    logger.info(f"[{request_id}] Processing: {data}")
```
If the container is reused and you forget to clear the global, the next invocation gets stale data. Also breaks with `async/await` if multiple coroutines read the global.

Nuance: In a strictly synchronous Lambda handler with no background threads or `async/await`, you can reduce risk by setting the global on entry and clearing it in a `finally` block. This still risks leaks on missed code paths, and it will break if you later introduce concurrency. Prefer `ContextVar`.

### 3. ContextVar (✅ correct)
```python
from contextvars import ContextVar

request_id_var: ContextVar[str] = ContextVar("request_id", default="unknown")

def lambda_handler(event, context):
    request_id_var.set(context.aws_request_id)
    process_data(event['data'])

def process_data(data):
    request_id = request_id_var.get()
    logger.info(f"[{request_id}] Processing: {data}")
```

## How ContextVar works
Python's `contextvars` module (3.7+) provides context-local storage:
- Each `async` task gets its own isolated copy of the context
- Each thread gets its own isolated copy of the context
- Calling `.set()` only affects the current context
- Child tasks/threads inherit parent context values at creation time

This is analogous to C#'s `AsyncLocal<T>` which flows across `await` boundaries. (Similar to [[CSharp]] `ThreadLocal<T>`, but that won't work if async resumes on a different thread.)

## When do you need ContextVar?
- **Lambda with async/await**: Definitely need it if using asyncio
- **Lambda with synchronous code**: Technically could use a global if you're careful to set/clear it, but ContextVar is safer
- **Long-running services**: If you have a thread pool or event loop handling multiple requests, you need context-local storage
- **Libraries**: If writing reusable code, use ContextVar to be async-safe

## Real-world example: AWS Lambda Powertools
The [AWS Lambda Powertools](https://github.com/aws-powertools/powertools-lambda-python/blob/6bcb720a643d6d7891be8d2fc78e952f97dd3005/aws_lambda_powertools/logging/formatter.py#L74) library uses `ContextVar` to store logging metadata:
```python
THREAD_LOCAL_KEYS: ContextVar[dict[str, Any]] = ContextVar("THREAD_LOCAL_KEYS", default={})

def set_context_keys(**kwargs: Any):
    current = THREAD_LOCAL_KEYS.get()
    THREAD_LOCAL_KEYS.set({**current, **kwargs})
```

Their [inject_lambda_context decorator](https://github.com/aws-powertools/powertools-lambda-python/blob/6bcb720a643d6d7891be8d2fc78e952f97dd3005/aws_lambda_powertools/logging/logger.py#L947) automatically sets `request_id` (and optionally correlation IDs from the event) into the context:
```python
from aws_lambda_powertools import Logger

logger = Logger()

@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    logger.info("Processing started")  # automatically includes request_id
    process_data(event['data'])

def process_data(data):
    logger.info(f"Processing: {data}")  # still includes request_id, no params needed
```
