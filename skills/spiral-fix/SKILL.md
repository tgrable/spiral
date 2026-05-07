---
name: spiral-fix
description: "Patch a bug found in usage. Single-shot: identify, fix, commit, log on the source phase. No sketch ceremony, no harden gate."
argument-hint: "[short description of the bug] [optional: phase number]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

<philosophy>
`/spiral-fix` is for the bug you just found while *using* the thing. Something built and shipped, now misbehaving. The user does not want a sketch, a plan, a wave structure, or a verification step — they want the bug gone and a record of what changed.

This is the skill that closes the spiral loop: you built it, you used it, you found something off, you fix it. Real-usage feedback is the whole point of MVP-first, and fixes are how that feedback turns into code.

**Scope discipline is everything here.** Fix the reported bug. Nothing else. Related issues become deferred items, not extra work in this commit.
</philosophy>

<inputs>
- Optional bug description as args (e.g., `/spiral-fix login button does nothing on Safari`).
- Optional phase number as a trailing arg (e.g., `/spiral-fix login button broken 2`).
- If no description: ask once — "What's broken?"
- If no phase number: try to infer from context, ask only if ambiguous.
</inputs>

<process>

## Step 1 — Verify project state
Check `.spiral/PROJECT.md` exists. If not, this isn't a Spiral project — tell the user and stop.

## Step 2 — Get the bug description
If the user passed a description, use it. If not, ask one question: **"What's broken?"** Get a one-or-two sentence answer and proceed.

## Step 3 — Identify the source phase
The fix gets logged on the phase that originally introduced the broken code.

**Try to infer first** (don't make the user think):
- If the user passed a phase number, use it.
- Otherwise, scan `.spiral/phases/` and look for a phase whose Intent or Happy Path mentions the affected feature.
- If recent git history shows the relevant files were touched in `phase N: ...` commits, use N.

**Ask only when truly ambiguous:**
> "Looks like this could touch phase 2 (auth) or phase 4 (dashboard) — which one introduced this?"

If the bug is in code that predates `.spiral/` (or spans many phases), log it on the most recently `built` phase and note that in the Fixes entry.

## Step 4 — Investigate
Read the relevant files. Reproduce the bug mentally (or with a quick test if one exists). You're looking for the *root cause*, not a symptom patch.

If the investigation reveals the bug is much bigger than reported (e.g., "the auth token is structurally wrong everywhere"), **stop and tell the user**. Offer to either:
- Fix the immediate symptom now and capture the deeper issue as a TODO via `/spiral-todo`, or
- Abort `/spiral-fix` and sketch a proper phase via `/spiral-sketch`.

Do not silently expand scope.

## Step 5 — Patch
Apply the minimum change that fixes the reported bug. Same rules as `/spiral-build`:

- Happy-path fix only. Don't add input validation, defensive checks, or error UI unless that *is* the bug.
- Don't refactor surrounding code.
- Don't add tests during the fix. If a test would have caught this, append it as a deferred TODO in the source phase file:
  ```
  - [ ] regression test for <bug> — category: test
  ```
  Then keep moving.

If you spot related issues during the fix, capture each one as a one-line entry via the conventions of `/spiral-todo` (or just append to `.spiral/TODO.md` directly):
```
- [ ] [YYYY-MM-DD] <related issue noticed during fix for X>
```

## Step 6 — Verify the fix manually
Confirm the patched code actually resolves the reported bug. Run the dev server, hit the endpoint, render the component — whatever the fastest path is.

If you can't verify without the user (e.g., you can't reach a real device, you don't have credentials), say so explicitly: **"Patch applied. I couldn't run it myself — please confirm the bug is gone."** Don't claim the fix works when you didn't observe it work.

## Step 7 — Commit atomically
One fix → one commit.

```
fix phase N: <one-line bug summary>
```

No long body. The phase file's Fixes log carries the context.

## Step 8 — Log on the phase file
Append (or create) a `## Fixes` section in `.spiral/phases/N-<slug>.md`. Place it after `## Harden Notes` (or after `## Deferred TODOs` if Harden Notes isn't there yet).

Entry format:

```markdown
## Fixes

### YYYY-MM-DD — <one-line bug summary>
- **Symptom:** <what the user saw / what was broken>
- **Cause:** <root cause in one line>
- **Fix:** <what changed, file-level not line-level>
- **Commit:** <short sha or commit subject>
```

Each fix gets its own dated subsection. Newest at the bottom (chronological).

Do **not** change phase status. A fix doesn't promote `built` → `hardened` and doesn't demote `hardened` → `building`. The phase already represented its scope; this is post-hoc maintenance.

## Step 9 — Wrap up
Print a short summary:
- One-line: what was broken, what changed.
- Where it was logged (`.spiral/phases/N-<slug>.md`).
- Any TODOs you captured for related issues (count + file).

If the bug is the *third or more* you've fixed in the same phase, gently flag it: **"That's N fixes on phase X — worth considering a small harden pass or a follow-up phase if a pattern is emerging."** Don't push, just note.

</process>

<conventions>

**Always log, even for trivial fixes.** The audit trail is cheap and the phase file becomes the living record of what that feature has been through. A one-line typo fix still gets a Fixes entry.

**Phase inference > asking.** Spiral's whole pitch is no interrogation. If you can guess the phase with reasonable confidence from the file paths or commit history, just use it and tell the user which one you picked. They'll correct you if wrong.

**Atomic commits, no exceptions.** One bug → one commit. If you find two bugs while investigating, fix one, commit, then run `/spiral-fix` again for the second. Never bundle.

**A fix is not a feature.** If the "fix" requires a new module, a schema change, or touches more than a handful of files, you're really sketching a phase. Stop and tell the user to run `/spiral-sketch` instead.

**Status field unchanged.** Fixes don't move the phase through the lifecycle. The phase already shipped its scope; this is upkeep.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Generate a separate FIX.md, INCIDENT.md, or POSTMORTEM.md. The phase file is the only record.
- Spawn a subagent to investigate the bug.
- Write tests "to prevent regression" without the user asking. Defer them.
- Refactor adjacent code "while you're in there." Out of scope.
- Ask the user three questions before patching. One question max — "what's broken?" — and only if they didn't say.
- Bundle multiple unrelated fixes into one commit.
- Promote or demote the phase status. Fixes don't change lifecycle state.
</anti_patterns>
