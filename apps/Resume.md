Features I probably want:
- hide private fields: phone number

- [ ] Get example of markdown and JSON resumes
## `resume.json` 🌟**4k**
Example: https://registry.jsonresume.org/thomasdavis
Site https://jsonresume.org/

Various themes: https://jsonresume.org/themes/
* https://github.com/thibaudcolas/jsonresume-theme-eloquent
	* Obfuscates your email address and phone number from spam bots.

`resume export resume.pdf`

#### Import from LinkedIn
> One of our community members wrote a great Chrome extension to import your LinkedIn Profile.   
[Download here](https://chrome.google.com/webstore/detail/json-resume-exporter/caobgmmcpklomkcckaenhjlokpmfbdec)

js tool: https://github.com/jsonresume/resume-cli

#### Hosting
1. create a Gist on GitHub named `resume.json`.
2. Our hosting service will automatically detect this when you access `https://registry.jsonresume.org/{your_github_username}`
*Use your own repository (instead of a gist)*

Schema: https://github.com/jsonresume/resume-schema
## Reactive Resume 🌟**12k**
Homepage https://rxresu.me/
Source: https://github.com/AmruthPillai/Reactive-Resume
Explained: https://dev.to/cppshane/finally-a-free-and-open-source-resume-builder-without-watermarks-or-limitations-2gbm


> [!warning] Doesn't seem to support using git as source-of-truth of resume data

- unique sharable link

## resumy 🌟**0.08k**
https://github.com/shaoner/resumy

Uses YAML, can import resumejson

Workflow automation: https://github.com/shaoner/resumy_workflow

## Other Tools
- https://www.resumevita.com/ (in beta)
- https://github.com/karanpargal/resume-cli  🌟**0.06k**
- https://github.com/hacksalot/HackMyResume  🌟**9k**
	- > You can **merge multiple resumes together** by specifying them in order from most generic to most specific: `hackmyresume build base.json specific.json TO resume.all`
	- > This can be useful for overriding a base (generic) resume with information from a specific (targeted) resume. For example, you might override your generic catch-all "software developer" resume with specific details from your targeted "game developer" resume, or combine two partial resumes into a "complete" resume. Merging follows conventional [extend()](https://api.jquery.com/jquery.extend/)-style behavior...
	- > **Private Resume Fields**: Have a gig, education stint, membership, or other relevant history that you'd like to hide from _most_ (e.g. public) resumes but sometimes show on others? Tag it with `"private": true` to omit it from outbound generated resumes by default.
	- > Then, when you want a copy of your resume that includes the private gig / stint / etc., tell HackMyResume that it's OK to emit private fields. The way you do that is with the --private switch.
	- ***But*** the project is kind of dead: https://github.com/hacksalot/HackMyResume/issues/229
- https://github.com/karlitos/KissMyResume 🌟**0.06k**
	- has hot-reload `kissmyresume serve`
- https://github.com/fresh-standard/fresh-resume-schema
	- FRESH is a different competing standard to resumejson
	- https://web.archive.org/web/20190125203208/https://freshstandard.org/#/12
- https://luther.io/markdown-resume/
