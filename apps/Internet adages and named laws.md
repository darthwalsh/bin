- [ ] source many from https://twitter.com/G_S_Bhogal/status/1438972527838117895?s=09
- [ ] https://newsletter.manager.dev/p/the-13-software-engineering-laws

There are lots of "laws" named after people, that describe common tropes/adages/idioms/sayings when it comes to the internet.

## Chesterton's fence
https://en.wikipedia.org/wiki/G._K._Chesterton#Chestertons_fence
>reforms should not be made until the reasoning behind the existing state of affairs is understood
## Cunningham's Law
https://en.wikipedia.org/wiki/Ward_Cunningham#Law
>The best way to get the right answer on the Internet is not to ask a question; it's to post the wrong answer.
## Godwin's law
https://en.wikipedia.org/wiki/Godwin%27s_law
>As an online discussion grows longer, the probability of a comparison involving Nazis or Hitler approaches 1.
## Goodhart's law
https://en.wikipedia.org/wiki/Goodhart%27s_law
>When a measure becomes a target, it ceases to be a good measure

(Great [XKCD](https://xkcd.com/2899/) on this.)
## Greenspun's tenth rule
https://en.wikipedia.org/wiki/Greenspun%27s_tenth_rule
>Any sufficiently complicated C or Fortran program contains an ad hoc, informally-specified, bug-ridden, slow implementation of half of Common Lisp.

*Related:* [The Configuration Complexity Clock](https://mikehadlow.blogspot.com/2012/05/configuration-complexity-clock.html) 
1. Hard coded config
2. Values in JSON, XML
3. Groups, hierarchies
4. Rules engine
5. DSL
6. Cycle back to the beginning, now have a full programming language
(I've called this a "doomsday clock" but that's just my mistaken term)
*Related:* Google had a global outage where deploying their "feature flags" which was turing complete and recursive, causing the config evaluation to StackOverflow and fail all regions at once. Code deployment followed best-practice staggered, regional deployment, but feature flag deployment was global.
## Hyrum's law
https://en.wikipedia.org/wiki/API#Hyrums
>With a sufficient number of users of an API, it does not matter what you promise in the contract: all observable behaviors of your system will be depended on by somebody.

Relevant [XKCD](https://xkcd.com/1172/). Also, Hyrum made his own page for it! https://www.hyrumslaw.com/ credits Titus Winters
## Jakob's Law
https://en.wikipedia.org/wiki/Jakob_Nielsen_(usability_consultant)#Jakob's_law
>Users will anticipate what an experience will be like, based on their mental models of prior experiences on websites. When making changes to a design of a website, try to minimize changes in order to maintain an ease of use.

OR
https://lawsofux.com/jakobs-law/
>Users spend most of their time on other sites. This means that users prefer your site to work the same way as all the other sites they already know.
## Poe's Law
https://en.wikipedia.org/wiki/Poe%27s_law
>Adage of internet culture which says that, without a clear indicator of the author's intent, any parodic or **sarcastic** expression of extreme views can be **mistaken** by some readers for a **sincere** expression of those views.
## Postel's law
https://en.wikipedia.org/wiki/Robustness_principle
>be conservative in what you send, be liberal in what you accept

Criticism: better to follow norms for established protocols where some implementations depend on lax behavior.
## Zawinski's Law
https://en.wikipedia.org/wiki/Jamie_Zawinski#Zawinski's_Law
>Every program attempts to expand until it can read \[e-mail]. Those programs which cannot so expand are replaced by ones which can.
## Sources: wikipedia
- [ ] pull in more from https://en.wikipedia.org/wiki/Category:Internet_terminology

# Murphy's Law books has basically all pre-internet adages
From this [VSauce Video](https://youtube.com/shorts/4vbdDtbgkr8?si=Y6g8q9Zgg30PrVti) he talks about [Arthur Bloch's](https://en.wikipedia.org/wiki/Arthur_Bloch) book Murphy's Law published 1977

But the different editions of the book have been confusing me, so summarized:
## "Murphy's Law and Other Reasons Why Things Go Wrong"
- ISBN [9780843104288](https://isbnsearch.org/isbn/9780843104288)
- Published 1978
- The original!
- Had a couple sequels
- Converted to HTML: https://www.cse.unr.edu/~sushil/class/cs202/quotes/cs202.html#laws ([Archive](https://web.archive.org/web/20221204172700/https://www.cse.unr.edu/~sushil/class/cs202/quotes/cs202.html#laws))
	- Doesn't have entries from Book Two, Thee, Murphy's law 2000, or Computer Murphology from 9780843129687
- [x] Try to find from VSauce video: "Boob's law" is "You always find something the last place you look." --
	- it's not in the HTML, but presumably is in text of first book?
	- Another law from the VSauce is in the website: Meskimen's Laws \#2 "There's never time to do it right, but always time to do it over."
	- Boob's law is in "Murphy's law complete: all the reasons why everything goes wrong!" on p37

## "Murphy's law complete: all the reasons why everything goes wrong!"
- https://archive.org/details/murphyslawcomple0000bloc/page/n5/mode/2up
- ISBN [9780413572004](https://isbnsearch.org/isbn/9780413572004)
- Published 1986 or 1990
- Looks to be just a reprint of his first three books, as subsections
- Has index on page 279 by topic... *but not the law names*

## "The complete Murphy's law: a definitive collection" 
- https://archive.org/details/completemurphysl00bloc/page/n9/mode/2up
- ISBN [9780843129687](https://isbnsearch.org/isbn/9780843129687)
- Published 1991, seems like it merges together the last three books
- Better print quality
- *BUT NO INDEX* -- what good is a print book without an index :\

## "Murphy's law 2000"
- https://archive.org/details/murphyslaw2000wh00bloc
- Published 1999
- ISBN [9780843174823](https://isbnsearch.org/isbn/9780843174823)

## "Murphy's Law (Complete)"
- Not on Internet Archive
- Published 2008
- ISBN [9780099445456](https://isbnsearch.org/isbn/9780099445456)

## "Murphy's Law Complete & All the Reason Why Everything Goes Wrong"
- Published 2011, but likely is just reprint of 9780413572004
- ISBN [9788183071116](https://isbnsearch.org/isbn/9788183071116)
