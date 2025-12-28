---
description: Create a new implementation plan. Use --branch to also create a git feature branch.
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "TodoWrite", "AskUserQuestion"]
argument-hint: "topic" [--branch]
---

# Create New Implementation Plan

Create a new implementation plan file with optional git branch.

## Core Principles

- Use TodoWrite to track progress through phases
- Ask for user confirmation before git operations
- Generate unique identifiers using timestamp

## Arguments

Parse `$ARGUMENTS`:
- First argument (required): Topic/title for the plan (can be quoted string)
- `--branch`: Also create a git feature branch

---

## Phase 1: Validation
**Goal**: Ensure we're in a valid s2s project

**Actions**:
1. Check for s2s project files:
   - `.s2s/config.yaml` (standalone)
   - `.s2s/workspace.yaml` (workspace)
   - `.s2s/component.yaml` (component)
2. If none found: inform user to run `/s2s:proj:init` first and exit
3. Extract topic from `$ARGUMENTS`
4. If no topic provided: ask user for the plan topic

---

## Phase 2: Generate Identifiers
**Goal**: Create unique plan ID and optional branch name

**Actions**:
1. Generate timestamp in format: `YYYYMMDD-HHMMSS` (current local time)
2. Generate slug from topic:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Remove special characters (keep only a-z, 0-9, hyphens)
   - Truncate to max 50 characters
3. Create Plan ID: `{timestamp}-{slug}`
4. Create file path: `.s2s/plans/{plan-id}.md`

**If `--branch` flag present**:
5. Count existing feature branches to get next number
6. Generate branch name: `feature/F{NN}-{slug}` where NN is zero-padded

---

## Phase 3: Pre-flight Checks
**Goal**: Verify safe to proceed

**Actions**:
1. Check if plan file already exists (unlikely with timestamp, but verify)
2. Create `.s2s/plans/` directory if it doesn't exist

**If `--branch` flag present**:
3. Check git status for uncommitted changes
   - If dirty: warn user and ask if they want to proceed anyway
4. Verify current branch (store for reference)

---

## Phase 4: Confirmation
**Goal**: Get user approval before creating files

**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

Present to user:
- Plan topic: {topic}
- Plan ID: {plan-id}
- File path: `.s2s/plans/{plan-id}.md`
- Branch (if --branch): `feature/F{NN}-{slug}`

Ask: "Create this plan?"

---

## Phase 5: Create Plan
**Goal**: Generate plan file and optionally create branch

**Actions**:
1. Load plan template from `${CLAUDE_PLUGIN_ROOT}/templates/plan.md`
2. Apply substitutions:
   - `{Topic}` → User-provided topic
   - `{plan-id}` → Generated plan ID
   - `{branch-name}` → Generated branch name or "N/A"
   - `{timestamp}` → Current ISO timestamp
3. Write file to `.s2s/plans/{plan-id}.md`

**If `--branch` flag present**:
4. Create git branch: `git checkout -b feature/F{NN}-{slug}`
5. Update plan file with actual branch name

**For multi-repo workspace** (if component.yaml exists):
6. Note: Branch should be created in component repo only
7. If workspace coordination needed, inform user about `/s2s:git:branch`

---

## Phase 6: Update State
**Goal**: Register the new plan in state

**Actions**:
1. Read `.s2s/state.yaml` (or create if doesn't exist)
2. Add plan entry:
   ```yaml
   plans:
     "{plan-id}":
       status: "planning"
       branch: "{branch-name}"  # or null
       created: "{ISO timestamp}"
       updated: "{ISO timestamp}"
   ```
3. Write updated state.yaml

---

## Output

Present to user:

```
Implementation plan created!

Plan ID: {plan-id}
File: .s2s/plans/{plan-id}.md
Topic: {topic}
Status: planning
{Branch: feature/F{NN}-{slug}}  # if --branch

Next steps:
1. Edit the plan to add references and tasks
2. Run /s2s:plan:start "{plan-id}" when ready to begin
3. Use /s2s:decision:new if architectural decisions needed
```

---

## Error Handling

- **No topic provided**: Ask user for topic interactively
- **Not in s2s project**: Direct to `/s2s:proj:init`
- **Git dirty** (with --branch): Warn but allow user to proceed
- **Branch creation fails**: Report error but keep plan file
- **File write fails**: Report specific error
