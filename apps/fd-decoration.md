Per-fd decoration via process substitution on fds 1/2/5:

```bash
the-command 5> >(sed 's/^/5: /') 2> >(sed 's/^/2: /') 1> >(sed 's/^/1: /'); sleep 0.1;
```

- Need `5` first, to prevent lines from getting double-decorated
- A short `sleep` so the decorators finish before the prompt is printed.