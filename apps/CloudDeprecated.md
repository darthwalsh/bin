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
- [x] dotnetbytes to 2nd Gen OR, [[hosting.fly|fly.io]] 🆔 dotnet-2gen
- [ ] Upgrade [DownloadCodinGame](https://github.com/darthwalsh/DownloadCodinGame/blob/b11bcf8befb24c69872e16b82edd235189f854c4/feed/functions/index.js#L1)
	- [ ] IIRC upgrading the cron job topic will be annoying... so fly.io??
- [ ] Upgrade [RunTheGlobe](https://github.com/darthwalsh/RunTheGlobe/blob/e88a0a93157832a199485f06be7135d068a3e682/functions/index.js#L2)
## fly.io function dotnet8
https://learn.microsoft.com/en-us/lifecycle/products/microsoft-net-and-net-core
- [ ] dotnetbytes upgrade to dotnet10 ⏫  🛫 2026-11-10 ⏳2026-10-01
## Google Cloud function NodeJS
- [x] Fix DownloadCodinGame https://github.com/darthwalsh/DownloadCodinGame/issues/1
- [x] Fix RunTheGlobe https://github.com/darthwalsh/RunTheGlobe/issues/10
https://cloud.google.com/functions/docs/runtime-support#node.js
- [ ] Followup when node 18 is deprecated then decommissioned 🛫 2025-04-30  📅 2025-10-30

## Transition from Container Registry to Artifact Registry 
- [x] firesocket-test upgrade to container registry ⏳ 2024-12-26 📅 2025-04-22
https://cloud.google.com/artifact-registry/docs/transition/transition-from-gcr

- [x] [Find usage](https://cloud.google.com/artifact-registry/docs/transition/check-gcr-usage#organization) 
Run `gcloud container images list-gcr-usage --organization=0` didn't work...
```powershell

gcloud projects list | Select-Object -Skip 1 | % {($_ -split '\s')[0]} | % {$_; gcloud container images list-gcr-usage --project=$_}

dotnetbytes
repository: us.gcr.io/dotnetbytes
usage: INACTIVE

download-codingame
repository: us.gcr.io/download-codingame
usage: INACTIVE

firesocket-test
repository: gcr.io/firesocket-test
usage: INACTIVE

firesocketexample
repository: us.gcr.io/firesocketexample
usage: INACTIVE

runtheglobe
repository: us.gcr.io/runtheglobe
usage: INACTIVE
```
Others were empty! One left:
- [x] repository: gcr.io/firesocket-test
	- creates https://console.cloud.google.com/gcr/images/firesocket-test/global/npm-with-java8
	- marked TODOs https://github.com/darthwalsh/FireSocket/commit/ebd076441a57e7c4f6c51917d48c8061c553fa5c
- [x] Fixed in https://github.com/darthwalsh/FireSocket/pull/75 
- [ ] Check on cost https://console.cloud.google.com/artifacts/docker/firesocket-test/us/gcr.io/npm-with-java8?inv=1&invt=AblK1Q&project=firesocket-test ⏳ 2025-02-04 
- [x] delete npm-with-java8 if [builds](https://console.cloud.google.com/cloud-build/builds?project=firesocket-test&invt=AblLDQ&inv=1) look good
- [x] Check if unblocked node version: https://github.com/darthwalsh/FireSocket/pull/69 🛫 2024-12-29


### Migrate your Cloud Run functions (1st generation) to Artifact Registry 
https://cloud.google.com/functions/docs/building#identify-container-registry-functions

```
$ gcloud --project download-codingame functions describe scheduledFunction --no-gen2 | rg dockerRegistry
dockerRegistry: ARTIFACT_REGISTRY

$ gcloud --project runtheglobe functions describe stravaToken --no-gen2 | rg dockerRegistry
dockerRegistry: ARTIFACT_REGISTRY
```
Nothing to do!
