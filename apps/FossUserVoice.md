---
tags:
  - app-idea
---
UserVoice is a very powerful app for collecting user feedback, but [it's really expensive](https://www.uservoice.com/pricing), starting at $899 a month.

## UserVoice features made bug reports and feature requests easier for users and maintainers
- When drafting an issue, and AI search is continuously running and helping you find duplicates
- Users are given a limited number of upvotes to spend on their top issues
- Maintainers can "respond" in a special part of the UI, like a pinned comment

## FOSS clone backed by GitHub 
Something should build a user voice clone but built on top of GitHub issues, PRS, and discussions

if you have an idea to hack on some repo, you can do an AI search (RAG?) against all of the existing stuff to see if it already exists. Adding a feature that the maintainer already declined is not a good feeling.

Another related feature would be an AI-summary of each issue. (Imagine the first summary of the problem and fix is a wiki, and the replies from the OP, maintainers, or community could change the scope of the problem, solution, workarounds, current Inter- or intra-repo blockers, fix planned, etc.). If the issue was closed as a dupe, then show the summary of the linked issue.
