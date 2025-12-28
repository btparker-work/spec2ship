---
description: Create a new implementation plan. Use --branch to also create a git feature branch.
---

# Create New Implementation Plan

Create a new implementation plan file with optional git branch.

## Arguments

- First argument: Topic/title for the plan (required, can be quoted string)
- `--branch`: Also create a git feature branch

## Instructions

1. **Parse arguments**: Extract topic from `$ARGUMENTS`. Check for `--branch` flag.

2. **Validate**: Ensure we're in an s2s project (check for `.s2s/config.yaml`, `.s2s/workspace.yaml`, or `.s2s/component.yaml`)

3. **Generate identifiers**:
   - Timestamp: `YYYYMMDD-HHMMSS` format (use current local time)
   - Slug: lowercase topic with spaces replaced by hyphens, max 50 chars
   - Plan ID: `{timestamp}-{slug}`
   - File path: `.s2s/plans/{plan-id}.md`

4. **Create plans directory** if it doesn't exist: `mkdir -p .s2s/plans`

5. **Create plan file** using this template:

```markdown
# Implementation Plan: {Topic}

**ID**: {plan-id}
**Status**: planning
**Branch**: {branch-name or N/A}
**Created**: {ISO timestamp}
**Updated**: {ISO timestamp}

## References

### Requirements
<!-- Link to relevant requirements -->

### Architecture
<!-- Link to relevant architecture sections -->

### Decisions
<!-- Link to relevant ADRs -->

## Design Notes

<!-- Component-specific technical decisions -->

## Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Notes

<!-- Progress notes, blockers, etc. -->
```

6. **If --branch flag**:
   - Check git status is clean (warn if dirty)
   - Count existing feature branches to get next number
   - Create branch: `feature/F{NN}-{slug}`
   - Update plan file with branch name

7. **Output** confirmation with:
   - File path created
   - Plan ID
   - Branch name (if created)
   - Next steps hint
