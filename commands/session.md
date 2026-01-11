---
description: Show current roundtable session status. Use subcommands for more options.
allowed-tools: Bash(pwd:*), Bash(ls:*), Read, Glob
argument-hint: (no arguments - shows current session)
---

# Session Status

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears → "yes", otherwise → "NOT_S2S"

If S2S is initialized:
- Read `.s2s/state.yaml` to get `current_session` value
- If `current_session` is set, read the session file

---

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S":

    Error: Not an s2s project. Run /s2s:init first.

### Check for current session

Read `.s2s/state.yaml` and extract `current_session` field.

**IF** `current_session` is null or empty:

    No active session.

    Recent sessions:
    {list last 3 sessions from .s2s/sessions/*.yaml}

    Commands:
      /s2s:session:list      - List all sessions
      /s2s:specs             - Start requirements roundtable
      /s2s:design            - Start design roundtable
      /s2s:brainstorm        - Start brainstorm session

### Display current session

**YOU MUST use Read tool** to read `.s2s/sessions/{current_session}.yaml`.

Display session summary:

    Current Session
    ═══════════════════════════════════════

    ID:       {id}
    Workflow: {workflow_type}
    Strategy: {strategy}
    Status:   {status}

    Started:  {timing.started}
    Duration: {calculated from timing}

    Progress
    ─────────────────────────────────────
    Rounds:   {metrics.rounds_completed}
    Artifacts: {metrics.artifacts.total}
      - Requirements: {metrics.artifacts.by_type.requirements}
      - Business Rules: {metrics.artifacts.by_type.business_rules}
      - NFR: {metrics.artifacts.by_type.nfr}
      - Open Questions: {metrics.artifacts.by_type.open_questions}
      - Conflicts: {metrics.artifacts.by_type.conflicts}

    Topics
    ─────────────────────────────────────
    {for each topic in agenda}
    [{status icon}] {topic_id}
    {/for}

    Status icons: ○ open | ◐ partial | ● closed

    Commands
    ─────────────────────────────────────
      /s2s:session:status    - Detailed view
      /s2s:session:validate  - Check consistency
      /s2s:roundtable:resume - Continue discussion

---

## Status Icons

| Status | Icon |
|--------|------|
| open | ○ |
| partial | ◐ |
| closed | ● |
