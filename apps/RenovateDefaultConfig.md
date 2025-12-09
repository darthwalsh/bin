When onboarding to [renovate](https://docs.renovatebot.com/), you get a PR to add `/renovate.json`
```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:recommended"
  ]
}
```
Look for:
1. **Detected Package Files** is expected
2. **What to Expect**
## Running docker locally to preview config
Mount local folder and dry-run renovate:
```bash
docker run --rm -e LOG_LEVEL=debug -v "$(pwd):/mnt" -w /mnt renovate/renovate:latest --platform=local --dry-run
```
Then look for the log line `DEBUG: packageFiles with updates (repository=local)` and following lines.
To see upgrades, look for `.kind.[].deps[].updates`
## My suggestion
### Reduce chance of supply-chain attack
*If you have access to a virtual package feed (socket.dev, artifactory, etc.) then this might not be an issue.*
With the constant news of malicious NPM packages getting uploaded, a tool that blindly upgrades to latest is not the best idea!

For OSS projects, you probably don't have budget for a premium, validated virtual package feed. It would be nice to use Socket.dev as a required github check for PRs, but that also seems to be a premium feature.
In renovate, can use [minimumReleaseAge](https://docs.renovatebot.com/configuration-options/#minimumreleaseage) to slow down changes. Probably also want config `prCreation=not-pending`.

Alternatively, could use [[Snyk]] status check on [[Renovate]]'s PRs: https://chatgpt.com/s/t_68c60566a0048191ba7c3352cb7b7e67
### Rename to JSON5 to allow comments
```bash
mkdir -p .github
mv renovate.json .github/renovate.json5
```
### Dashboard autoclose, concurrency, PR body

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",

  "dependencyDashboard": true,
  "dependencyDashboardAutoclose": true,

  // Assuming branch protection requires branch to be up-to-date, parallel PRs can't be merged
  "prConcurrentLimit": 1,

  // Assuming PRs are copied to slack, all the release notes are very verbose.
  // Neuter the message to the minimum
  "prBodyTemplate": "{{{warnings}}}{{{notes}}}"
}
```
### Instead of manually closing PR for problem package
i.e. you can't upgrade until OpenSSH on your linux server is upgraded, add

```json
{
  "packageRules": [
    {
      "enabled": false, // Completely disable renovate for all these packages
      "matchPackageNames": [
        "some-problem-package" // TODO(BUG-123) upgrade causes build failure
      ]
    }
  ]
}
```
### Decrease priority of noisy packages
If your renovate merges only run once a day, and one dependency releases once a day, and you don't group PRs, you will have a problem!
```json
{
   "packageRules": [
      // These packages got upgraded too frequently and drown out other upgrades
      {
        "matchPackageNames": ["semgrep"],
        "prPriority": -1
      },
      {
        "matchPackageNames": ["boto3"],
        "prPriority": -2
      }
   ]
}
```
### Group all upgrades into one PR, even major
```json
{
  "packageRules": [
    {
      "matchPackagePatterns": ["*"],
      "matchUpdateTypes": ["major", "minor","patch"
      ],
      "groupName": "all dependencies",
      "groupSlug": "all-major-minor-patch"
    }
  ]
}
```
### WIP Automerge
...Tried this, but haven't got it to really work when branch protection requires human approval and/or you want secret detection required check to run.
- [ ] If needed, instead try to set up [renovate-approve-bot](https://github.com/renovatebot/renovate-approve-bot) for selfhosted (or [renovate-approve](https://github.com/apps/renovate-approve) for Mend Renovate App for github.com)
```json
{
  "automerge": true,
  "automergeType": "pr",
  "platformAutomerge": true,
}
```
### WIP language constraint
(Instead of using this, maybe easier to upgrade your programming runtime?)
- [ ] if needed, try setting instead in i.e. `pyproject.toml`
```json
{
  "constraints": { "python": "3.11" },
  // Since Renovate 35.0.0 the configuration below is required to make Python version constraint work
  "constraintsFiltering": "strict",
}
```
## Default Configuration
What's actually in `config:recommended`?

The PR says
> ### Configuration Summary
> Based on the default config's presets, Renovate will:
> - Start dependency updates only once this onboarding PR is merged
> - Enable Renovate Dependency Dashboard creation.
> - Use semantic commit type `fix` for dependencies and `chore` for all others if semantic commits are in use.
> - Ignore `node_modules`, `bower_components`, `vendor` and various test/tests (except for nuget) directories.
> - Group known monorepo packages together.
> - Use curated list of recommended non-monorepo package groupings.
> - Apply crowd-sourced package replacement rules.
> - Apply crowd-sourced workarounds for known problems with packages.

https://docs.renovatebot.com/presets-config/#configrecommended
```json
{
  "extends": [
    ":dependencyDashboard",
    ":semanticPrefixFixDepsChoreOthers",
    ":ignoreModulesAndTests",
    "group:monorepos",
    "group:recommended",
    "replacements:all",
    "workarounds:all"
  ]
}
```
### :dependencyDashboard[¶](https://docs.renovatebot.com/presets-default/#dependencydashboard)
Enable Renovate Dependency Dashboard creation.
`{   "dependencyDashboard": true }`
### :semanticPrefixFixDepsChoreOthers[¶](https://docs.renovatebot.com/presets-default/#semanticprefixfixdepschoreothers)
Use semantic commit type `fix` for dependencies and `chore` for all others if semantic commits are in use.
```json
{
  "packageRules": [
    {
      "matchPackageNames": ["*"],
      "semanticCommitType": "chore"
    },
    {
      "matchDepTypes": [ "dependencies", "require" ],
      "semanticCommitType": "fix"
    },
    {
      "matchDepTypes": [ "project.dependencies", "project.optional-dependencies" ],
      "matchManagers": [ "pep621" ],
      "semanticCommitType": "fix"
    },
    "...trimmed out maven and poetry"
  ]
}
```
### :ignoreModulesAndTests[¶](https://docs.renovatebot.com/presets-default/#ignoremodulesandtests)
Ignore `node_modules`, `bower_components`, `vendor` and various test/tests (except for nuget) directories.
```json
{
  "ignorePaths": ["**/node_modules/**", "**/tests/**", "...vendor/ tetst/ etc." ],
  "nuget": { "ignorePaths": [ ... ] }
}
```
### group:monorepos[¶](https://docs.renovatebot.com/presets-group/#groupmonorepos)
Group known monorepo packages together.
```json
{
  "extends": [
    "group:semantic-releaseMonorepo",
    "group:aws-lambda-powertools-typescriptMonorepo",
    "... 300x others"
  ],
  "ignoreDeps": []
}
```
#### group:semantic-releaseMonorepo[¶](https://docs.renovatebot.com/presets-group/#groupsemantic-releasemonorepo)
Group packages from semantic-release monorepo together.
```json
{
  "packageRules": [
    {
      "extends": [
        "monorepo:semantic-release"
      ],
      "groupName": "semantic-release monorepo",
      "matchUpdateTypes": [
        "digest",
        "patch",
        "minor",
        "major"
      ]
    }
  ]
}
```
#### monorepo:semantic-release[¶](https://docs.renovatebot.com/presets-monorepo/#monoreposemantic-release)
semantic-release monorepo
`{   "matchSourceUrls": [     "https://github.com/semantic-release/**"   ] }`
### group:recommended[¶](https://docs.renovatebot.com/presets-group/#grouprecommended)
Use curated list of recommended non-monorepo package groupings.
```json
{
  "extends": [
    "group:nodeJs",
    "group:goOpenapi",
    "...50x more"
  ],
  "ignoreDeps": []
}
```
#### group:goOpenapi[¶](https://docs.renovatebot.com/presets-group/#groupgoopenapi)
Group `go-openapi` packages together.
```json
{
  "packageRules": [
    {
      "groupName": "go-openapi packages",
      "groupSlug": "go-openapi",
      "matchDatasources": [
        "go"
      ],
      "matchPackageNames": [
        "github.com/go-openapi/**"
      ]
    }
  ]
}
```
#### group:nodeJs[¶](https://docs.renovatebot.com/presets-group/#groupnodejs)
Group anything that looks like Node.js together so that it's updated together.
```json
{
  "packageRules": [
    {
      "commitMessageTopic": "Node.js",
      "matchDatasources": [
        "docker",
        "node-version"
      ],
      "matchPackageNames": [
        "/(?:^|/)node$/",
        "!calico/node",
        "!docker.io/calico/node",
        "!kindest/node"
      ]
    }
  ]
}
```
### replacements:all[¶](https://docs.renovatebot.com/presets-replacements/#replacementsall)
Apply crowd-sourced package replacement rules.
```json
{
  "extends": [
    "replacements:airbnb-prop-types-to-prop-types-tools",
    "replacements:apollo-server-to-scoped",
    "replacements:babel-eslint-to-eslint-parser",
    "replacements:containerbase",
    "replacements:cpx-to-maintenance-fork",
    "replacements:cucumber-to-scoped",
    "replacements:docker-compose",
    "replacements:eslint-config-standard-with-typescript-to-eslint-config-love",
    "replacements:eslint-plugin-eslint-comments-to-maintained-fork",
    "replacements:eslint-plugin-node-to-maintained-fork",
    "replacements:eslint-plugin-vitest-to-scoped",
    "replacements:fakerjs-to-scoped",
    "replacements:fastify-to-scoped",
    "replacements:hapi-to-scoped",
    "replacements:jade-to-pug",
    "replacements:joi-to-scoped",
    "replacements:joi-to-unscoped",
    "replacements:k8s-registry-move",
    "replacements:material-ui-to-mui",
    "replacements:mem-rename",
    "replacements:messageFormat-to-scoped",
    "replacements:middie-to-scoped",
    "replacements:now-to-vercel",
    "replacements:npm-run-all-to-maintenance-fork",
    "replacements:opencost-registry-move",
    "replacements:parcel-css-to-lightningcss",
    "replacements:passport-saml",
    "replacements:react-query-devtools-to-scoped",
    "replacements:react-query-to-scoped",
    "replacements:react-scripts-ts-to-react-scripts",
    "replacements:read-pkg-up-rename",
    "replacements:redux-devtools-extension-to-scope",
    "replacements:renovate-pep440-to-renovatebot-pep440",
    "replacements:rollup-babel-to-scoped",
    "replacements:rollup-json-to-scoped",
    "replacements:rollup-node-resolve-to-scoped",
    "replacements:rollup-terser-to-scoped",
    "replacements:rome-to-biome",
    "replacements:semantic-release-replace-plugin-to-unscoped",
    "replacements:spectre-cli-to-spectre-console-cli",
    "replacements:standard-version-to-commit-and-tag",
    "replacements:typeorm-seeding-to-scoped",
    "replacements:vso-task-lib-to-azure-pipelines-task-lib",
    "replacements:vsts-task-lib-to-azure-pipelines-task-lib",
    "replacements:xmldom-to-scoped",
    "replacements:zap"
  ],
  "ignoreDeps": []
}
```
#### replacements:docker-compose[¶](https://docs.renovatebot.com/presets-replacements/#replacementsdocker-compose)
Compose is now part of the official Docker image.
```json
{
  "packageRules": [
    {
      "matchDatasources": [
        "docker"
      ],
      "matchPackageNames": [
        "docker/compose"
      ],
      "matchCurrentValue": "/^((debian|alpine)-)?1\\.29\\.2$/",
      "replacementName": "docker",
      "replacementVersion": "23.0.0-cli"
    }
  ]
}
```
### workarounds:all[¶](https://docs.renovatebot.com/presets-workarounds/#workaroundsall)
Apply crowd-sourced workarounds for known problems with packages.
```json
{
  "extends": [
    "workarounds:mavenCommonsAncientVersion",
    "workarounds:ignoreSpringCloudNumeric",
    "workarounds:ignoreWeb3jCoreWithOldReleaseTimestamp",
    "workarounds:ignoreHttp4sDigestMilestones",
    "workarounds:typesNodeVersioning",
    "workarounds:nodeDockerVersioning",
    "workarounds:doNotUpgradeFromAlpineStableToEdge",
    "workarounds:supportRedHatImageVersion",
    "workarounds:javaLTSVersions",
    "workarounds:disableEclipseLifecycleMapping",
    "workarounds:disableMavenParentRoot",
    "workarounds:containerbase",
    "workarounds:bitnamiDockerImageVersioning",
    "workarounds:k3sKubernetesVersioning",
    "workarounds:rke2KubernetesVersioning",
    "workarounds:libericaJdkDockerVersioning",
    "workarounds:ubuntuDockerVersioning"
  ],
  "ignoreDeps": []
}
```
#### workarounds:javaLTSVersions[¶](https://docs.renovatebot.com/presets-workarounds/#workaroundsjavaltsversions)
Limit Java runtime versions to LTS releases.
```json
{
  "packageRules": [
    {
      "allowedVersions": "/^(?:8|11|17|21)(?:\\.|-|$)/",
      "description": "Limit Java runtime versions to LTS releases. To receive all major releases add `workarounds:javaLTSVersions` to the `ignorePresets` array.",
      "matchDatasources": [ "docker", "java-version"],
      "matchPackageNames": ["eclipse-temurin", "adoptopenjdk", "java", "..." ],
      "versioning": "regex:^(?<major>\\d+)?(\\.(?<minor>\\d+))?(\\.(?<patch>\\d+))?([\\._+](?<build>(\\d\\.?)+)(LTS)?)?(-(?<compatibility>.*))?$"
    },
    "...ditto matchDepNames"
  ]
}
```
#### workarounds:ubuntuDockerVersioning[¶](https://docs.renovatebot.com/presets-workarounds/#workaroundsubuntudockerversioning)
Use ubuntu versioning for `ubuntu` docker images.
```json
{
  "packageRules": [
    {
      "matchDatasources": ["docker"],
      "matchDepNames": ["ubuntu"],
      "versioning": "ubuntu"
    }
  ]
}
```
