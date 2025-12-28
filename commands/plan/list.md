---
description: List all implementation plans with their status.
allowed-tools: ["Bash", "Read", "Glob", "Grep"]
argument-hint: [--status planning|active|completed|blocked]
---

# List Implementation Plans

Display all plans in the project with their status and progress.

## Arguments

Parse `$ARGUMENTS`:
- `--status <status>`: Filter by status (planning, active, completed, blocked)
- (no args): Show all plans

---

## Phase 1: Validation
**Goal**: Ensure plans directory exists

**Actions**:
1. Check if `.s2s/plans/` directory exists
2. If not exists: show empty state message and exit

---

## Phase 2: Collect Plan Data
**Goal**: Read all plan files and extract metadata

**Actions**:
For each `.md` file in `.s2s/plans/`:

1. Extract plan ID from filename (without .md extension)
2. Read file and extract:
   - Topic: from `# Implementation Plan: {topic}` line
   - Status: from `**Status**: {status}` line
   - Branch: from `**Branch**: {branch}` line
   - Created: from `**Created**: {date}` line
   - Updated: from `**Updated**: {date}` line
3. Count tasks:
   - Total: lines matching `- [ ]` or `- [x]`
   - Completed: lines matching `- [x]`

---

## Phase 3: Filter (if requested)
**Goal**: Apply status filter if specified

**Actions**:
1. If `$ARGUMENTS` contains `--status`:
   - Extract status value
   - Filter plans to only those matching status
2. Check `.s2s/state.yaml` for `current_plan` to mark active plan

---

## Phase 4: Format Output
**Goal**: Display plans in organized format

**Group by status and display**:

**Active plans** (marked with `*`):
```
* {plan-id}
  Topic: {topic}
  Branch: {branch}
  Progress: {completed}/{total} tasks
  Started: {date}
```

**Planning plans** (marked with `-`):
```
- {plan-id}
  Topic: {topic}
  Tasks: {total} defined
  Created: {date}
```

**Completed plans** (marked with `✓`):
```
✓ {plan-id}
  Topic: {topic}
  Completed: {date}
```

**Blocked plans** (marked with `!`):
```
! {plan-id}
  Topic: {topic}
  Branch: {branch}
```

---

## Output

Present formatted list followed by summary:

```
Implementation Plans
====================

{grouped plan listings}

Total: {count} plans ({active} active, {planning} planning, {completed} completed)
```

---

## Empty State

If no plans exist, show:

```
No implementation plans found.

Create your first plan:
  /s2s:plan:new "feature name"

Or with a git branch:
  /s2s:plan:new "feature name" --branch
```

---

## Error Handling

- **Directory doesn't exist**: Show empty state (not an error)
- **Malformed plan file**: Skip file, warn user about specific file
- **Invalid status filter**: Show valid options
