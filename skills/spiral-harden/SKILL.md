---
name: spiral-harden
description: "Goal-check a built phase against its intent, then triage deferred TODOs (tests, edges, polish). Two distinct steps the user can run separately."
argument-hint: "[phase number] [optional: --goal-only | --robustness-only]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

<philosophy>
Harden is **two distinct steps**, not one combined pass:

1. **Goal check** — did the built code actually deliver the phase's Intent and Happy Path? If no, harden stops and the user goes back to `/spiral-build`. Don't write tests for a feature that doesn't yet meet its own goal.
2. **Robustness** — triage the Deferred TODOs accumulated during build. Tests, edges, polish, the things you skipped. The user picks what's worth doing now versus dropping versus deferring further.

The user must be in control of which deferred items get addressed. Hardening is *not* "do everything in the deferred list" — that's exactly the over-completion trap they're escaping.
</philosophy>

<inputs>
- Phase number (defaults to most recent `built` phase).
- Optional flags:
  - `--goal-only` — run step 1, skip step 2.
  - `--robustness-only` — skip step 1 (assume goal already verified).
  - default = run both, with a confirmation between them.
</inputs>

<process>

## Step 0 — Load
Read the phase file. Status must be `built` or `hardened` (re-hardening allowed). If status is `building`, tell the user to finish `/spiral-build` first and stop.

## Step 1 — Goal Check (skip if --robustness-only)

Read the phase's Intent and Happy Path sections.

**Verify, don't interrogate.** Walk through the codebase yourself first:
- Trace the happy path through the actual code. Can a real user execute each bullet?
- Run the thing if possible (start the dev server, hit the endpoint, render the component).
- Check for obvious gaps where the code looks like a stub.

Write findings into the phase file under `## Harden Notes` → `### Goal Check (<date>)`:

```markdown
### Goal Check (YYYY-MM-DD)

**Verdict:** met | partially-met | not-met

**Evidence:**
- <bullet — what you checked and what you found>
- <bullet>

**Gaps (if any):**
- <what's missing for the intent to be considered delivered>
```

If verdict is `not-met` or `partially-met`:
- List the gaps clearly.
- Recommend: "These should go back to `/spiral-build` as fresh tasks, not be addressed in harden."
- Offer to append the gaps as new tasks in the Rough Tasks section.
- **Stop here.** Do not proceed to robustness.

If verdict is `met`:
- Tell the user the goal is met and ask: **"Ready to triage Deferred TODOs, or stop here?"**
- If they stop, mark status `hardened` and exit.

## Step 2 — Robustness (skip if --goal-only or if user opted out)

Read the `## Deferred TODOs` section. Group by category (test, edge, polish, perf, a11y, docs).

Present the grouped list to the user and ask them to triage. Use this format:

```
Deferred TODOs for Phase N:

  Tests (3):
    1. <description>
    2. <description>
    3. <description>

  Edges (2):
    4. <description>
    5. <description>

  Polish (1):
    6. <description>

For each, mark: [k]eep / [d]rop / [l]ater
```

Accept input flexibly: "1k 2d 3k 4l 5d 6k" or "all keep" or "tests yes, polish no" — interpret naturally.

**For each KEPT item:**
- Implement it.
- Atomic commit per item, message: `harden N: <description>`.
- Mark the TODO as completed in the phase file: `- [x] <description>`.

**For each DROPPED item:**
- Remove it from the Deferred TODOs section.
- Append to a `### Dropped` subsection with a one-line reason if the user gave one.

**For each LATER item:**
- Leave it in Deferred TODOs.
- Move to bottom of the list.

## Step 3 — Wrap up

Update phase status:
- All TODOs handled (kept or dropped, none in `later`) → status: `hardened`.
- Some TODOs in `later` → status: `hardened-partial`.

Print a short summary:
- Goal check verdict (if run).
- Counts: kept (now done), dropped, later.
- Suggest next: `/spiral-sketch <next idea>` if the user wants to start a new phase.

</process>

<conventions>

**Goal check before robustness, always.** A failing goal check means more building is needed — writing tests for a half-built feature is wasted work because the code will change.

**The user triages, you don't.** Never decide unilaterally to drop or skip a deferred TODO during step 2. Always present the list and let the user mark each one.

**Don't grow the deferred list during harden.** If you discover a new edge case while hardening, *fix it now* if it's small, or surface it explicitly to the user. Don't silently push more work into Deferred TODOs — that's a treadmill.

**Re-running harden is fine.** If the user runs `/spiral-harden N` after already hardening, just operate on the remaining `later` items.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Auto-decide which deferred TODOs are "important" and silently address them.
- Generate a separate VERIFICATION.md, HARDEN.md, or REVIEW.md file. Everything stays in the phase file.
- Ask the user 10 questions about test strategy before writing a test. Just write the test using whatever testing tool the project already uses.
- Block on writing tests when no test runner is configured. If there's no test setup, ask the user once if they want to set one up — if no, drop the test TODOs and note that.
- Refuse to mark `hardened` because edge cases might still exist somewhere. The user explicitly chose what to harden.
</anti_patterns>
