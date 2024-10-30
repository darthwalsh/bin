- [ ] Lots of problems with this, consider looking for more maintained alternatives, or make a simple CLI for https://www.npmjs.com/package/youtube-playlist-markdown?activeTab=readme

Using https://www.npmjs.com/package/youtube-playlist-cli to get markdown list of playlists

```
md youtube-playlist-cli
npm i youtube-playlist-cli
export GOOGLE_API_KEY=$(op read 'op://Private/Youtube API Key/credential')
npx yp -p PLbg3ZX2pWlgKV8K6bFJr5dhM7oOClExUJ
cat playlist-PLbg3ZX2pWlgKV8K6bFJr5dhM7oOClExUJ.md | Set-Clipboard
```

## If npx install fails, you don't get any logs
```plaintext
$ npx -p youtube-playlist-cli yp -h
(node:51484) ExperimentalWarning: CommonJS module /opt/homebrew/lib/node_modules/npm/node_modules/debug/src/node.js is loading ES Module /opt/homebrew/lib/node_modules/npm/node_modules/supports-color/index.js using require().
Support for loading ES Module in require() is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
Need to install the following packages:
youtube-playlist-cli@1.5.4
Ok to proceed? (y) y

NativeCommandExitException: Program "npx" ended with non-zero exit code: 127.

$  gci ~/.npm/_logs/ | Sort-Object LastWriteTime -Descending | Select -First 1 | get-content | grep 127 -C 3
386 info run youtube-dl-exec@1.3.4 preinstall node_modules/youtube-dl-exec npx bin-version-check-cli python ">=2"
387 info run youtube-dl-exec@1.3.4 preinstall { code: 127, signal: null }
```

Or, run `npm i youtube-playlist-cli` to show the error message
## Need to have `python` CLI working at version >= 2
```command
$ pyenv local 3.11.6
$ pyenv which python
/Users/walshca/.pyenv/versions/3.11.6/bin/python
$ rm ./.python-version
$ pyenv which python
pyenv: python: command not found

The `python' command exists in these Python versions:
  3.6.15
  3.8.10
  3.8.18
  3.9.18
  3.10.13
  3.11.6

Note: See 'pyenv help global' for tips on allowing both
      python2 and python3 to be found.

```


[Workaround](https://github.com/microlinkhq/youtube-dl-exec/blob/862e3f58a25f52904f962701edcf7fe63638a73b/scripts/preinstall.mjs#L14) `export YOUTUBE_DL_SKIP_PYTHON_CHECK=1` didn't seem to help, because that wasn't getting run:

```
$ cat node_modules/youtube-dl-exec/package.json | jq -r .scripts.preinstall
npx bin-version-check-cli python ">=2"
```

Missing this change: https://github.com/microlinkhq/youtube-dl-exec/commit/54125f32a105f7de16538e186ee1fc3f12144dc6
- `npm i youtube-dl-exec@1.3.4` fails
- `npm i youtube-dl-exec@3.0.10` succeeds: it checks for python3 first