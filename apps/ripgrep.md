`rg` command is like the perfect version of `findstr` and probably a lot faster than `Select-String`

One nice feature I really like, that the author of ripgrep doesn't, is SmartCase search. i.e. if I search for `smart` that is automatically case-insensitive, while any capital like `smART` causes case-sensitive.

To make this the default in all uses of `rg` you could create some alias that only applies to the shell, but I just made the change global by setting `$RIPGREP_CONFIG_PATH` to [.ripgreprc](../.ripgreprc)

- [ ] Check it's installed on  #windows , maybe look if any scripts still expect `findstr` installed