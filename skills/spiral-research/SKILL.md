---
name: spiral-research
description: "Answer one specific technical question via focused web/doc lookup. Default output is conversational, not a file. The only spiral skill that uses a subagent — for context isolation, not parallelization."
argument-hint: "[a specific question] [--save]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Grep
  - Glob
  - WebFetch
  - WebSearch
  - Agent
---

<philosophy>
Research is the *one* place spiral allows ceremony — but only because not knowing how a library works wastes more time than a 5-minute lookup. The skill is bounded by three rules to keep it from sliding back into GSD-style research phases:

1. **One question per invocation.** Specificity is required.
2. **Conversational output by default.** A file is created only when explicitly saved.
3. **Subagent for context isolation, not parallelization.** Spawn one researcher, not four.
</philosophy>

<inputs>
- A question. Required.
- `--save` flag (optional). If present, persist findings to `.spiral/research/<slug>.md`. If absent, output stays in the chat.
- Project state is **not** required. This skill works standalone — sometimes you research to decide whether a project is worth starting.
</inputs>

<process>

## Step 1 — Validate the question

If the question is vague (e.g. "research auth", "look into databases", "tell me about React"), do **not** proceed. Reply with:

> "Narrow this down. Try a specific question like:
> - 'What's the simplest way to add magic-link auth to Next.js 15?'
> - 'How does Postgres LISTEN/NOTIFY compare to a polling approach for sub-second updates?'
> - 'What are the three most common pitfalls when integrating Stripe webhooks?'"

Then stop and wait. Do not guess at what the user meant.

If the question is specific enough, proceed.

## Step 2 — Decide if a subagent is warranted

Spawn a subagent (`general-purpose` or `Explore`) **only when**:
- The question requires fetching multiple web pages or doc sources.
- The answer would otherwise pollute main context with library docs / search results / code samples you don't need to keep.

For questions you can answer from your existing knowledge in 2–3 sentences with high confidence, **just answer directly.** Don't burn a subagent on "what's the syntax for a Python list comprehension?"

## Step 3 — Run the research

If using a subagent, brief it tightly:

```
Research the following specific question and return a focused answer.

Question: <the user's question>

Constraints:
- Answer in under 400 words.
- Include 2-4 code snippets if relevant, with one-line context each.
- Include source URLs for any non-obvious claims.
- Do NOT survey the entire space — focus on the question asked.
- Do NOT recommend further research directions.
- If the question is ambiguous, return one paragraph noting the ambiguity and the assumption you made.
```

If answering directly, write the same shape inline: under 400 words, snippets with context, sources for non-obvious claims.

## Step 4 — Surface the answer

Print the result to the chat in this shape:

```
## Research: <question>

<2-3 sentence direct answer to the question>

### Key points
- <bullet>
- <bullet>
- <bullet>

### Code / examples
<snippets with one-line context if relevant>

### Sources
- <url> — <one-line description>
- <url> — <one-line description>
```

Aim for a single screen. If the answer is genuinely longer than that, the question was probably too broad — call that out.

## Step 5 — Save (only if --save)

If `--save` was passed:
1. Determine the directory:
   - If `.spiral/` exists → save to `.spiral/research/<slug>.md`.
   - If `.spiral/` doesn't exist → ask the user where to save (or default to current directory as `research-<slug>.md`).
2. Generate a kebab-case slug from the question (3–5 words).
3. Write the same content shown in Step 4 to that file, prefixed with frontmatter:
   ```
   ---
   question: <original question>
   date: <YYYY-MM-DD>
   ---
   ```
4. Confirm to the user: "Saved to <path>."

If `--save` was not passed, do not write a file. The answer is in the chat — the user can copy it manually if they want, or re-run with `--save`.

## Step 6 — Suggest next step (optional)

If the research is clearly setting up a phase (e.g. the question was scoped to a build decision), end with a one-liner:

> "Want to sketch this as a phase? Run `/spiral-sketch <topic>`."

Otherwise, just stop.

</process>

<conventions>

**One question, one answer.** If the user asks "how does X work, and also Y, and what about Z?" — push back: "Pick one to start. We can run research again for the others."

**No follow-up surveys.** Don't end with "areas for further investigation." Spiral research closes the loop on a specific question; further questions are *new* invocations.

**Subagent briefings are tight.** If the subagent comes back with a 2000-word survey, you didn't constrain it enough. Re-prompt or trim aggressively before showing the user.

**Sources matter.** Any non-obvious claim needs a source URL. Don't fabricate them — if you can't find a source, say "based on common practice" and flag the lower confidence.

**Recency matters for moving libraries.** When researching a fast-moving framework (LLM SDKs, Next.js, etc.), explicitly check the date on doc sources and prefer ones from the last ~6 months. Note staleness if you find only old sources.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Spawn multiple subagents in parallel for the same question.
- Generate a multi-doc output (SUMMARY + DETAILS + REFERENCES).
- Write more than ~400 words of research output (or 800 if saved).
- Recommend "further reading" or "areas for further investigation" at the end.
- Save to a file when `--save` wasn't passed, even if you think it's "useful enough to keep."
- Insist on a specific output format when the answer is genuinely a 2-sentence reply.
- Refuse to answer simple questions because they "lack context" — just answer them.
</anti_patterns>
