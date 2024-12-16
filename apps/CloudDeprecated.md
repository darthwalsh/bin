See also: [[ProjectArchiving]]
## 🛫 Deprecation Query
Not *really* a start date, but the date it's officially EOL
```tasks
path includes {{query.file.path}}
has start date
sort by start
```

## 📅 Decommission Query
```tasks
path includes {{query.file.path}}
has due date
sort by due
```

## Google Cloud function 1st Gen
- [ ] dotnetbytes to 2nd Gen OR, [[hosting.fly|fly.io]] 🆔 dotnet-2gen
	- [ ] https://github.com/darthwalsh/dotNetBytes/pull/4#discussion_r1885089010 ⏳ 2024-12-16 
- [ ] Upgrade [DownloadCodinGame](https://github.com/darthwalsh/DownloadCodinGame/blob/b11bcf8befb24c69872e16b82edd235189f854c4/feed/functions/index.js#L1)
	- [ ] IIRC upgrading the cron job topic will be annoying... so fly.io??
- [ ] Upgrade [RunTheGlobe](https://github.com/darthwalsh/RunTheGlobe/blob/e88a0a93157832a199485f06be7135d068a3e682/functions/index.js#L2)
## Google Cloud function dotnet3
- [x] dotnetbytes deprecated 2024-01-30, upgrade before Decommission 📅 2025-01-30
https://cloud.google.com/functions/docs/runtime-support#.net-core
DONE! https://github.com/darthwalsh/dotNetBytes/pull/3
## Google Cloud function dotnet6
- [ ] dotnetbytes 🛫 2024-11-12 📅 2025-11-12 ⛔ dotnet-2gen
- [ ] OR, deploy to e.g. [[hosting.fly|fly.io]]
https://cloud.google.com/functions/docs/runtime-support#.net-core

wrinkle causing block on Gen2:
https://www.googlecloudcommunity.com/gc/Serverless/Roadmap-for-1st-gen-cloud-functions-support-of-NET-8-0-runtime/m-p/693538
>**No official roadmap or announcements for 1st gen .NET 8.0 support:** There's no clear indication from Google if or when they plan to add .NET 8.0 to 1st gen functions.
## Google Cloud function NodeJS
- [x] Fix DownloadCodinGame https://github.com/darthwalsh/DownloadCodinGame/issues/1
- [x] Fix RunTheGlobe https://github.com/darthwalsh/RunTheGlobe/issues/10
https://cloud.google.com/functions/docs/runtime-support#node.js
- [ ] Followup when node 18 is deprecated then decommissioned 🛫 2025-04-30  📅 2025-10-30

## Transition from Container Registry to Artifact Registry 
- [ ] firesocket-test upgrade to container registry ⏳ 2024-12-26 📅 2025-03-18
https://cloud.google.com/artifact-registry/docs/transition/transition-from-gcr

- [x] [Find usage](https://cloud.google.com/artifact-registry/docs/transition/check-gcr-usage#organization) 
Run `gcloud container images list-gcr-usage --organization=0` didn't work...
```powershell

gcloud projects list | Select-Object -Skip 1 | % {($_ -split '\s')[0]} | % {$_; gcloud container images list-gcr-usage --project=$_}

austerity
Listed 0 items.
carlwa
Listed 0 items.
dotnetbytes
---
repository: us.gcr.io/dotnetbytes
usage: INACTIVE
download-codingame
---
repository: us.gcr.io/download-codingame
usage: INACTIVE
firesocket-test
---
repository: gcr.io/firesocket-test
usage: INACTIVE
firesocketexample
---
repository: us.gcr.io/firesocketexample
usage: INACTIVE
last-walk
Listed 0 items.
run-the-globe
Listed 0 items.
runtheglobe
---
repository: us.gcr.io/runtheglobe
usage: INACTIVE
wizardsthreatguide
Listed 0 items.
xmas-geocode
Listed 0 items.
```
Others were empty! One left:
- [ ] repository: gcr.io/firesocket-test
	- creates https://console.cloud.google.com/gcr/images/firesocket-test/global/npm-with-java8
	- marked TODOs https://github.com/darthwalsh/FireSocket/commit/ebd076441a57e7c4f6c51917d48c8061c553fa5c
	- [ ] Good time to try bumping node version: https://github.com/darthwalsh/FireSocket/pull/69


