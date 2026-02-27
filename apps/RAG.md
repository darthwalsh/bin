#ai-slop
> Retrieval-Augmented Generation (RAG) is ==an AI framework that improves the accuracy and relevance of large language models (LLMs) by fetching up-to-date data from external, trusted knowledge sources before generating a response==. It minimizes hallucinations and provides, precise, context-aware answers without needing to retrain the model. 
> 
> **How RAG Works**  
> RAG operates by combining information retrieval with generative AI through a three-step process: 
> 
> - **Retrieval:** The user's query is used to perform a semantic search in a database (e.g., vector database) containing documents, company databases, or the internet.
> - **Augmentation:** The relevant data retrieved is added to the user's original prompt to provide context
> - **Generation:** The LLM receives this enriched prompt and generates a response based on the external, up-to-date information.

**Where RAG lives:** The chat UI (Claude, Cursor) is not the RAG component. RAG is provided by the **MCP server** when it maintains an index (embeddings + vector store) and exposes a semantic-search tool.

## Knowledge in ChatGPT (Project vs Custom GPT)
**Context:** Putting a large corpus (e.g. a blog archive, product wiki) into ChatGPT so the model can answer from it uses **retrieval**: chunking, embeddings, and semantic search. It is not a full “index in its head”; only retrieved chunks are in context. That shapes what works.

> [!WARNING] These are both Pro subscription features.

### Project vs Custom GPT (Knowledge)
- **Project:** Workspace of chats + reference files + instructions. Good for iterative work and more file slots (plan-dependent, e.g. 20–40). Not a reusable “app” you open from anywhere.
- **Custom GPT with Knowledge:** Instructions + uploaded corpus in one reusable GPT. Knowledge = up to 20 files, each up to 512 MB / 2M tokens; lifecycle tied to the GPT. Best when the library changes infrequently; 20-file cap usually means **bundling** (e.g. one file per year or quarter).

### What works less well than people expect
1. **No global awareness** — Broad prompts (“summarize all views on X”) can miss key docs. **Mitigation:** Add a **catalog file** (ID | Title | Date | URL | short abstract | keywords) and prompt to “find relevant items first, then synthesize.”
2. **Raw HTML poisons retrieval** — Nav, footers, related links, cookie banners dilute embeddings. **Mitigation:** Preprocess to article-only: title, date, body, optional tags, canonical URL.
3. **Citations** — Not automatic; instruct the GPT to cite (e.g. “post title + date”) for every factual claim.

### Library structure that retrieves well
- One **catalog/index** file (table of IDs, titles, dates, URLs, 1–2 line abstracts, keywords).
- **Bundle** posts into fewer, larger files (required for Custom GPT’s 20-file limit; still helps in Projects).
- **Normalize headers** per post, e.g. `# <Title> (<Date>)`, `URL: …`, `---`, then body.

### Getting the corpus (e.g. a blog)
- **Best:** Sitemap index → list post URLs → fetch HTML → extract article content → save as Markdown.
- **Ongoing updates:** RSS feed (often only recent N items).
- **Fallback:** Archive-by-month pages (more brittle). Third-party dumps (e.g. GitHub `lassik/oldnewthing` from Wayback) can be useful as URL/index source; verify completeness and freshness.

## Turning a blog into a RAG?
#app-idea 

> I want to create a system in ChatGPT that has indexed the content of every helpful programming article I've ever read. Say we start with The Old New Thing blog on MSDN from Raymond Chen. Let's say I want to download every article. I could put it into a ChatGPT project or make a custom GPT with the content. Let's say I downloaded like HTML or markdown files. What are the pros and cons here, and what would work well, and what will work less well than I expect?


- [ ] Download files locally
	- [ ] https://devblogs.microsoft.com/oldnewthing/feed?utm_source=chatgpt.com
	- [ ] [lassik/oldnewthing: Index of Raymond Chen's blog "The Old New Thing"](https://github.com/lassik/oldnewthing?utm_source=chatgpt.com)  
	- [ ] [old-new-win32api/README.md at master · mity/old-new-win32api](https://github.com/mity/old-new-win32api/blob/master/README.md?utm_source=chatgpt.com)
	- [ ] [Bulk Fix possible for "Old New Thing" links? Important Win32 resource - Meta Stack Exchange](https://meta.stackexchange.com/questions/383208/bulk-fix-possible-for-old-new-thing-links-important-win32-resource?utm_source=chatgpt.com)
- [ ] Convert to markdown
- [ ] Append with folder2file or something
- [ ] Create custom GPT


> Another idea from the past: Take all [[XKCD]] comic descriptions, and train a bot to pick out relevant XKCD comics based on relevance. Maybe in forum replies, or maybe in [[ConversationStack]] 