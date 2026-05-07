#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_step() {
    echo ""
    echo -e "${BOLD}${BLUE}[$1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"
}

print_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "  ${RED}✗${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}!${NC} $1"
}

TOTAL_STEPS=3
ERRORS=0

echo ""
echo -e "${BOLD}Spiral — Setup${NC}"
echo "================================================"
echo "MVP-first framework for Claude Code. Build, use, refine."
echo "================================================"

# ──────────────────────────────────────────────
# Step 1: Check for Claude Code installation
# ──────────────────────────────────────────────
print_step 1 "Checking for Claude Code..."

if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    print_pass "Claude Code is installed (${CLAUDE_VERSION})"
else
    print_fail "Claude Code is not installed."
    echo ""
    echo "    Claude Code is Anthropic's CLI tool that these skills run inside."
    echo "    Install it with:"
    echo ""
    echo "      npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "    Then re-run this script."
    echo ""
    exit 1
fi

# ──────────────────────────────────────────────
# Step 2: Install skills
# ──────────────────────────────────────────────
print_step 2 "Installing skills..."

mkdir -p "$CLAUDE_SKILLS_DIR"

INSTALLED_SKILLS=()
for skill in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill")
    cp -r "$skill" "$CLAUDE_SKILLS_DIR/$skill_name"
    print_pass "Installed /$skill_name"
    INSTALLED_SKILLS+=("$skill_name")
done

# ──────────────────────────────────────────────
# Step 3: Usage guide
# ──────────────────────────────────────────────
print_step 3 "How to use Spiral"

echo ""
echo -e "  ${BOLD}Getting started:${NC}"
echo "    1. cd into the project you want to work in (or an empty directory"
echo "       for a brand new project)"
echo "    2. Start Claude Code by typing: claude"
echo "    3. Use the commands below inside the Claude Code session"
echo ""
echo -e "  ${BOLD}The typical flow:${NC}"
echo "    /spiral-new-project  →  /spiral-sketch  →  /spiral-build  →  (use it)  →  /spiral-harden"
echo ""
echo -e "  ${BOLD}Commands:${NC}"
echo ""
echo -e "    ${GREEN}/spiral-new-project${NC} [optional pitch]"
echo "      Lightweight project init. Three questions, scaffolds .spiral/,"
echo "      no upfront roadmap. Run once per project."
echo ""
echo -e "    ${GREEN}/spiral-sketch${NC} [phase name or short description]"
echo "      Captures your mental plan for a phase. Combines GSD's discuss +"
echo "      plan into one quick step. Asks only what's genuinely ambiguous."
echo ""
echo -e "    ${GREEN}/spiral-build${NC} [phase number]"
echo "      Executes the happy path for a sketched phase. Edges, tests, and"
echo "      polish get captured as deferred TODOs but never block progress."
echo "      Atomic commits per task."
echo ""
echo -e "    ${GREEN}/spiral-harden${NC} [phase number] [--goal-only|--robustness-only]"
echo "      Two steps you control: (1) goal check — did the phase deliver"
echo "      its intent? (2) deferred TODO triage — you mark each one"
echo "      keep / drop / later. Selective hardening, not all-or-nothing."
echo ""
echo -e "    ${GREEN}/spiral-fix${NC} [bug description] [optional phase number]"
echo "      Patch a bug found while using a built phase. Single-shot:"
echo "      identify, fix, atomic commit, log on the source phase file"
echo "      under ## Fixes. No sketch ceremony, no harden gate."
echo ""
echo -e "    ${GREEN}/spiral-todo${NC} [idea text]"
echo "      Park an idea in .spiral/TODO.md so you don't forget it."
echo "      No args lists current TODOs. /spiral-sketch offers to bundle"
echo "      them into the next phase's Rough Tasks."
echo ""
echo -e "    ${GREEN}/spiral-research${NC} [specific question] [--save]"
echo "      Optional. Answers one focused technical question via web/doc"
echo "      lookup. Conversational by default — pass --save to persist."
echo "      Works standalone, no project required."
echo ""
echo -e "  ${BOLD}Philosophy reminder:${NC}"
echo "    Spiral is MVP-first. Build until you can use the thing, then"
echo "    let real usage tell you what edges actually matter. Defer freely."
echo ""

# ──────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}${BOLD}Setup complete!${NC} ${#INSTALLED_SKILLS[@]} skills installed."
else
    echo -e "${YELLOW}${BOLD}Setup complete with warnings.${NC} ${#INSTALLED_SKILLS[@]} skills installed."
    echo -e "Review the warnings above before using the skills."
fi
echo "================================================"
echo ""
