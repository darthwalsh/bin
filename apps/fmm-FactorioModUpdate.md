First download: https://github.com/raiguard/fmm/releases

```
# Might be different for you based on where you installed Factorio
$ENV:FACTORIO_PATH = "C:\SteamLibrary\steamapps\common\Factorio"
$ENV:FACTORIO_MODS_PATH = Join-Path $env:APPDATA "Factorio\mods"

cd ~\Downloads\fmm-*

# List mods
./fmm.exe list

# Update mods
./fmm.exe update
```

- [ ] Doesn't seem to update anything -- [check](https://github.com/raiguard/fmm/blob/d9c631204a9ecd29fa5889d3ffd69d326ce54237/lib/manager.go#L513) if there is a way to enable debugging for why 