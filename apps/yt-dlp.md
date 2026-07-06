Downloads [[YouTube]] playlist to local file.
You need [[ffmpeg]] with mp3 support installed.

## Download
Download a youtube playlist as mp3s:
```
uvx yt-dlp --remote-components ejs:github -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --paths "temp:/tmp" --download-archive ~/youtube-archive.txt --yes-playlist "https://www.youtube.com/playlist?list=$PLAYLIST_ID" --output "%(playlist_index)s - %(title)s.%(ext)s"
```

- `--remote-components ejs:github` solves [[#Warning for JS challenges / signature solving]]
- `-x` just extracts audio
- `--paths "temp:/tmp"`avoids writing temporary files to SD card
- `--download-archive ~/youtube-archive.txt` allows incremental downloading
- `playlist_index` automatically pads with leading zeros

## Warning for JS challenges / signature solving

```
WARNING: [youtube] [jsc] Remote components challenge solver script (deno) and NPM package (deno) were skipped. These may be required to solve JS challenges. You can enable these downloads with  --remote-components ejs:github  ... refer to  https://github.com/yt-dlp/yt-dlp/wiki/EJS
WARNING: [youtube] GJAt8bqW00E: Signature solving failed: Some formats may be missing. Ensure you have a supported JavaScript runtime and challenge solver script distribution installed. Review any warnings presented before this message. For more details, refer to  https://github.com/yt-dlp/yt-dlp/wiki/EJS
```
I already had `deno` installed, but that wasn't enough!

AI says:
> yt-dlp tried to use Deno to solve YouTube's anti-bot measures but skipped some remote components. **They didn't block the download** this time (you got the audio stream), but they can cause missing formats on some videos.
> **To reduce them**: `uvx yt-dlp --remote-components ejs:github ...`

## Caching
Don't set `--cache-dir` it defaults to `${XDG_CACHE_HOME}/yt-dlp`
