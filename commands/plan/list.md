---
description: List all implementation plans with their status
---

# List Implementation Plans

List all plans in `.s2s/plans/` directory with their status, topic, and progress.

## Instructions

1. Check if `.s2s/plans/` directory exists. If not, inform user to create first plan with `/s2s:plan:new`

2. For each `.md` file in `.s2s/plans/`:
   - Extract plan ID from filename (without .md extension)
   - Read the file and extract:
     - Topic from `# Implementation Plan: {topic}` line
     - Status from `**Status**: {status}` line
     - Branch from `**Branch**: {branch}` line
     - Count total tasks (lines starting with `- [ ]` or `- [x]`)
     - Count completed tasks (lines starting with `- [x]`)

3. If `$ARGUMENTS` contains `--status`, filter plans by that status

4. Display plans grouped by status:

**Active plans** (marked with `*`):
```
* {plan-id}
  Topic: {topic}
  Branch: {branch}
  Progress: {done}/{total} tasks
```

**Planning plans** (marked with `-`):
```
- {plan-id}
  Topic: {topic}
  Tasks: {total} defined
```

**Completed plans** (marked with `✓`):
```
✓ {plan-id}
  Topic: {topic}
  Completed: {date}
```

5. Show total count at the end

## Empty State

If no plans exist, show:
```
No implementation plans found.

Create your first plan:
  /s2s:plan:new "feature name"
```
