## Semver `1.2.3`
https://semver.org/
> Given a version number `MAJOR.MINOR.PATCH`, increment the:
> 1. `MAJOR` version when you make incompatible API changes
> 2. `MINOR` version when you add functionality in a backward compatible manner
> 3. `PATCH` version when you make backward compatible bug fixes

Makes it easy to reason about whether upgrades are breaking changes
Also: `0.1.0` or `1.0.0-alpha`: prerelease

## VERSIONINFO `1.2.3.567`
[VERSIONINFO resource - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/menurc/versioninfo-resource)
The default on Windows. Just a 64-bit number that by-convention is broken into 4 16-bit nums.

[What can I do if I don't want my file version number to be a sequence of four integers? - The Old New Thing](https://devblogs.microsoft.com/oldnewthing/20230503-51/?p=108135)

## ChronVer `2019.05.19`
https://chronver.org/
> Given a version number `YEAR.MONTH.DAY.CHANGESET_IDENTIFIER`, increment the:
> 1. `YEAR` version when the year changes,
> 2. `MONTH` version when the month changes,
> 3. `DAY` version when the day changes, and the
> 4. `CHANGESET_IDENTIFIER` every time you commit a change to your package/project.

`.CHANGESET_IDENTIFIER` is optional if you only have one release that day

Do breaking changes in a sane way: mark it deprecated, then remove it after several python releases (i.e. how python does it). Then you must use the label "break": `2006.04.03.12-break`

- [ ] Spec doesn't define what a "label" is, or what else you are allowed to put into it. The [rust library](https://github.com/dnaka91/chronver/blob/32f0993b2bdf437a0de2f9aa54a43a9c8d267564/src/lib.rs#L401) has nice tests though