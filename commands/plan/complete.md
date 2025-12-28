---
description: Mark the current implementation plan as completed. Optionally merge the branch.
allowed-tools: Bash(git:*), Bash(cat:*), Read, Write, Edit, TodoWrite, AskUserQuestion
argument-hint: [--merge] [--no-delete-branch]
---

# Complete Implementation Plan

## Context

- State file: !`cat .s2s/state.yaml`
- Git status: !`git status --porcelain`
- Current branch: !`git branch --show-current`
- Remote HEAD: !`git symbolic-ref refs/remotes/origin/HEAD`

## Interpret Context

Based on the context output above, determine:

- **Current plan**: Extract the `current_plan:` value from the State file content (or "none" if not set/null)
- **Git status clean**: If Git status output is empty → "clean", otherwise → "dirty"
- **Default branch**: Extract branch name from Remote HEAD (remove "refs/remotes/origin/" prefix), default to "main" if error

## Instructions

### Check for active plan

If current plan is "none", display this message and stop:

    No active plan found.

    Use /s2s:plan:list to see available plans.
    Use /s2s:plan:start "plan-id" to activate a plan.

### Read plan file

Read .s2s/plans/{current-plan}.md and extract:
- Topic from "# Implementation Plan: " line
- Branch from "**Branch**: " line
- Created date from "**Created**: " line
- Tasks: count lines with "- [ ]" (incomplete) and "- [x]" (complete)

### Check task completion

If there are incomplete tasks:
- List them to the user
- Ask: "Complete plan with {n} incomplete tasks?" using AskUserQuestion
- If user declines, stop

### Parse arguments

Check $ARGUMENTS for:
- **--merge**: Merge feature branch to default branch
- **--no-delete-branch**: Keep branch after merge (only with --merge)

### Confirm completion

Present summary and ask for confirmation:
- Plan ID and topic
- Task completion status
- Branch operation (merge/keep/none)

### Git operations (if --merge)

If --merge flag is present:

1. If git status is "dirty":
   - Warn user and ask them to commit first
   - Stop if they don't want to commit

2. Checkout default branch: git checkout {default-branch}

3. Pull latest: git pull origin {default-branch}

4. Merge feature branch: git merge {branch}
   - If merge conflict, report and stop (user must resolve manually)

5. If --no-delete-branch NOT present:
   - Delete the feature branch: git branch -d {branch}

### Update plan file

Edit .s2s/plans/{current-plan}.md:
- Change "**Status**: active" to "**Status**: completed"
- Update "**Updated**:" to current ISO timestamp
- Add "**Completed**: {current ISO timestamp}" after Updated line

### Update state

Update .s2s/state.yaml:
- Set current_plan to null
- Update the plan entry status to "completed"

### Output

Display confirmation:

    Plan completed!

    Plan: {plan-id}
    Topic: {topic}
    Tasks: {completed}/{total} completed
    Duration: {days since created} days

    {if --merge}
    Branch merged: {branch} → {default-branch}
    Branch deleted: {yes/no}
    {end if}

    Next steps:
    - View completed plans: /s2s:plan:list --status completed
    - Create new plan: /s2s:plan:new "next feature"
