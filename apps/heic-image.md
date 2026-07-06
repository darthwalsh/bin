## Convert to JPG
From https://apple.stackexchange.com/a/347507/325877 just use imagemagick:
```
magick foo.HEIC foo.jpg

magick mogrify -format jpg *.HEIC
```
