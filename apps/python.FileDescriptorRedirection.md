Same functionality, with increasing levels of abstraction. 
## Using `os`
```python
import sys

# Opens file and changes stdin fd 1 stdin to the file.
new_df = os.open("file", os.O_WRONLY | os.O_CREAT | os.O_TRUNC)
old_df = os.dup(1)
os.dup2(new_df, 1)

print("abc")

# Undo FD change
os.dup2(old_df, 1)

# Hopefully clean up the right FD
os.close(old_df)
os.close(new_df)


# Then print the file and cleanup for repeated testing:
with open("file", "r") as f:
    print("GOT: " + f.read())

os.remove("file")
```
## Using native file:

```python
with open("file", "w") as f:
    old_stdout = os.dup(1)
    os.dup2(f.fileno(), 1)
    print("abc")
    os.dup2(old_stdout, 1)
    
    os.close(old_stdout)

# ... print, cleanup
```
## Overwriting `sys.stdout`:

```python
with open("file", "w") as f:
    old_stdout = sys.stdout
    sys.stdout = f
    print("abc")
    sys.stdout = old_stdout
```
## Using `contextlib.redirect_stdout`

```python
from contextlib import redirect_stdout

with open("file", "w") as f:
    with redirect_stdout(f):
        print("abc")
```
