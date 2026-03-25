#ai-slop
# Golden / Snapshot Testing

**Core idea**: instead of hand-writing expected values, capture output once as a "golden" file and fail when it drifts. Git becomes the approval UI.

The pattern has two distinct workflows depending on when you want to approve changes.

## The two approval workflows

**Snapshot (update-on-command)** -- normal run fails on mismatch; you re-run with a flag to accept all changes at once.

```
pytest                    # fails, shows diff
pytest --snapshot-update  # writes new snapshots, passes
git diff __snapshots__/   # review what changed
git commit
```

**Approval (received/approved files)** -- on mismatch, writes a `*.received` file next to the `*.approved` golden. You promote received → approved to accept.

```
pytest                    # fails, writes *.received
mv tests/golden/foo.txt.received tests/golden/foo.txt
pytest                    # passes
git diff tests/golden/    # review what changed
git commit
```

The difference: snapshot mode approves everything at once via a flag; approval mode lets you selectively promote individual files.

## Python tools

### [`syrupy`](https://pypi.org/project/syrupy/) -- snapshot style

Stores snapshots in `__snapshots__/*.ambr` files alongside tests. Approval is `pytest --snapshot-update`.

```python
# pip install syrupy
def test_render(snapshot):
    assert render("hello") == snapshot  # snapshot name derived from test node id
```

### [`approvaltests`](https://pypi.org/project/approvaltests/) -- received/approved style

Writes `*.received.txt` / `*.approved.txt` pairs. Can open a diff tool automatically on failure.

```python
# pip install approvaltests pytest-approvaltests
from approvaltests import verify

def test_render():
    verify(render("hello"))  # writes test_render.received.txt on mismatch
```

```bash
pytest --approvaltests-use-reporter='PythonNative'
```

### DIY -- minimal, no dependencies

Write `*.received` on mismatch; promote with a shell one-liner. Git is the only approval UI.

```python
# conftest.py
from pathlib import Path

def assert_golden(actual: str, approved: Path):
    approved.parent.mkdir(parents=True, exist_ok=True)
    received = approved.with_suffix(approved.suffix + ".received")
    if not approved.exists() or approved.read_text() != actual:
        received.write_text(actual)
        raise AssertionError(f"Golden mismatch. Wrote: {received}")
```

```bash
# promote all received files
find tests/golden -name '*.received' -exec sh -c 'mv "$1" "${1%.received}"' _ {} \;
```

## Auto-promote pattern (fail + overwrite)

A third variant: on mismatch, overwrite the golden immediately and still fail. The next run passes. Used in [dotNetBytes `BaselineExample()`](https://github.com/darthwalsh/dotNetBytes/blob/main/Tests/AssemblyBytesTests.cs#L333):

```csharp
if (actual != expected) {
    File.WriteAllText(view("bytes.json"), expected);
    Assert.Fail("Baseline was out of date, but fixed now!");
}
```

The test fails once, then passes on the next run. `git diff` immediately shows the incremental JSON drift -- useful when the golden is a large structured file (hundreds of diffs) and you want to review changes incrementally.

This isn't a built-in mode of syrupy or approvaltests; implement it directly if you want it.

## Choosing an approach

| Want | Use |
|---|---|
| Approve everything at once via CLI | `syrupy` |
| Selectively promote individual files, diff-tool integration | `approvaltests` |
| No dependencies, Git as the only UI | DIY `assert_golden` |
| Auto-update golden on first failure, review in git | Auto-promote pattern |

## DX tips

- Normalize output before comparing (strip trailing whitespace, normalize line endings) to avoid noisy diffs
- Name golden files from `request.node.nodeid` automatically so you don't hand-maintain paths
- Add `tests/golden/**/*.received` to `.gitignore` to keep received files out of commits
