---
description: Mark the current implementation plan as completed. Optionally merge the branch.
allowed-tools: ["Bash", "Read", "Write", "Edit", "TodoWrite", "AskUserQuestion"]
argument-hint: [--merge] [--no-delete-branch]
---

# Complete Implementation Plan

Mark the active plan as completed with optional branch operations.

## Core Principles

- Use TodoWrite to track completion steps
- Warn about incomplete tasks before completing
- Require explicit confirmation for git operations

## Arguments

Parse `$ARGUMENTS`:
- `--merge`: Also merge the feature branch to default branch
- `--no-delete-branch`: Keep the branch after completion (only with --merge)

---

## Phase 1: Find Active Plan
**Goal**: Identify the current active plan

**Actions**:
1. Read `.s2s/state.yaml`
2. Get `current_plan` value
3. If no active plan: inform user and exit
4. Load plan file from `.s2s/plans/{current_plan}.md`

---

## Phase 2: Task Check
**Goal**: Verify task completion status

**Actions**:
1. Count tasks in plan file:
   - Total: lines matching `- [ ]` or `- [x]`
   - Incomplete: lines matching `- [ ]`
2. If incomplete tasks exist:
   - List incomplete tasks
   - Ask: "Complete plan with {n} incomplete tasks?"
   - If user declines: exit

---

## Phase 3: Confirmation
**Goal**: Get user approval for completion

**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

Present to user:
- Plan: {plan-id}
- Topic: {topic}
- Tasks: {completed}/{total} completed
- Branch: {branch}
- Merge requested: {yes/no}

Ask: "Mark this plan as completed?"

---

## Phase 4: Git Operations (if --merge)
**Goal**: Merge feature branch to default branch

**Pre-conditions**:
- Check for uncommitted changes
- If dirty: warn and ask to commit first

**Actions**:
1. Get default branch (main or develop, check git config)
2. Checkout default branch
3. Pull latest changes
4. Merge feature branch: `git merge {branch}`
5. If merge conflicts: report and exit (user must resolve)
6. If `--no-delete-branch` NOT present: delete feature branch

---

## Phase 5: Update Plan
**Goal**: Mark plan as completed

**Actions**:
1. Update plan file:
   - Change `**Status**: active` to `**Status**: completed`
   - Update `**Updated**:` to current timestamp
   - Add `**Completed**:` with current timestamp

---

## Phase 6: Update State
**Goal**: Clear active plan from state

**Actions**:
1. Update `.s2s/state.yaml`:
   ```yaml
   current_plan: null
   ```
2. Update plan entry:
   ```yaml
   plans:
     "{plan-id}":
       status: "completed"
       completed: "{ISO timestamp}"
   ```

---

## Output

Present to user:

```
Plan completed!

Plan: {plan-id}
Topic: {topic}
Tasks: {completed}/{total} completed
Duration: {days since created}

{if --merge}
Branch merged: {branch} → {default-branch}
Branch deleted: {yes/no}
{/if}

Next steps:
- View completed plans: /s2s:plan:list --status completed
- Create new plan: /s2s:plan:new "next feature"
```

---

## Error Handling

- **No active plan**: Inform user, suggest `/s2s:plan:list`
- **Uncommitted changes** (with --merge): Ask user to commit first
- **Merge conflicts**: Report conflict, exit without completing plan
- **Branch delete fails**: Warn but complete the plan anyway
- **Not on feature branch** (with --merge): Warn and ask confirmation
