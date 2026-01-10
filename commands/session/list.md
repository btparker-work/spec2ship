---
description: List all roundtable sessions with their status, workflow type, and progress.
allowed-tools: Bash(pwd:*), Bash(ls:*), Read, Glob
argument-hint: [--status active|completed|paused|failed] [--workflow specs|design|brainstorm]
---

# List Sessions

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears → "yes", otherwise → "NOT_S2S"

If S2S is initialized:
- Read `.s2s/state.yaml` to get `current_session` value
- Use Glob to find all `.s2s/sessions/*.yaml` files

---

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S":

    Error: Not an s2s project. Run /s2s:init first.

### Parse arguments

Extract from $ARGUMENTS:
- **--status**: Filter by session status (active|completed|paused|failed)
- **--workflow**: Filter by workflow type (specs|design|brainstorm)

### Find sessions

Use Glob tool to find all session files:
```
.s2s/sessions/*.yaml
```

**IF** no session files found:

    No sessions found.

    Start a new session:
      /s2s:specs      - Requirements roundtable
      /s2s:design     - Design roundtable
      /s2s:brainstorm - Brainstorm session

### Read session files

For each session file found:

1. **YOU MUST use Read tool** to read the session file
2. Extract:
   - `id`
   - `workflow_type`
   - `strategy`
   - `status`
   - `timing.started`
   - `timing.completed`
   - `metrics.rounds_completed`
   - `metrics.artifacts.total`

### Apply filters

**IF** --status provided:
- Only include sessions where `status` matches

**IF** --workflow provided:
- Only include sessions where `workflow_type` matches

### Format output

Group sessions by status:

    Sessions
    ═══════════════════════════════════════

    Active ({count})
    ─────────────────────────────────────
    {for each session where status == "active"}
    * {id}
      Workflow: {workflow_type} | Strategy: {strategy}
      Started: {timing.started}
      Progress: {metrics.rounds_completed} rounds, {metrics.artifacts.total} artifacts
    {/for}

    Completed ({count})
    ─────────────────────────────────────
    {for each session where status == "completed"}
    ✓ {id}
      Workflow: {workflow_type} | Strategy: {strategy}
      Duration: {calculated}
      Result: {metrics.artifacts.total} artifacts
    {/for}

    Paused ({count})
    ─────────────────────────────────────
    {for each session where status == "paused"}
    ⏸ {id}
      Workflow: {workflow_type}
      Paused at: {timing.last_activity}
    {/for}

    Failed ({count})
    ─────────────────────────────────────
    {for each session where status == "failed"}
    ✗ {id}
      Workflow: {workflow_type}
      Failed at: {timing.last_activity}
    {/for}

    ─────────────────────────────────────
    Total: {total count} sessions

### Mark current session

If `current_session` from state.yaml matches a session ID, mark it with `→`:

    → * {id}  (current)

---

## Status Icons

| Status | Icon |
|--------|------|
| active | * |
| completed | ✓ |
| paused | ⏸ |
| failed | ✗ |
| abandoned | ∅ |
