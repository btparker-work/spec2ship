---
description: Resume a roundtable session. Continues from where the discussion left off.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(date:*), Read, Write, Edit, Glob, Task, AskUserQuestion, TodoWrite
argument-hint: [session-id]
---

# Resume Roundtable Session

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`
- Current timestamp: !`date -u +"%Y-%m-%dT%H:%M:%SZ"`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"

If S2S is initialized:
- Read `.s2s/state.yaml` to get `current_session` value
- Use Glob to list `.s2s/sessions/*.yaml`

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Determine which session to resume

Check $ARGUMENTS for session ID.

**If session ID provided**:
- Search for matching session file in `.s2s/sessions/`
- If exact match found, use it
- If partial match, confirm with user
- If no match, show available sessions and stop

**If no session ID provided**:
- If `current_session` exists in state.yaml, use it
- If no current session, show available sessions:

    No active session found.

    Available sessions:
    {list of sessions with IDs}

    Resume a specific session:
      /s2s:roundtable:resume <session-id>

    Or start a new discussion:
      /s2s:roundtable:start "topic"

### Load session state

Read the session file `.s2s/sessions/{session-id}.yaml` and extract:
- Topic
- Participants
- Status
- Rounds completed
- Current consensus points
- Current conflicts
- Expected output type

### Validate session can be resumed

If session status is "completed":

    Session {session-id} is already completed.

    Outcome: {outcome summary}
    Output: {path to generated document}

    To start a new discussion on related topic:
      /s2s:roundtable:start "new topic"

    To fork this session (start from its conclusions):
      /s2s:roundtable:start "topic" --from {session-id}

### Display session context

Show current state:

    Resuming roundtable session...

    Session: {session-id}
    Topic: {topic}
    Status: {status}
    Participants: {list}

    Progress:
    - Rounds completed: {n}
    - Consensus points: {count}
    - Open conflicts: {count}

    {If conflicts exist}
    Current conflicts:
    1. {conflict 1 summary}
    2. {conflict 2 summary}

### Update session

Update the session file:
- Set `status` to "active"
- Add resume timestamp to metadata

Update `.s2s/state.yaml`:
- Set `current_session` to this session ID

### Launch facilitator with context

Launch the facilitator with full session context:

```
Task(
  subagent_type="general-purpose",
  prompt="You are the Roundtable Facilitator resuming a session.

Session ID: {session-id}
Topic: {topic}

Previous Progress:
- Rounds completed: {n}
- Consensus reached:
{list of consensus points}

- Open conflicts:
{list of conflicts with positions}

Participants: {list}
Expected output: {adr|plan|summary}

Your task:
1. Briefly summarize where we left off
2. Continue the discussion from the last round
3. Focus on resolving open conflicts
4. Drive toward consensus
5. Generate the expected output when ready

Use the roundtable agents to continue gathering perspectives as needed."
)
```

### Handle completion

Same as `/s2s:roundtable:start` - update session file, generate output, display summary.
