## Current infra
Source: https://github.com/darthwalsh/darthwalsh.github.io
Just one hardcoded HTML file
Endpoint: https://carlwa.com/
IIRC set this up before GitHub Pages supported HTTPS, so Cloudfront is doing HTTPS termination and proxying
Email: free alias for just forwarding: https://improvmx.com/
## Website skeleton Features
- [ ] Create favicon.ico
- [ ] Link carlwa.com in signature
## Generating HTML from markdown
Need to decide between:
- [[mkdocs]]
	- Also Material: https://squidfunk.github.io/mkdocs-material/getting-started/
- https://jekyllrb.com/docs/posts/#a-typical-post
- hugo
- http://www.sphinx-doc.org/en/stable/examples.html
- https://bearblog.dev/

Should have features to support:
### RSS feed
One for new posts, one for edits?
### Blog/wiki from markdown
More of a [bliky](https://martinfowler.com/bliki/WhatIsaBliki.html), want to create permanent content here. Anybody can edit with link back to github.com.

Content licensed with some CreativeCommons
- [ ] originally watned NonDerivative, but I like people being able to just fork the repo...?
Any JS code licensed MIT

*MAYBE* If linked entry doesn't exist:
- [ ] link pull-request create it?
- [ ] OR, add failure message because it might be in my personal markdown notes or a deleted page?
### PascalCase links
I thought before I'd want to use the wiki format of any word in PascalCase being a link...
- [ ] now: using `[[Wikilinks]]` syntax -- correctly parsed as links
### Renames
Once I post a URL, I want it to be alive forever even if I want to rename / move article...

one way to handle redirection for article renames:
https://github.com/MicrosoftDocs/PowerShell-Docs/blob/37517e1c9668bb76d0873aa90663dfcbace16a67/.openpublishing.redirection.virtual.json#L1226
(followed links, and googled this `openpublishing` framework and i think it's proprietary to MSFT...)

https://docs.bearblog.dev/post/#alias
### Comments
Chose one of:
- https://github.com/imsun/gitment
- https://giscus.app/
### Gists
Example of how to embed a Gist on GitHub Pages using Jekyll: https://gist.github.com/benbalter/5555251
## Email
Around 2015, looked into email hosting for custom domain, and Microsoft/Google/etc. would charge $5 a month.
Originally was going to set up [Hover Webmail](https://support.hover.com/support/solutions/articles/201000064701-the-complete-guide-to-webmail).
Ended up with https://improvmx.com/

Alternative choices:
- https://github.com/discourse/discourse/blob/main/docs/INSTALL-email.md
## Affiliate Links
Something to consider if hosting costs raise over $0
https://magnet4blogging.net/amazon-affiliate-links/
*In the past I would have linked to Amazon Smile, but that went away :(*

Otherwise, monetize with ads
(Had idea to advertise on YouTube, but that is the opposite ad spend...?)
## Other website common knowledge to learn
- [ ] NoFollow Links
- [ ] Cookies
	- [ ] "By continuing using this site you agree to share your cookies" [meme](https://ifunny.co/picture/by-continuing-using-this-site-you-agree-to-share-your-6SkrU6gKB)
- [ ] Privacy Policy, i.e. https://try.codeaesthetic.io/privacy
- [ ] Passwordless auth i.e. WebAuthn or [Passkeys](https://blog.1password.com/what-are-passkeys/)
- [ ] ?  [CSS](https://www.learnenough.com/css-and-layout?srsltid=AfmBOooN4rWDa_GwkCZuwcn1eQy1NGBo-rmEfWJtNSLVG_SW_fEjrM88)
- [ ] [email](https://medium.com/@onedurr/how-to-set-up-custom-email-addresses-on-your-web-site-for-free-afd700de5e9c)

## Cool blogs I want to poke into and capture features
- https://steven-giesel.com/blogPost/392d8179-c02c-4d7d-897d-e6a055c970b9
	- comments powered by GitHub discuss
- https://sive.rs/tech
- https://xeiaso.net/blog/carcinization-golang
- https://github.com/renatoathaydes/renatoathaydes.github.io
- https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
- https://syscall.org/doku.php/gobjectutorial/start
- https://raymii.org/s/tutorials/Ansible_-_Playbook_Testing.html
	- source: https://github.com/RaymiiOrg/raymiiorg.github.io/blob/master/tutorials/Ansible_-_Playbook_Testing.txt
	- "❗ This post is over three years old. It may no longer be up to date. Opinions may have changed."
		- nice message to include on old pages
	- https://raymii.org/s/software/ingsoc.html
	- https://raymii.org/s/blog/Site_update_self_hosted_search_via_pagefind.html#toc_0
- https://rmoff.net/2020/07/01/learning-golang-some-rough-notes-s01e07-readers/
	- source https://github.com/rmoff/rmoff.github.io
- https://blog.washi.dev/posts/int-main/
- https://bicycleforyourmind.com/obsidian_is_going_to_eat_everyone's_lunch
- https://yuanqing.github.io/single-page-markdown-website/
- https://til.simonwillison.net/git/git-filter-repo
	- Edit button at bottom goes back to GitHub
- https://jdsalaro.com/about.html
- https://chrisholdgraf.com/projects/
- https://utteranc.es/
- https://github.com/jamestharpe/jamestharpe.com/blob/main/content/ci-cd.md
- https://joshuatz.com/projects/applications/git-date-extractor-npm-package-and-cli-tool/
	- https://joshuatz.com/posts/2019/gatsby-better-last-updated-or-modified-dates-for-posts/
	- Created_Modified time In YAML frontmatter?
	- (Or, push backwards by rewriting customized git commit times?)
	- ALSO, https://joshuatz.com/posts/2019/gatsby-better-last-updated-or-modified-dates-for-posts
- https://luther.io/mongodb/mongodb-tips-and-tricks/
	- categories, created/modified time, "X minute read"
	- FontAwesome icons on left side bar
- https://swyxkit.netlify.app/moving-to-a-github-cms
- https://devdosvid.blog/about/
	- nice blog theme: using Hugo themed PaperMod
	- source:  https://github.com/vasylenko/devdosvid.blog/tree/main/static/assets/img/s
- https://www.yongliangliu.com/now
	- dark/light theme. looks great!
- https://joshuatz.com/posts/2022/pytest-productivity-tips/
- https://github.com/parsonsmatt/parsonsmatt.github.io
- https://briancha5431.github.io/#about
- https://iliana.fyi/blog/ios-wallet-library-card/#user-content-fnref-blood
- https://blog.ornx.net/post/bluetooth-volume-fix/#fnref4
- https://dg-docs.ole.dev/features/
	- Plugin to deploy to Vercel, or other static site. Supports many markdown features
- https://quartz.jzhao.xyz/
	- Another obsidian site generator
	- Examples with GitHub pages or cloudflare
- https://linked-blog-starter.vercel.app/home
	- Alternative Obsidian publish, might have good obsidian-markdown scripts?
- https://david.reviews/
	- Media reviews site, might be useful to clone as a "better goodreads viewer" for series?
	- source: https://github.com/xavdid/david.reviews
	- Driven by airtable data, so wouldn't want to copy that part of backend
	- Related blog site: https://xavd.id/projects/
- https://sytone.github.io/obsidian-queryallthethings/first-query
- https://www.stefanjudis.com/notes/space-shuttle-style-coding/
	- Click for "Published at" and "Last Updated" and Tags
- https://www.ssp.sh/blog/why-i-moved-away-from-wordpress/
- https://adam-p.ca/blog/2022/03/x-forwarded-for/
- https://purplesyringa.moe/blog/i-sped-up-serde-json-strings-by-20-percent/
- https://simonwillison.net/tags/julia-evans/
- https://til.simonwillison.net/github-actions/daily-planner
	- Has edit history and file write times in footer
- https://nerdymomocat.github.io/posts/a-quick-guide-to-apples-notes-app/
- https://www.swyx.io/devto-cms
	- site content search is very cool! very fast!
	- framework uses github issues as source https://github.com/swyxio/swyxdotio/issues/390 
	- Gives comments and reactions
- https://rakhim.exotext.com/web-developers-a-growing-disconnect
- https://notes.chiubaca.com/permanent-notes/learning/
	- Source https://github.com/chiubaca/notes/blob/main/permanent-notes/learning.md