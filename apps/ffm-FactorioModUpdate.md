First downlaod: https://github.com/raiguard/fmm/releases

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
