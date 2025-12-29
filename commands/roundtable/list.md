---
description: List all roundtable sessions with their status and outcomes.
allowed-tools: Bash(ls:*), Read, Glob
argument-hint: [--status active|completed|all]
---

# List Roundtable Sessions

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"

If S2S is initialized:
- Use Glob to find `.s2s/sessions/*.yaml`
- Read `.s2s/state.yaml` to get `current_session` value

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Check for sessions

If no session files found in `.s2s/sessions/`, display:

    No roundtable sessions found.

    Start a new discussion:
      /s2s:roundtable:start "topic"

    Examples:
      /s2s:roundtable:start "API versioning strategy"
      /s2s:roundtable:start "authentication architecture" --participants architect,devops

### Parse arguments

Check $ARGUMENTS for:
- **--status**: Filter by status
  - `active` - only active sessions
  - `completed` - only completed sessions
  - `all` - all sessions (default)

### Read session files

For each session file found:
1. Read the YAML content
2. Extract:
   - **ID**: from `id` field
   - **Topic**: from `topic` field
   - **Status**: from `status` field
   - **Started**: from `started` field
   - **Participants**: from `participants` array
   - **Rounds**: count of items in `rounds` array
   - **Outcome**: from `outcome` field (if completed)

### Format output

Group sessions by status and display:

**Active sessions** (prefix with *):
```
* {session-id}
  Topic: {topic}
  Started: {date}
  Participants: {list}
  Rounds: {count}
```

**Completed sessions** (prefix with ✓):
```
✓ {session-id}
  Topic: {topic}
  Completed: {date}
  Outcome: {brief summary}
  Output: {path to generated document}
```

### Mark current session

If a session ID matches `current_session` from state.yaml, add "(current)" marker.

### Display summary

End with summary line:

    Total: {n} sessions ({active} active, {completed} completed)

    Commands:
      /s2s:roundtable:start "topic"    Start new session
      /s2s:roundtable:resume           Resume current session
      /s2s:roundtable:resume <id>      Resume specific session
