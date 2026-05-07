---
name: spiral-new-project
description: "Lightweight project init for greenfield or existing repos — capture intent in ~5 minutes, scaffold .spiral/, no upfront roadmap or research ceremony. Phases emerge as you sketch them."
argument-hint: "[optional one-line project description]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

<philosophy>
GSD's new-project spawns research agents, generates a multi-phase roadmap, and asks for deep context before any code is written. Spiral does the opposite: capture the intent in a few sentences, scaffold a single file, and get out of the way. Phases emerge from `/spiral-sketch` as the user goes — no upfront roadmap.

Works for two cases:
- **Greenfield** — empty (or near-empty) directory. Ask for intent, scaffold, done.
- **Existing repo** — code already present. Same intent questions, plus a *brief* codebase read (manifest + top-level dirs) that gets folded into PROJECT.md. No analysis docs.

Total time from invocation to first sketch should be under 10 minutes in either case.
</philosophy>

<process>

## Step 1 — Check state and detect mode
- If `.spiral/` already exists, ask the user: "Project already initialized. Re-init or continue with existing?" Only proceed if they confirm re-init.
- If working directory is not a git repo, ask once: "Not a git repo — want me to `git init` so atomic commits work?" Default: yes.
- **Detect mode.** Run a quick `ls -A` and check for source signals (a manifest like `package.json`/`Cargo.toml`/`pyproject.toml`/`go.mod`/`Gemfile`, or any source-code files outside `.git/` and dotfiles).
  - **Greenfield** — empty or only contains `.git/`, `README.md`, `.gitignore`, license. Proceed normally.
  - **Existing** — has code or a manifest. You'll do a brief read in Step 2.5.

## Step 2 — Gather minimal intent
Ask only these questions, conversationally. Skip any that the user already answered in their invocation arg.

1. **One-sentence pitch** — "What is this thing?" (For existing repos, frame it as: "What are you trying to build *with* it from here?" — intent now, not what's already there.)
2. **Who's it for** — "Just you? Internal team? Public users?" (default: just you)
3. **The first thing you want to build** — "What's the first phase you'd sketch right now?"

That's it. Three questions, not twenty. Do not ask about:
- Tech stack — for existing repos you'll read it in Step 2.5; for greenfield, ask only if the user wants guidance.
- Success metrics, KPIs, or business goals.
- Stakeholders, risks, dependencies.
- Future phases or roadmap.
- Architecture decisions.

If greenfield and the user hasn't mentioned a stack, ask **one** combined question: "Any stack preferences, or pick whatever fits?"

## Step 2.5 — Brief codebase read (existing repos only)
Skip this step entirely for greenfield. For existing repos, do a *fast* read — under 60 seconds, no recursion into source.

Read at most:
- The primary manifest (`package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / etc.) — extract language, framework, key deps.
- `README.md` if it's short (<100 lines). Skip if longer; the user's pitch is the source of truth for intent.
- Top-level directory listing (`ls -A`, no recursion) — note 3–6 directories worth mentioning (e.g. `src/`, `app/`, `tests/`, `migrations/`).

Capture findings as ~3–6 terse bullets for the PROJECT.md "Stack & Layout" section. Examples:
- `Stack: TypeScript, Next.js 15, Postgres via Drizzle`
- `Top-level: app/, components/, lib/, drizzle/`
- `Tests: vitest in tests/`

**Do not:**
- Read source files beyond the manifest and short README.
- Generate a CODEBASE.md, ARCH.md, or any analysis doc.
- Recurse into `src/` or run Grep across the tree.
- Comment on code quality, conventions, or refactor opportunities.

If anything is genuinely ambiguous after this scan (e.g. two manifests for two different stacks), ask **one** clarifying question. Otherwise proceed.

## Step 3 — Scaffold

Create the directory structure:

```
.spiral/
├── PROJECT.md
└── phases/
    └── (empty for now)
```

Write `.spiral/PROJECT.md`:

```markdown
# <Project Name>

**Started:** <YYYY-MM-DD>
**For:** <audience from Q2>
**Mode:** <greenfield | existing repo>

## What this is
<One sentence pitch from Q1.>

## Stack & Layout
<For existing repos: 3–6 bullets from Step 2.5 (language, framework, top-level dirs, test runner). For greenfield: stack choice if any was made, otherwise omit this section.>

## Notes
<Anything else useful that came up. Constraints, links, future ideas. Keep terse.>
```

Do **not** create:
- A ROADMAP.md.
- A REQUIREMENTS.md.
- A research/ subdirectory.
- A milestones/ structure.
- A CODEBASE.md / ARCH.md / analysis files of any kind (even for existing repos).
- Any subagent output files.

## Step 4 — Hand off

Tell the user:
- "Project scaffolded at `.spiral/PROJECT.md`."
- "First phase you mentioned: `<their answer to Q3>`."
- "Run `/spiral-sketch <that phase>` when ready, or just say it conversationally."

If they answered Q3 with a clear first phase, **offer** to invoke `/spiral-sketch` immediately with that as the input. Don't assume — ask.

</process>

<conventions>

**No roadmap.** Phases emerge one at a time. The user does not need to commit to phases 2-N upfront. If they want a list of future phases, they can keep notes in PROJECT.md → `## Notes` informally.

**PROJECT.md is short.** Aim for under 30 lines (40 max for existing repos with a Stack & Layout section). If it's getting long, you're capturing too much; trust the user to fill in details when sketching specific phases.

**Skip research.** No web searches, no domain investigation, no competitive analysis. The user has an idea and wants to build. Research happens organically inside `/spiral-sketch` or `/spiral-build` when actually needed.

</conventions>

<anti_patterns>
Slipping back into GSD ceremony if you:
- Spawn any subagent.
- Generate more than one file (PROJECT.md plus the directory).
- Ask more than 3 questions before scaffolding (4 for existing repos if one disambiguation is needed after the codebase read).
- Suggest a roadmap, milestones, or success criteria.
- Recommend a stack the user didn't ask for guidance on.
- Run for more than ~10 minutes total.

Existing-repo specific anti-patterns:
- Reading more than the manifest + short README + top-level `ls`.
- Recursing into `src/` or grepping for patterns "to understand the codebase."
- Generating a CODEBASE.md, ARCH.md, conventions doc, or any analysis output.
- Critiquing the existing code or suggesting refactors.
- Asking the user to explain what the code already does — read it yourself, briefly.
</anti_patterns>
