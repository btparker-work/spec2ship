---
description: Start working on an implementation plan. Switches to the plan's branch and marks it as active.
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "TodoWrite", "AskUserQuestion"]
argument-hint: "plan-id"
---

# Start Implementation Plan

Mark a plan as active and switch to its git branch.

## Core Principles

- Use TodoWrite to track progress
- Warn before switching branches with uncommitted changes
- Only one plan can be active at a time

## Arguments

Parse `$ARGUMENTS`:
- First argument: Plan ID (full or partial match)

---

## Phase 1: Validation
**Goal**: Ensure we're in a valid s2s project

**Actions**:
1. Check for s2s project files (config.yaml, workspace.yaml, or component.yaml)
2. If not found: inform user to run `/s2s:proj:init` first

---

## Phase 2: Find Plan
**Goal**: Locate the specified plan file

**Actions**:
1. If exact match exists: `.s2s/plans/{plan-id}.md` → use it
2. If not exact match, search for partial matches in `.s2s/plans/`
3. If multiple matches found: list them and ask user to be specific
4. If no matches found: list available plans and exit

---

## Phase 3: Check Current State
**Goal**: Handle any existing active plan

**Actions**:
1. Read `.s2s/state.yaml` if exists
2. Check `current_plan` value
3. If another plan is active:
   - Warn user: "Plan '{current}' is currently active"
   - Ask: "Switch to '{new-plan}' instead?"
   - If user declines: exit

---

## Phase 4: Pre-flight Checks
**Goal**: Ensure safe to switch branches

**Actions**:
1. Extract branch name from plan file (`**Branch**:` line)
2. If branch exists in git:
   - Check for uncommitted changes
   - If dirty: warn user and ask confirmation
3. If branch doesn't exist but is specified: warn user

---

## Phase 5: Confirmation
**Goal**: Get user approval

**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

Present to user:
- Plan: {plan-id}
- Topic: {topic}
- Branch: {branch}
- Current branch: {current-git-branch}
- Tasks: {completed}/{total}

Ask: "Activate this plan and switch to branch?"

---

## Phase 6: Activate Plan
**Goal**: Update plan status and switch branch

**Actions**:
1. If branch exists: `git checkout {branch}`
2. Update plan file:
   - Change `**Status**: planning` to `**Status**: active`
   - Update `**Updated**:` to current timestamp
3. If previous plan was active:
   - Update its status back to `planning` (unless completed)

---

## Phase 7: Update State
**Goal**: Register active plan in state

**Actions**:
1. Update `.s2s/state.yaml`:
   ```yaml
   current_plan: "{plan-id}"
   ```
2. Update plan entry status to "active"

---

## Output

Present to user:

```
Plan activated!

Plan: {plan-id}
Topic: {topic}
Branch: {branch}
Status: active

Tasks:
- [ ] {task 1}
- [ ] {task 2}
...

Next steps:
- Work through the tasks in the plan
- Mark tasks complete with [x] as you progress
- Run /s2s:plan:complete when finished
```

---

## Error Handling

- **Plan not found**: List available plans
- **Multiple matches**: List matches and ask for specific ID
- **Git checkout fails**: Report error, don't update plan status
- **Uncommitted changes**: Warn but allow user to force switch
- **Branch doesn't exist**: Offer to create it or proceed without
