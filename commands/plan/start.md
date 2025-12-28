---
description: Start working on an implementation plan. Switches to the plan's branch and marks it as active.
---

# Start Implementation Plan

Mark a plan as active and switch to its git branch.

## Arguments

- First argument: Plan ID (timestamp-slug format or partial match)

## Instructions

1. **Validate**: Ensure we're in an s2s project

2. **Find plan file**:
   - Look for exact match: `.s2s/plans/{plan-id}.md`
   - If not found, try partial match in `.s2s/plans/`
   - If multiple matches, list them and ask user to be specific
   - If no matches, list available plans

3. **Check current state**:
   - Read `.s2s/state.yaml` if exists
   - If another plan is active, warn user and ask confirmation

4. **Extract branch** from plan file (`**Branch**:` line)

5. **Switch branch** (if branch exists):
   - Check for uncommitted changes first
   - If dirty, warn and stop
   - Run `git checkout {branch}`

6. **Update plan file**:
   - Change `**Status**: planning` to `**Status**: active`
   - Update `**Updated**:` timestamp

7. **Update state** in `.s2s/state.yaml`:
   ```yaml
   current_plan: "{plan-id}"
   ```

8. **Output**:
   - Confirm plan activated
   - Show current branch
   - List tasks from plan
