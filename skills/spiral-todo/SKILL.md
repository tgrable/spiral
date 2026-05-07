---
name: spiral-todo
description: "Capture an idea or follow-up so it isn't forgotten. Append to a flat .spiral/TODO.md, or list current items if no args. /spiral-sketch picks them up later."
argument-hint: "[short description of the idea] (no args = list current TODOs)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

<philosophy>
The TODO list is a parking lot, not a backlog. The user noticed something while working — a feature idea, a refactor, a follow-up — and doesn't want to context-switch into sketching it right now. They want to drop it somewhere safe and keep moving.

`/spiral-sketch` is what eventually consumes these. When the user starts a new phase, sketch will offer to bundle outstanding TODOs into the Rough Tasks. That's the bridge from "noted idea" to "active phase."

Keep this skill **minimal**. No priorities, no tags, no due dates, no editing — just append and list. The user can edit `.spiral/TODO.md` by hand if they want. Add features only when real usage shows they're needed.
</philosophy>

<inputs>
- Args present → append a new TODO with that text.
- No args → read `.spiral/TODO.md` and list current items.
</inputs>

<process>

## Step 1 — Verify project state
Check `.spiral/PROJECT.md` exists. If not, tell the user to run `/spiral-new-project` first and stop.

## Step 2 — Branch on args

### If args present (append mode)
1. If `.spiral/TODO.md` doesn't exist, create it with this header:
   ```markdown
   # Spiral TODOs

   Outstanding ideas and follow-ups. Curated into phases via /spiral-sketch.
   ```
2. Append a single line at the end of the file:
   ```
   - [ ] [YYYY-MM-DD] <user's text verbatim>
   ```
   Use today's date. Don't paraphrase or "improve" the user's wording.
3. Print a one-line confirmation: **"Added — `.spiral/TODO.md` now has N items."**

### If no args (list mode)
1. If `.spiral/TODO.md` doesn't exist or has zero unchecked items, say: **"No outstanding TODOs."** and stop.
2. Otherwise, print the unchecked items in the order they appear in the file:
   ```
   Outstanding TODOs (N):
     1. [2026-05-04] <text>
     2. [2026-05-05] <text>
     ...
   ```
3. Add a one-line tail: **"Run `/spiral-sketch` to bundle any of these into a new phase."**

</process>

<conventions>

**Single flat file, no per-phase TODO lists.** The whole point is one parking lot the user can dump into without thinking about which phase it belongs to. Categorization happens at sketch time, if at all.

**Append-only from the skill.** Don't edit, reorder, deduplicate, or "clean up" the list. The user owns the file. If they want to merge duplicates, they will.

**Verbatim text.** Whatever the user typed goes in. Don't reword for grammar or clarity — they wrote it that way for a reason and may rely on the exact phrasing as a memory cue.

**Date is the only metadata.** No category, no priority, no phase pointer. Keep the line format dead simple: `- [ ] [YYYY-MM-DD] <text>`.

**Done items are removed by sketch, not by this skill.** When `/spiral-sketch` pulls a TODO into a phase's Rough Tasks, sketch deletes that line from `.spiral/TODO.md`. The user can also delete or check off lines manually. This skill never touches the `[ ]` state.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Add categories, tags, priorities, or owners.
- Ask follow-up questions about the TODO ("how urgent?" "which phase?"). Just append.
- Try to suggest related work or "bundle similar TODOs."
- Reformat the existing file when appending.
- Generate a separate file (TODO_INDEX.md, ideas/, etc.).
- Spawn a subagent.
</anti_patterns>
