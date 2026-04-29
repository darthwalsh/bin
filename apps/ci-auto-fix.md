#app-idea
# AI Agents Fixes Your PR's CI
AI Agents are most useful when an automated check can produce a machine-readable failure signal: they can just loop running CI over and over until it's passing!

Imagine an AI agent watches your PR, reacts to CI failures or review comments, and proposes a fix on a **separate branch** that you review before merging.
This is the same workflow as a human teammate saying "I noticed your build failed, here's a fix" (except they never sleep and they respond in minutes.)

Alternatively, most teams don't put in the effort to find and fix the root cause of issues and just repeatedly retry. You get into a "Self Heal" mindset and accept flakiness.
## The AI Agent Loop
The process an AI Agent should follow is the same I'd task an ~~intern~~ contractor with:

1. ❌ **Detect** a problem (CI check failure, review comment, lint error)
2. 📎 **Fetch** the evidence (build logs, test output, reviewer's request)
3. 🧪 _(best-effort)_ **Reproduce** the failure locally or in a matching environment
4. 🩹 **Fix** with a minimal patch (and rerun the repro steps)
5. 🟢 **Validate** by pushing git commit for CI to rerun (else if ❌, GOTO step 3)
6. 🔔 **Propose** by opening a PR-on-your-PR 

## Branch Isolation Keeps Humans in Control
If AI just made changes to the PR branch, a reviewer giving a once-over for the code diffs might not even notice lines of code from the agent. Zero human eyeballs on code MUST be prevented! The solution is an extra process: AI-generated code must land on a **separate branch**, never directly on the author's PR branch. The AI can start a new branch at your PR, push changes, and create a new PR whose base is your PR branch. This gives a similar diff experience like in Cursor, where you can review code knowing it is AI-generated before adopting it. This also isolates your branches from the AI's hallucinations while it iterates.

See [[github.pr.push-approve]] for preventing a reviewer from pushing commits to a PR branch then self-approve — with no second eyes on that code.
## Knowing When NOT to Fix
An agent that *always* proposes a patch is less helpful than one that sometimes says "I can't fix this, here's what I found." 

For out-of-repo issues (expired credentials, flaky infra, dependency outage, environment drift) the agent should instead post a structured diagnosis and suggested next steps.
This could be a comment on the original PR, letting the author know the agent is done trying for now.

The agent can get a good signal that the issue is out-of-repo by looking at the default (e.g. `main`) branch CI. The agent might also retry builds on the PR or default branch. (Fixing default branch is covered in [[#Beyond PRs]].)

## Reproducing CI Locally with Docker
The gap between "works on my machine" and "fails in CI" is usually the environment. Matching the CI environment in Docker closes that gap, running the exact failing command from the build logs.
The reproduction step is what separates "AI that reads logs and guesses" from "AI Agent that actually validates its fix."

## Cost and Token Optimization
Running a full detect-reproduce-fix loop against each PR before even before hitting a CI failure is an expensive use of tokens! Practical mitigations:
- **Script the detection**: i.e. [[github.pr.dash]], a script can detect different problems, and apply heuristics
- **Filter known flakes**: if the same issue has surfaced in [[Jenkins failure analyzer|main branch lately]], just retry
- **Filter the logs**: if CI stages run in parallel, only show logs from one (Not the entire Jenkins consoleText). AI can also grep sections of the logs.
- **Cap the effort**: set a maximum number of changed lines and CI runs before giving up

## MCP as the Glue Layer
The agent needs **read** access to build data and **write** access to git. [[MCP]] abstracts away credentials, and makes tool usage easier.

Gotcha: Slack MCP requires browser session tokens (`xoxc`/`xoxd`), which expire and can't be automated cleanly. Read Slack as a last resort, not the primary data source.

## Packaging the Loop as a Command or Skill
The skill/command file itself should include the scope constraint explicitly: "you are only authorized to work on problems observed in the branch-under-test." Without this, we've seen scope-creep into fixing unrelated issues the AI finds along the way.

Gotcha: Cursor worktrees start in detached HEAD state, so `git branch --show-current` returns empty. The agent can use a fallback: `git branch -r --points-at HEAD | grep -v HEAD` to find which remote branch is checked out, then ask the user if multiple candidates exist.

## Existing Tools (2026)
[Claude Code on the web](https://code.claude.com/docs/en/claude-code-on-the-web#auto-fix-pull-requests) ships "Auto-fix pull requests"
>[!WARNING] Requires the Claude GitHub App installed on the repo and runs in Anthropic's cloud sandbox.

Claude subscribes to GitHub webhooks for a PR, reacts to CI failures and review comments, pushes fixes if confident, and asks the author if ambiguous. Replies to review threads are posted under the author's GitHub account but labeled as coming from Claude Code.

## Beyond PRs
Once the loop works for PR branches, the same pattern applies to:
- **Main branch regressions**: cron-trigger the agent on default/nightly build failures
- **Dependency update PRs**: [[Renovate]]/Dependabot PRs that break CI get auto-fixed
