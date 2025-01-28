---
tags: app-idea
created: 2017-09-08
---
How often do you get an email from your org's director, saying "Person A is promoted to lead Group Z. Person B and C now report to A, and Group Y is now formed which contains X and Z."

When you don't know your org's existing organizations, this always feels like gibberish and you might need to ask your manager to understand if *your* team is a sub-group of any of the affected groups...

In [[ComputerScience]], you learn about tree data structures like binary trees, and algorithms for optimizing them like [Splay Trees](https://en.wikipedia.org/wiki/Splay_tree) which includes "rotating" nodes of the tree:
![splay tree animation](https://upload.wikimedia.org/wikipedia/commons/b/ba/Splay_Tree_Search_Animation.gif)

Using git version control, there are various ways to visualize files being renamed: could we combine this to make a GIF summary of every org update?

## PoC
1. Cron job:
	1. *in a compliant way* export org from e.g. Active Directory into folders of files
		1. would be nice to create groups: `MyCompany/Engineering/InternalComponents/SyncTeam/SDK.txt`
		2. but lowest-common-denominator is employee reporting structure: `CEO/VP/Directory/Skip/Manager/Me.txt`
		3. Will be tricky to represent dotted-line reporting
	2. Maybe include contact info like phone number, social profiles, etc. to contact your friends if you see later they leave the company?
	3. Push git commit to secure server
2. Script that generates the GIF
	1. just generate before/after visual of part of the subtree
	2. there's some morph/interpolation tools that can generate a video