---
name: spiral-sketch
description: "Lightweight planning for a new phase — capture intent, happy path, and rough tasks. Combines what GSD splits across discuss + plan, without the interrogation."
argument-hint: "[phase name or short description of what to build]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

<philosophy>
The user has already done most of the planning in their head. Your job is to **capture** their thinking, not interrogate it. Ask only when something is genuinely ambiguous — never ask questions whose answers you could reasonably guess from the request itself.

A good sketch takes 5–10 minutes, not an hour. Output should be just enough structure that `/spiral-build` has something to work from.
</philosophy>

<inputs>
The user invokes this with a brief description like "user auth with email magic links" or "dashboard for viewing recent runs".

If they invoke with no args, ask one question: "What do you want to build in this phase?" Then proceed.
</inputs>

<process>

## Step 1 — Verify project state
Check that `.spiral/PROJECT.md` exists. If not, tell the user to run `/spiral-new-project` first and stop.

Read `.spiral/PROJECT.md` for context. Read `.spiral/phases/` to find the next phase number (N = highest existing number + 1, or 1 if none exist).

## Step 2 — Quick pattern scan (optional, fast)
If the codebase is non-trivial, do **one** quick scan with Grep/Glob to find the closest existing patterns to the feature being built. This is a 30-second sanity check, not a research phase. Skip if the project is empty or it's obvious where the new code goes.

## Step 3 — Check outstanding TODOs
Read `.spiral/TODO.md` if it exists. Skip this step if the file is missing or has zero unchecked items.

If there are unchecked items, list them inline and ask:

```
I see N outstanding TODOs in .spiral/TODO.md:
  1. [2026-05-04] <text>
  2. [2026-05-05] <text>
  ...

Want to bundle any into this phase? (e.g. "1, 3" or "none")
```

Accept input flexibly — numbers, ranges, "all", "none".

For each selected TODO:
- Add it to the phase's Rough Tasks list (verbatim text, with `- [ ]`).
- Remove that line from `.spiral/TODO.md`.

For each unselected TODO:
- Leave it in `.spiral/TODO.md` untouched.

If the user picks "none", proceed without modifying anything. Don't push them — the parking lot is supposed to be lossless until they decide.

## Step 4 — Draft the sketch
Write `.spiral/phases/N-<slug>.md` directly. Use this exact template:

```markdown
# Phase N: <Title>

**Status:** sketched
**Created:** <YYYY-MM-DD>

## Intent
<One sentence — what this phase delivers when done.>

## Happy Path
<1–3 bullets describing what success looks like when the user actually uses the thing. No edge cases here.>

## Rough Tasks
- [ ] <task 1 — file or component level, not line level>
- [ ] <task 2>
- [ ] <task 3>

## Out of Scope
<Anything explicitly NOT in this phase. Be honest about what gets deferred.>

## Open Questions
<Only list things you genuinely cannot proceed without. If empty, delete this section.>

## Deferred TODOs
<Empty initially. Populated during /spiral-build as edges, tests, and polish surface.>

## Harden Notes
<Empty initially. Populated during /spiral-harden.>
```

## Step 5 — Ask only what's necessary
Before finalizing, scan the sketch for blockers. Ask the user **only** if:
- The intent is genuinely ambiguous (e.g., they said "add auth" — which kind?)
- A task can't be defined without a decision (e.g., "which DB?" when none is chosen)
- There's a fork that significantly changes scope

**Do not ask:**
- Questions to confirm what's already obvious from context.
- Edge cases ("what if the user is offline?") — those go in Deferred TODOs during build.
- Test strategy — that's harden's problem.
- Anything that has a sensible default.

If you have 0 questions, that's the goal. 1–2 is fine. 3+ means you're falling back into GSD interrogation mode — re-read the request and prune.

## Step 6 — Confirm
Show the user the sketch. Ask: **"Look right? Anything to adjust before we build?"**

When they confirm, mark the sketch as ready and remind them to run `/spiral-build N` (or just `/spiral-build` for the latest phase).

</process>

<conventions>

**Phase naming:** `N-<kebab-slug>` where slug is 1–4 words. e.g. `1-magic-link-auth`, `2-dashboard-shell`.

**Tasks should be file/component-level, not line-level.** "Add login route" is a task. "Add `req.body.email` validation" is implementation detail and goes in the route's code, not the sketch.

**Out of Scope is required.** Even a one-line "no email verification yet" — being explicit about deferrals is core to the spiral philosophy.

**Don't write code in the sketch.** Pseudo-code only if essential to communicate intent. The sketch is a contract, not an implementation.

</conventions>

<anti_patterns>
Things that mean you're slipping back into GSD ceremony mode and should stop:
- Asking 4+ questions before writing the sketch.
- Generating a research document.
- Spawning subagents.
- Writing more than ~40 lines in the sketch file.
- Including a "Risks and mitigations" section.
- Asking about test strategy.
</anti_patterns>
