#ai-slop

## Underrated smart traits

- **Mental Flexibility / Cognitive Agility:** Updating your beliefs when new evidence shows up, even when you’re emotionally invested.
- **Pattern Recognition:** Noticing meaningful connections across domains (analogies, metaphors, systems), not just doing linear logic.
- **Metacognition:** Monitoring how you’re thinking/learning and correcting course when you drift.
- **Tolerance for Ambiguity:** Staying productive in “I don’t know yet” without rushing to premature conclusions.
- **Depth of Attention:** Fully engaging with an idea the first time so you catch nuance and reduce re-learning.
- **Intellectual Humility:** Comfortably saying “I don’t know,” and genuinely being open to learning from others.
- **Grit / Delayed Gratification:** Sticking with learning and refinement when progress is slow or unrewarding.
- **Intrinsic Motivation:** Learning out of fascination or meaning, not just external rewards.
- **Self-Regulation / Impulse Control:** Overriding distraction and reactive emotion so you can think clearly.
- **Resilience to Failure:** Treating mistakes as feedback and continuing anyway.
- **Perspective-Taking:** Accurately modeling how others think to communicate, collaborate, and teach.
- **Emotional Awareness:** Noticing when pride, fear, or shame is biasing your judgment.
- **Listening:** Taking in what someone means (not just what they said) and integrating it.
- **Strategic Thinking:** Seeing the “why,” anticipating downstream effects, and choosing actions that compound.
- **Clarity of Communication:** Explaining complex things simply and precisely.
- **Judgment / Taste:** Knowing what matters and what’s worth doing in a sea of options.
- **Self-Compassion:** Being kind to yourself in a way that sustains effort and learning.
- **Intuition + Calibration:** Knowing when to trust your gut—and when to slow down and verify.
- **Playfulness / Imaginative Thinking:** Approaching learning as exploration and experimentation, not just duty.
- **Skepticism without Cynicism:** Questioning claims rigorously while staying open to being persuaded.

### In software engineering

- **Abstraction Management:** Choosing the right boundaries makes features cheaper to add and reduces how often “small changes” turn into rewrites.
    - Avoids over-generalizing (hard to understand) and under-abstracting (copy/paste sprawl).
- **Naming Things Well:** Good names compress complexity, speed up code review, and reduce onboarding time for new teammates (including future-you).
    - [ ] There was a great youtube video about *not* naming things, if it was reasonable to just inline a variable or not introduce an abstract class layer.
- **Trade-off Thinking:** Explicitly weighing cost/benefit improves technical decisions and prevents expensive “optimizing the wrong thing.”
    - Helps you justify choices to stakeholders (performance vs. correctness vs. time-to-ship vs. maintenance).
- **Code as Communication:** Writing for readers reduces review churn, prevents subtle bugs, and makes incident response faster because the intent is discoverable.
- **Pattern Recognition (and Anti-Pattern Detection):** Spotting “this looks like that outage/bug class” helps you prevent repeats and build safer systems.
- **Deep Debugging Skill:** Hypothesis-driven debugging reduces MTTR and makes you reliable under pressure.
    - You become the person who can turn a vague symptom into a precise fix (or a precise rollback).
- **Engineering Judgment / Taste:** Knowing when to refactor, when to simplify, and when to ship increases delivery predictability and reduces long-term maintenance cost.
- **Empathy for Users and Collaborators:** Designing usable APIs and writing kind, actionable reviews reduces support load and raises team throughput.
- **Continuous Learning:** Adapting to new tools/frameworks keeps you effective as the stack changes, without thrashing or chasing novelty.

## Overrated smart signals

- **Big Words / Jargon Fluency:** Sounding sophisticated can hide shallow understanding; clarity beats impressiveness.
- **Answering Quickly:** Speed is often a proxy for familiarity, not depth, nuance, or good judgment.
- **High IQ:** It captures a narrow slice of ability and misses practical intelligence and context sensitivity.
- **Being a Walking Encyclopedia:** Memorizing facts is less valuable than finding, evaluating, and applying information well.
- **Always Being Right:** Protecting correctness can block learning; updating beliefs is the real skill.
- **Emotional Detachment / Pure Rationality:** Ignoring emotion can reduce empathy and distort decisions in human-centered problems.
- **Elite Credentials:** Credentials correlate imperfectly with flexible thinking, creativity, or real-world effectiveness.
- **Contrarianism:** Disagreeing by default is performative; independent thinking is evidence-based.
- **Confidence:** Confidence is easy to fake; calibration (knowing when you’re unsure) is rarer and more useful.
- **Being Good at Arguing:** Debate skill can optimize for winning rather than truth-seeking or collaborative understanding.

### In software engineering

- **Knowing Many Languages:** Breadth looks impressive, but it matters less than transferable fundamentals (testing, debugging, concurrency, data modeling).
- **Clever / Dense Code:** “Smart” one-liners often increase defect rates and slow everyone down because comprehension becomes the bottleneck.
- **The 10x Lone Wolf Myth:** Solo heroics don’t scale; you become a delivery risk if the team can’t maintain or extend what you built.
- **Memorizing Framework Internals:** Useful sometimes, but less impactful than learning how to read source/docs quickly and reason from first principles.
- **Winning Code Review Arguments:** If you optimize for being right, you reduce trust and collaboration; outcomes improve when the team converges on the best idea.
    - Being able to say “good point, let’s do that” is a productivity multiplier.
- **Being the Fastest Coder:** Speed without validation creates rework; high-performing engineers optimize for correct, maintainable output per week, not lines per hour.

