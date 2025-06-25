<#
.SYNOPSIS
Archive Google Photos
.DESCRIPTION
Opens ~/OneDrive/.aph-ArchiveGooglePhotos.txt
where each line is one album that you want to archive.

Context: apps/GooglePhotosInbox.md
Opens browser windows to search for photos in album, so you can manually archive them all.
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($album in (Get-Content ~/OneDrive/.aph-ArchiveGooglePhotos.txt)) {
  Start-Process "https://photos.google.com/search/$album"
}
