#carlwa_com 
## Current infra
Source: https://github.com/darthwalsh/darthwalsh.github.io
Just one hardcoded HTML file
Endpoint: https://carlwa.com/
IIRC set this up before GitHub Pages supported HTTPS, so Cloudfront is doing HTTPS termination and proxying
Email: free alias for just forwarding: https://improvmx.com/
## Website skeleton Features
- [ ] Create favicon.ico
- [ ] Link carlwa.com in signature
## Website style guide
cribbed from [Strong Opinions on URL Design | Vale.Rocks](https://vale.rocks/posts/strong-opinions-on-url-design)
- manually typeable: short URLs, lowercase
- no www / id numbers / slugs / dates--(good if content can be updated)
- hyphens as separators are easier to type, show when underlined (no underscores, no spaces)
    - avoid periods unless used for file extension (definitely no .html)
## Generating HTML from markdown
Need to decide between:
- [[mkdocs]]
	- Also Material: https://squidfunk.github.io/mkdocs-material/getting-started/
- https://jekyllrb.com/docs/posts/#a-typical-post
	- https://mademistakes.com/work/jekyll-themes/minimal-mistakes/
	- https://github.com/mattwarren/mattwarren.github.io/blob/master/_config.yml
- hugo
- http://www.sphinx-doc.org/en/stable/examples.html
- https://bearblog.dev/

Should have features to support:
### RSS feed
One for new posts, one for edits?
### Blog/wiki from markdown
More of a [bliky](https://martinfowler.com/bliki/WhatIsaBliki.html), want to create permanent content here. Anybody can edit with link back to github.com. Working to create [Evergreen notes](https://notes.andymatuschak.org/Evergreen_notes).

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
#### Cloudflare Pages can handle redirects:
https://kevin.deldycke.com/2022/cloudflare-commands
https://github.com/kdeldycke/kevin-deldycke-blog/blob/0cded43812eb7cff66f390de8fd51cd5348635bf/content/extra/_redirects
### Comments
Chose one of:
- No comments (see [comments](https://news.ycombinator.com/item?id=45423506) about PHP blogs moving to static sites)
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
- [ ] Social Media Preview of article contents (i.e. what does facebook preview look like)
- [ ] Cookies
	- [ ] Is this required for setting user pref in browser `localStorage`?
	- [ ] "By continuing using this site you agree to share your cookies" [meme](https://ifunny.co/picture/by-continuing-using-this-site-you-agree-to-share-your-6SkrU6gKB)
- [ ] Privacy Policy, i.e. https://try.codeaesthetic.io/privacy
- [ ] Best practic HTML
	- [ ] [Plain Vanilla - Sites](https://plainvanillaweb.com/pages/sites.html)
- [ ] https://webmention.io/
- [ ] index from e.g. https://searchmysite.net/admin/add/
- [ ] Passwordless auth i.e. WebAuthn or [Passkeys](https://blog.1password.com/what-are-passkeys/)
- [ ] Styling
	- [ ] [Plain Vanilla - Styling](https://plainvanillaweb.com/pages/styling.html)
	- [ ] [Stylelint - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint)
	- [ ] [CSS](https://www.learnenough.com/css-and-layout?srsltid=AfmBOooN4rWDa_GwkCZuwcn1eQy1NGBo-rmEfWJtNSLVG_SW_fEjrM88) paid course
- [ ] NoFollow Links only useful if users can post links, or you are paid for links
	- [geeksforgeeks.org/nofollow-links/](https://www.geeksforgeeks.org/nofollow-links/): says "So, why would anyone use nofollow links? There are several reasons:"
	- To prevent spam: Nofollow links are widely used in comment sections, forums, and social media to stop people from trying to boost their ranking by posting irrelevant links.
	- For sponsored content: If you're paid to link to another website, it's considered unethical to pass on ranking power, so you should use a nofollow link.
	- For user-generated content: Sites like Wikipedia use nofollow links for references and external links in user-generated content to prevent misuse."
- [ ] [Speculation Rules](https://www.jonoalderson.com/conjecture/its-time-for-modern-css-to-kill-the-spa/#:~:text=That%E2%80%99s%20where%20Speculation%20Rules%20come%20in.%20This%20lets%20the%20browser%20preload%20or%20prerender%20full%20pages%20based%20on%20user%20behaviour%20%E2%80%93%20like%20hovering%20or%20touching%20a%C2%A0link%20%E2%80%93%20before%20they%C2%A0click) lets the browser preload full pages before they click a link
- [ ] [email](https://medium.com/@onedurr/how-to-set-up-custom-email-addresses-on-your-web-site-for-free-afd700de5e9c)
- [ ] [Plain Vanilla - Components](https://plainvanillaweb.com/pages/components.html)
- [ ] PWA: [Turning a GitHub page into a Progressive Web App | Christian Heilmann](https://christianheilmann.com/2022/01/13/turning-a-github-page-into-a-progressive-web-app/)
- [ ] Translations, i.e. [webrtc-for-the-curious/config.toml](https://github.com/webrtc-for-the-curious/webrtc-for-the-curious/blob/master/config.toml)
- [ ] DNS
	- [x] Apex domain CNAME? i.e. CNAME `https://carlwa.com` and avoid hardcoding `A` IP Address? Yes! [Cloudflare supports it!](https://developers.cloudflare.com/dns/cname-flattening/?utm_source=chatgpt.com)
	- [ ] ⚠️ **Domain Verification**: If a CNAME target is used for domain verification (e.g., for email services), enabling CNAME flattening may cause the verification to fail
## Hosting
Publishing a static site to GitHub Pages or Cloudflare Pages is possible, and has free HTTPS.
Otherwise, Obsidian Publish [supports](https://publish.obsidian.md/hub/06+-+Inbox/Let's+Encrypt) Let's Encrypt 
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
- https://mattwarren.org/
- https://fasterthanli.me/series/making-our-own-ping
- https://matklad.github.io/2025/04/19/things-zig-comptime-wont-do.html
	- blog with edit button
- https://github.com/bgheneti/bgheneti.github.io
- https://github.com/beingpax/obsidian-blogger
- https://evanhahn.com/a-decade-of-dotfiles/
- https://style.ysap.sh/
	- Custom blog, `curl https://style.ysap.sh/` renders in ANSI
	- https://style.ysap.sh/md prints raw markdown
