Idea first came from [Digital Aristotle: Thoughts on the Future of Education - CGP Grey - YouTube](https://www.youtube.com/watch?v=7vsCAM17O-M)

- [ ] Ideas from [[ExpLang]]

## Khan AI
First called Khan Labs ($9/month), now Khanmigo
>Ready to get AI-powered tutoring?
>Get access to Khanmigo’s personalized learning for $4/month or $44/year

## 2026 survey
#ai-slop 

I’m looking for something like a *learning-aware knowledge graph*: a system that knows
- what concepts exist
- how they relate
- what I already understand
- what the natural next interfaces are for me to learn

What I want—a “digital Aristotle”—doesn’t fail because of AI.
It fails because *pedagogy is not objective*, and encoding it at scale is still an unsolved problem.

Today:
- The **data problem** (what concepts exist) is mostly solved.
- The **reasoning problem** (how concepts relate) is solvable with ontologies.
- The **learning problem** (how humans internalize abstractions) is the hard part.
- No system yet combines:
    - a global, high-quality knowledge graph
    - explicit prerequisite structure
    - learner modeling
    - and an LLM as a disciplined interface
### Conceptual foundations
- **Ontologies / Knowledge Graphs**
    - Purpose: define *what exists* and *how things relate* (e.g., Wikidata, WICUS).
    - Strength: global scope, explicit semantics, machine reasoning.
    - Limitation: no notion of learner state or pedagogy.
- **Learning graphs (prerequisites, mastery)**
    - Purpose: define *what should be learned before what*.
    - Strength: supports progression and assessment.
    - Limitation: usually siloed, domain-specific, and manually curated.
- **LLMs**
    - Purpose: act as a natural-language interface over knowledge.
    - Strength: explanation, synthesis, personalization.
    - Limitation: unreliable without grounding in high-quality structure.

### Real attempts & where they stand
- **Wikidata**
    - Global, open knowledge graph of technical concepts.
    - Status: active, growing 📈
    - Missing: pedagogy, mastery modeling.
- **Khan Academy Knowledge Map**
    - Explicit prerequisite graph with visual navigation.
    - Status: retired ❌
    - Lesson: graph UX was powerful, but hard to maintain and align with curricula.
- **Metacademy**
    - Curated prerequisite graph for ML topics.
    - Status: inactive ❌
    - Lesson: expert curation scales poorly without institutional support.
- **Brilliant**
    - Strong at conceptual “interfaces” and diagnostics.
    - Status: active 📈
    - Missing: explicit, navigable global concept graph.
- **CourseKG / KnowEdu (research)**
    - Automatically constructed educational knowledge graphs.
    - Status: prototype / academic ❄️
    - Lesson: graph construction is feasible; pedagogy still hard.
- **VoiceScholar / Algor (startups)**
    - AI-generated concept maps from content.
    - Status: active 📈
    - Lesson: visualization helps learning, but depth depends on input quality.
- **KG-RAG / CZI + Anthropic**
    - LLMs grounded in curated educational graphs.
    - Status: active (research / early deployment) 📈
    - Lesson: LLMs work best *on top of* graphs, not instead of them.
