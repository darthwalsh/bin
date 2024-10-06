In the past, installed `nircmd` to quickly change sound devices:
```batch
nircmd getdefaultsounddevice
nircmd showsounddevices

REM mic.bat
nircmd setdefaultsounddevice "Headset"

REM hea.bat
nircmd setdefaultsounddevice "Headphones"

REM spk.bat
nircmd setdefaultsounddevice "MySpeakers"
```

I don't remember if one of these was bluetooth speakers, or a virtual sounds device like for Steam Link?

Also, for a bit was trying to use `SoundVolumeView.exe` but I don't remember if that was working:
```batch
~\scoop\apps\soundvolumeview\current\SoundVolumeView.exe /GetPercent
~\scoop\apps\soundvolumeview\current\SoundVolumeView.exe /GetPercent Speakers
~\scoop\apps\soundvolumeview\current\SoundVolumeView.exe /GetPercent 
~\scoop\apps\soundvolumeview\current\SoundVolumeView.exe /Mute
```
