---
tags:
  - app-idea
---
Idea: PR check for template: fail if there is a `- [ ]` in PR description body.
At work we use [[Jenkins CI/CD]] so was hoping to implement the check in jenkinsfile (groovy) or in python

- [ ] Simplest idea: use a new webhook for "PR updated"
	- Better than being part of main jenkins CI/CD, so every edit to PR description doesn't trigger another CI run that takes an hour!
	- [ ] Can it be synchronous, where the POST to the webhook just returns `check failed?` If so, then a dumb lambda can host this
		- [ ] Otherwise, it needs to POST back a github check, using REST auth. Then would be reasonable to host as a project-agnostic jenkins job??
	- Would be fine as a non-blocking check for now, could make it required per-project
- Build API https://example.com/job/ProjectName/job/BranchName/1/api/python?pretty=true just has `CauseAction: BranchEventCause` with name: `refactor-mock-classes`
	- [ ] Possible to just use github API to go from branch name -> PR -> description?
	- [ ] Wait until we're using CloudBees CI/CD and see if it's supported then 🛫 2025-06-01 
- Looking at https://example.com/job/ProjectName/configure for possible options
	- [ ] Option to "Discover Pull Request from Origin" instead of / in addition to branch push, check it gives PR in `$CHANGE_ID` ([docs](https://www.jenkins.io/doc/book/pipeline/multibranch/#additional-environment-variables))
- [ ] [JENKINS-50871](https://issues.jenkins.io/browse/JENKINS-50871) tracks jenkins feature request to add "Filter by Github PR Description"
	- [ ] Then you could filter, and fail if any template items are open?
	- [ ] Might need to be a second build??
- [ ] See if the saved slack thread has any insights

## v2
Would be cool to have a merge-pr-with-unchecked-task job that sent out a slack message when a PR is merged and/or a weekly rollup summary.