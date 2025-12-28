---
description: Mark the current implementation plan as completed.
---

# Complete Implementation Plan

Mark the active plan as completed.

## Arguments

- `--merge`: Also merge the feature branch to main/develop
- `--no-delete-branch`: Keep the branch after completion

## Instructions

1. **Find active plan**:
   - Read `.s2s/state.yaml` to get `current_plan`
   - If no active plan, inform user and exit

2. **Check tasks**:
   - Count incomplete tasks (lines with `- [ ]`)
   - If incomplete tasks exist, warn user and ask confirmation

3. **Update plan file**:
   - Change `**Status**: active` to `**Status**: completed`
   - Update `**Updated**:` timestamp

4. **Update state**:
   - Set `current_plan: null` in `.s2s/state.yaml`

5. **Handle branch** (if `--merge` flag):
   - Check for uncommitted changes
   - Get default branch (main or develop)
   - Merge feature branch
   - Delete branch (unless `--no-delete-branch`)

6. **Output**:
   - Confirm plan completed
   - Show task summary
   - Show merge result if applicable
