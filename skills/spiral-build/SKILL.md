---
name: spiral-build
description: "Execute happy-path features for a phase. Capture edges, tests, and polish as deferred TODOs without blocking. Atomic commits, no inter-wave verification gates."
argument-hint: "[phase number, e.g. 1] (defaults to most recent sketched phase)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

<philosophy>
This is the **MVP-first** execution mode. The goal is for the user to be using working code as fast as possible — not to ship a hardened, fully-tested feature. Edges, error handling, tests, and polish are explicitly deferred to `/spiral-harden`.

The user has abandoned past projects because edge-case work blocked them from ever reaching usable functionality. Do not repeat that mistake here. **When in doubt, defer.**
</philosophy>

<inputs>
- Optional phase number. If omitted, find the most recent phase with status `sketched` or `building`.
- Read the phase file at `.spiral/phases/N-<slug>.md`.
</inputs>

<process>

## Step 1 — Load context
Read the phase file. If status is not `sketched` or `building`, ask the user to confirm before proceeding.

Set status to `building` in the phase file (one-line update at the top).

## Step 2 — Order the tasks
Look at the Rough Tasks list. Group them into waves where:
- **Wave** = a set of tasks that can run sequentially or in parallel without depending on each other.
- Most phases have 1–3 waves. If you find yourself planning 5+ waves, the phase is probably too big — flag this to the user and offer to split.

You don't need to write the wave plan to a file. Hold it in context.

## Step 3 — Execute waves
For each task:

1. **Implement the happy path.** Write code that works for the normal case described in the sketch's Happy Path section.
2. **Skip these by default:**
   - Input validation beyond what the framework already does.
   - Error handling for cases the user hasn't mentioned.
   - Loading/empty/error UI states unless they're in the Happy Path.
   - Unit tests, integration tests, e2e tests.
   - Logging, metrics, observability.
   - Accessibility polish.
   - Performance optimization.
3. **When you notice something worth doing later, capture it.** Append a single line to the phase file's `## Deferred TODOs` section:
   ```
   - [ ] <terse note> — <category: test|edge|polish|perf|a11y|docs>
   ```
   Then keep building. Do not stop to ask permission to defer.
4. **Commit atomically per task.** One task → one commit. Commit message format:
   ```
   phase N: <task description>
   ```
   No long bodies. The sketch is the context.

## Step 4 — When to ask the user
Stop and ask only when:
- A task in the sketch is genuinely ambiguous in a way that affects the happy path.
- You hit a real blocker (missing credential, broken dep, conflicting requirement).
- A change you need to make is **out of scope** of this phase per the sketch's Out of Scope section.

Do **not** ask:
- "Should I also handle error case X?" → defer.
- "Should I write a test for this?" → defer.
- "Should I refactor this nearby code while I'm here?" → no, unless it's blocking.

## Step 5 — Wrap up
When all Rough Tasks are checked off:

1. Update phase status to `built`.
2. Print a short summary to the user:
   - Tasks completed (count).
   - Deferred TODO count, grouped by category.
   - One-sentence "how to try it" — the actual command/URL/action to use the thing.
3. Tell the user: **"Try it out. When you're ready to verify intent and tackle deferred items, run `/spiral-harden N`."**

Do **not**:
- Run a verification step.
- Spawn a code reviewer.
- Generate a VERIFICATION.md or REVIEW.md.
- Suggest the next phase yet — let the user use this one first.

</process>

<conventions>

**Atomic commits, no exceptions.** One commit per task makes spiral-undo and spiral-harden's deferred-TODO triage clean. Bundling commits ("phase 1 wave 1") is the GSD anti-pattern that makes it hard to revert one bad task.

**Deferred TODOs are a feature, not technical debt.** They're the explicit, structured surface that `/spiral-harden` operates on. Every captured TODO is a future decision the user gets to make: keep, drop, or fix.

**Wave parallelization is internal.** Don't show the user "Wave 1 of 3 complete" updates — that's GSD ceremony. Just build. They'll see the commits.

**Status field values:** `sketched` → `building` → `built` → `hardened`.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Run tests before saying the phase is built.
- Ask the user to approve each wave.
- Write defensive code for cases the user didn't request.
- Generate any *.md file other than updating the phase file.
- Spawn subagents for review or verification.
- Write more than ~5 deferred TODOs per task — if a task generates that many, the task is genuinely incomplete and you should keep building, not defer.
</anti_patterns>
