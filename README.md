# Spiral

A lightweight, MVP-first framework for Claude Code — built as a set of custom skills.

Spiral is for the way most people actually build software: have an idea, think it through in your head, bang out features until you have something usable, *then* refine. It deliberately strips out the upfront ceremony (deep research, multi-phase roadmaps, gated verification) that other frameworks impose between you and working code.

## Philosophy

You build in **spirals**, not waterfalls. Get to a usable MVP fast, use it, and let real usage tell you which edges actually matter. Most "obscure edge cases" you'd test for in week 1 turn out to be irrelevant by week 3 because the design shifted.

Spiral encodes three rules:

1. **Happy path first.** Edges, tests, error states, and polish are captured as *deferred TODOs* during the build, never blocking progress.
2. **You triage hardening, not the framework.** When you do harden, you decide per-TODO: keep / drop / later. Hardening is never all-or-nothing.
3. **No subagents, no gates between waves.** Direct execution, atomic commits, you stay in control.

## The flow

```
/spiral-new-project  →  /spiral-sketch  →  /spiral-build  →  (use it)  →  /spiral-harden
                              ↑                                              │
                              └──────────────  next phase  ──────────────────┘

         /spiral-research  ←—  callable anytime, by you or the agent
         /spiral-todo      ←—  park ideas as they surface; sketch picks them up
         /spiral-fix       ←—  bug found while using a built phase? patch it here
```

## The skills

| Skill | What it does |
|---|---|
| `/spiral-new-project` | Three questions, scaffolds `.spiral/`, no roadmap. Run once. |
| `/spiral-sketch` | Captures your mental plan for one phase. Combines discuss + plan, no interrogation. Offers to bundle outstanding TODOs. |
| `/spiral-build` | Executes the happy path. Captures deferred TODOs inline. Atomic commits per task. |
| `/spiral-harden` | Two steps you control: goal check + deferred-TODO triage. Selective. |
| `/spiral-fix` | Patch a bug found in usage. Single-shot: identify, fix, commit, log on the source phase. |
| `/spiral-todo` | Park an idea in `.spiral/TODO.md` so you don't forget it. `/spiral-sketch` picks them up later. |
| `/spiral-research` | *Optional.* Focused web/doc lookup for one specific question. Conversational by default; pass `--save` to persist. |

Each skill's full behavior lives in `skills/<skill-name>/SKILL.md`.

## Install

```bash
./setup.sh
```

The script:
1. Verifies Claude Code is installed.
2. Copies the `spiral-*` skills into `~/.claude/skills/`.
3. Prints a usage guide.

To pick up local edits to a skill after install, re-run `./setup.sh`.

## Project state

Spiral keeps everything in a single directory at the root of your project:

```
.spiral/
├── PROJECT.md              # one-paragraph project intent
├── TODO.md                 # parking lot for ideas (created on first /spiral-todo)
└── phases/
    ├── 1-magic-link-auth.md   # one file per phase, all sections inline
    ├── 2-dashboard-shell.md
    └── ...
```

Each phase file holds its own Sketch, Deferred TODOs, Harden Notes, and Fixes — no per-phase folders, no file sprawl.

## Phase status lifecycle

`sketched` → `building` → `built` → `hardened` (or `hardened-partial`)

`/spiral-harden` can fail back to `/spiral-build` if the goal check finds the intent isn't met — don't write tests for half-built features.

## When NOT to use Spiral

- Production-critical infrastructure where every edge case matters from day one.
- Compliance-driven work where verification gates are required by policy.
- Large team coordination where upfront roadmaps reduce conflict.

For those, use GSD or another heavier framework. Spiral is for the solo or small-team builder optimizing for time-to-usable.

## Contrast with GSD

| | GSD | Spiral |
|---|---|---|
| Per-feature commands | discuss → plan → execute → verify | sketch → build → harden |
| Tests/edges | Inline, blocking each wave | Deferred to harden, user-triaged |
| Subagents | Many, parallel | None |
| Project init | Multi-agent research, roadmap | 3 questions, single file |
| File sprawl | Per-phase directory + many docs | Single file per phase |
| Time to first code | Hours | Minutes |
