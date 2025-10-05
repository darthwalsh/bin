`rg` command is like the perfect version of `grep`/`findstr` and probably a lot faster than `Select-String`

## SmartCase
One nice feature I really like, that the author of ripgrep doesn't, is SmartCase search. i.e. if I search for `smart` that is automatically case-insensitive, while any capital like `smART` causes case-sensitive.

To make this the default in all uses of `rg` you could create some alias that only applies to the shell, but I just made the change global by setting `$RIPGREP_CONFIG_PATH` to [.ripgreprc](../.ripgreprc)
## Extracting match
Using `grep` with `-o` or `--only-matching` will literally only print contents matching regex to stdout.

But same options with `rg`  still includes the line number *when not piped*, so you might want `-N` or `--no-line-number`
But when piping output, it doesn't include the line numbers, but has the file names:  `-I` or `--no-filename`

```command
rg -Io JIRA-\d+ --glob !CHANGELOG.md` | Sort-Object -Unique
```

To get only part of the regex match, use a regex capture group with `()` and `-r '$1'` to replace output with group

```command
rg 'from (\S+) import' -Ior '$1' | Sort-Object -Unique
```
## Ignoring
use `--glob` or `-g` for globbing the whole dir/to/the/file.txt path

Make sure to escape any stars so the shell doesn't expand them: `-g '*.py'`
*Or even better use `--type` !* `-t py`

`--iglob` is case-insensitive matching
Can use `--glob-case-insensitive` to affect all `-g` globs


`rg -o JIRA-\d+ --glob !CHANGELOG.md`

## Listing files with matched found
Use `--files-with-matches` or `-l`

## Listing Files included in search
The `--files` option is confusing because it you just add it to a search, `rg` prints an error that your search pattern isn't a file.
```command
$ rg abcd --glob readme*
NativeCommandExitException: Program "rg" ended with non-zero exit code: 1.
$ rg abcd --glob readme* --files
rg: abcd: IO error for operation on abcd: No such file or directory (os error 2)
NativeCommandExitException: Program "rg" ended with non-zero exit code: 2.
```

Instead, first remove the regex `abcd`:
```command
$ rg --glob readme* --files
README.md
```

(Not being able to append `--files` to rg that exited without finding anything seems like a bug.)