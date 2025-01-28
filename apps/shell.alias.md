In order to improve your shell experience, it is common to add several *aliases* for long commands you often type.
i.e in bash, a common practice is to have a `bash_aliases` file that your bash login profile imports.
Very common commands could be:
```bash
# Don't accidentally use python2
alias python=python3

# Change directories easily
alias ..='cd ..'
alias ...='cd ../..'

# Colorize the ls output
alias ls='ls --color=auto'

function pushtmp() {
   tmp_dir=$(mktemp -d -t GAR-$(date +%Y-%m-%d-%H-%M-%S)-XXXX)
   pushd "$tmp_dir"
}
```

These aliases function differently than adding/changing `ls` or `python` commands in your `PATH`, as they only affect *your shell* and so they won't break any other program that runs on your computer and expects i.e. python2. 

Having a function run in your bash shell is also different than creating a `pushtmp` script with a shebang, because that would run in a new shell process and changing directories or setting environment variables would have no affect. Otherwise, it is better to put complicated script logic into it's own entry in the `PATH` -- then it could also be used in your own tools.
## pwsh
[[pwsh]] is a little strange, because the `Set-Alias` cmdlet [doesn't support arguments](https://stackoverflow.com/a/4167071/771768) to the command i.e. `ls='ls --color=auto'`.
Instead, creating a `function` is the equivalent.
## Command aliases
It's also common to make aliases in other tools, but if you are also familiar with making shell plugins I'm not sure why it's any better to make `git co` run `git checkout` when you could write a shell alias `gitco`?
- [ ] See [[lang.plugin#Language-Agnostic]] "Execute command with fixed prefix"
- [ ] i.e. [Mastering Git Shortcuts: A Guide to Git Aliases - DEV Community](https://dev.to/pradumnasaraf/mastering-git-shortcuts-a-guide-to-git-aliases-324j)

