---
description: Start a roundtable discussion with AI expert participants. Use for technical decisions, architecture reviews, or requirements refinement.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(mkdir:*), Bash(date:*), Read, Write, Edit, Glob, Task, AskUserQuestion, TodoWrite
argument-hint: "topic" [--participants architect,tech-lead,qa] [--output adr|plan|summary]
---

# Start Roundtable Discussion

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`
- Current timestamp: !`date +"%Y%m%d-%H%M%S"`
- ISO timestamp: !`date -u +"%Y-%m-%dT%H:%M:%SZ"`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"

If S2S is initialized, use Read tool to:
- Check if `.s2s/sessions/` directory exists
- Read `.s2s/CONTEXT.md` for project context (if exists)
- Read `.s2s/state.yaml` to check for active session

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Parse arguments

Extract from $ARGUMENTS:
- **Topic**: The discussion topic (required) - first quoted string or unquoted words
- **--participants**: Comma-separated list of participants (optional)
  - Default: "architect,tech-lead,qa"
  - Available: architect, tech-lead, qa, devops, product-manager
- **--output**: Expected output type (optional)
  - Default: "adr" for technical decisions, "plan" for implementation discussions
  - Options: adr, plan, summary

If no topic is provided, ask the user using AskUserQuestion.

### Check for active session

Read `.s2s/state.yaml` and check `current_session` value.

If there is an active session:
- Warn user: "A roundtable session is already active: {session-id}"
- Ask using AskUserQuestion: "Start new session or resume existing?"
  - Options: "Start new (archive current)" / "Resume existing session"
- If resume, redirect to `/s2s:roundtable:resume`

### Prepare session

1. Create sessions directory if not exists: `mkdir -p .s2s/sessions`

2. Generate session ID: `{timestamp}-{topic-slug}`
   - Slug: lowercase, spaces to hyphens, max 30 chars

3. Determine participants based on topic and --participants flag:
   - Technical/architecture topics → architect, tech-lead
   - Quality/testing topics → qa, tech-lead
   - Infrastructure topics → devops, architect
   - Requirements topics → product-manager, architect
   - Default → architect, tech-lead, qa

### Load context

Gather relevant context for the discussion:

1. Read `.s2s/CONTEXT.md` if exists (project context)
2. Search for related files based on topic:
   - Architecture topic → read `docs/architecture/*.md`
   - API topic → read `docs/specifications/api/*.md`
   - Requirements topic → read `docs/specifications/requirements.md`
3. Check for related ADRs in `docs/decisions/`

### Create session file

Write `.s2s/sessions/{session-id}.yaml`:

```yaml
id: "{session-id}"
topic: "{topic}"
type: "{inferred type: technical|requirements|architecture|infrastructure}"
started: "{ISO timestamp}"
status: "active"
participants:
  - "{participant-1}"
  - "{participant-2}"
  - "{participant-3}"
expected_output: "{adr|plan|summary}"
context:
  project: ".s2s/CONTEXT.md"
  related_files:
    - "{file1}"
    - "{file2}"
rounds: []
consensus: []
conflicts: []
outcome: null
```

### Update state

Update `.s2s/state.yaml` to set `current_session` to the new session ID.

### Launch facilitator

Display session start message:

    Roundtable session started!

    Session: {session-id}
    Topic: {topic}
    Participants: {participant list}
    Expected output: {adr|plan|summary}

    Launching facilitator...

Launch the roundtable facilitator agent using Task tool:

```
Task(
  subagent_type="general-purpose",
  prompt="You are the Roundtable Facilitator.

Topic: {topic}

Participants: {participant list}

Project Context:
{context from CONTEXT.md}

Related Files:
{list of related files and their key points}

Session ID: {session-id}

Your task:
1. Frame the discussion - clarify scope and expected outcome
2. Launch each participant agent to get their perspective on the topic
3. Synthesize positions, identify consensus and conflicts
4. If conflicts exist, present options to the user for resolution
5. Generate the expected output ({adr|plan|summary})
6. Update the session file with outcome

Use the roundtable agents:
- roundtable-software-architect for architecture perspective
- roundtable-technical-lead for implementation perspective
- roundtable-qa-lead for quality perspective
- roundtable-devops-engineer for infrastructure perspective
- roundtable-product-manager for business perspective

At the end, save the outcome to the session file and generate appropriate output document."
)
```

### Handle completion

When facilitator completes:

1. Read the session file to get outcome
2. Display summary:

    Roundtable complete!

    Session: {session-id}
    Topic: {topic}
    Rounds: {number of rounds}

    Outcome:
    {summary of decision/consensus}

    Output saved to:
    {path to generated ADR/plan/summary}

    Next steps:
    {suggested actions based on outcome}

3. Update session status to "completed"
4. Clear `current_session` in state.yaml
