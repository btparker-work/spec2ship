---
name: Roundtable Execution
description: "This skill provides instructions for executing multi-agent roundtable discussions.
  Use when a command needs to run discussion rounds with facilitator and participants.
  Referenced by: specs.md, design.md, brainstorm.md.
  Trigger: 'execute roundtable', 'run discussion rounds', 'multi-agent discussion'."
version: 2.0.0
---

# Roundtable Execution Instructions

This skill provides step-by-step instructions for executing a multi-agent roundtable discussion with file-based artifact management.

## When to Use This Skill

- Executing `/s2s:specs` requirements gathering
- Executing `/s2s:design` architecture design
- Executing `/s2s:brainstorm` ideation sessions

## Key Architecture

- **Session file**: `.s2s/sessions/{session-id}.yaml` - Slim index
- **Session folder**: `.s2s/sessions/{session-id}/` - Artifacts and dumps
- **Artifacts**: Individual YAML files per requirement/conflict/etc.
- **Verbose dumps**: `rounds/` subfolder with per-actor dump files

---

## PHASE 1: Session Setup

### Step 1.1: Generate Session ID

```
{YYYYMMDD}-{workflow_type}-{project-slug}
Example: 20260107-requirements-elfgiftrush
```

### Step 1.2: Create Session Folder Structure

```bash
mkdir -p .s2s/sessions/{session-id}
mkdir -p .s2s/sessions/{session-id}/rounds  # Only if --verbose
```

### Step 1.3: Create Snapshot Files

**context-snapshot.yaml**: Read `.s2s/CONTEXT.md` and write YAML snapshot:
```yaml
# Captured: {ISO timestamp}
source: ".s2s/CONTEXT.md"

project_name: "{from CONTEXT.md}"
description: "{from CONTEXT.md}"
objectives: [...]
constraints: [...]
scope:
  in: [...]
  out: [...]
```

**config-snapshot.yaml**: Read `.s2s/config.yaml` and write relevant config:
```yaml
# Captured: {ISO timestamp}
source: ".s2s/config.yaml"

verbose: {verbose_flag}
interactive: {interactive_flag}
strategy: "{strategy}"
limits:
  min_rounds: 3
  max_rounds: 20
escalation:
  max_rounds_per_conflict: 3
  confidence_below: 0.5
  critical_keywords: ["security", "must-have", "blocking", "legal"]
participants: [...]
```

**agenda.yaml**: Copy workflow agenda from `references/agenda-{workflow_type}.md`:
```yaml
# Captured: {ISO timestamp}
source: "skills/roundtable-execution/references/agenda-{workflow_type}.md"
workflow: "{workflow_type}"
topics: [...]  # Full topic definitions with done_when criteria
```

### Step 1.4: Create Session Index File

Write `.s2s/sessions/{session-id}.yaml`:
```yaml
id: "{session-id}"
topic: "{topic}"
workflow_type: "{workflow_type}"
strategy: "{strategy}"
status: "active"

timing:
  started: "{ISO timestamp}"
  completed: null
  duration_ms: null

artifacts:
  requirements: []
  business_rules: []
  conflicts: []
  open_questions: []
  exclusions: []

agenda: []  # Will be populated from agenda.yaml

rounds: []

metrics:
  rounds: 0
  tasks: 0
  tokens: 0
```

### Step 1.5: Update State File

Edit `.s2s/state.yaml`:
```yaml
current_session: "{session-id}"
```

---

## PHASE 2: Round Execution Loop

### Loop Variables

```
round_number = 0
session_folder = ".s2s/sessions/{session-id}/"
```

### Step 2.1: Display Round Start

```
═══════════════════════════════════════════════════════════════
ROUNDTABLE: {topic}
Strategy: {strategy} | Round: {round_number + 1}
═══════════════════════════════════════════════════════════════

AGENDA STATUS:
{for each topic in agenda}
[{status}] {topic_name} {(CRITICAL) if critical}
{/for}

ARTIFACTS: {count} requirements, {count} conflicts, {count} open questions
```

### Step 2.2: Facilitator Question

**YOU MUST use Task tool** to call facilitator:

```yaml
subagent_type: "general-purpose"
prompt: |
  You are the Roundtable Facilitator.
  Read your agent definition from: agents/roundtable/facilitator.md

  === SESSION STATE ===
  Round: {round_number + 1}
  Session folder: {session_folder}

  === ARTIFACT SUMMARY ===
  Requirements: {list IDs with title, status}
  Conflicts: {list IDs with title, status}
  Open questions: {list IDs with title, status}

  (Read artifact files only if you need full details)

  === AGENDA STATUS ===
  {for each topic}
  [{status}] {topic_id} - DoD: {criteria summary}
  {/for}

  === PREVIOUS ROUND ===
  {synthesis from last round or "First round"}

  === ESCALATION CONFIG ===
  max_rounds_per_conflict: 3
  confidence_below: 0.5
  min_rounds: 3

  === YOUR TASK ===
  1. DECIDE focus for this round (agenda/conflict/open_question)
  2. SELECT context files for participants
  3. GENERATE question + exploration prompt
```

**Parse response**: Extract `decision`, `context_files`, `question`, `exploration`, `participants`

**IF --verbose**: Write dump file `rounds/{NNN}-01-facilitator-question.yaml`

### Step 2.3: Participant Responses (PARALLEL)

**YOU MUST launch ALL participant Tasks in SINGLE message** for blind voting.

For EACH participant:

```yaml
subagent_type: "general-purpose"
prompt: |
  You are the {Participant Role} in a roundtable discussion.
  Read your agent definition from: agents/roundtable/{participant-id}.md

  === CONTEXT FILES ===
  Read these files (DO NOT read other session files):
  {for each file in context_files}
  - {session_folder}/{file}
  {/for}

  === QUESTION ===
  {facilitator's question}

  === EXPLORATION ===
  {facilitator's exploration prompt}

  === YOUR RESPONSE FORMAT ===
  Return YAML:
  position: "{your position}"
  rationale:
    - "{reason 1}"
    - "{reason 2}"
  confidence: 0.85
  concerns:
    - "{concern}"
  suggestions:
    - "{new idea or question}"
```

**Store responses** in `participant_responses[]`

**IF --verbose**: Write dump files `rounds/{NNN}-02-{participant-id}.yaml` for each

### Step 2.4: Facilitator Synthesis

**YOU MUST use Task tool** for synthesis:

```yaml
subagent_type: "general-purpose"
prompt: |
  You are the Roundtable Facilitator.
  Read your agent definition from: agents/roundtable/facilitator.md

  === ROUND {round_number + 1} RESPONSES ===
  {for each participant}
  **{Participant Role}** (confidence: {confidence}):
  Position: {position}
  Rationale: {rationale}
  Concerns: {concerns}
  Suggestions: {suggestions}
  {/for}

  === ARTIFACT SUMMARY ===
  {same as in question phase}

  === AGENDA STATUS ===
  {same as in question phase}

  === ESCALATION CONFIG ===
  max_rounds_per_conflict: 3
  confidence_below: 0.5
  min_rounds: 3

  === YOUR TASK ===
  1. SYNTHESIZE responses
  2. PROPOSE new artifacts (without IDs)
  3. UPDATE agenda status
  4. DECIDE next action
```

**Parse response**: Extract `synthesis`, `proposed_artifacts`, `resolved_conflicts`, `agenda_update`, `next`, `next_focus`

**IF --verbose**: Write dump file `rounds/{NNN}-03-facilitator-synthesis.yaml`

### Step 2.5: Process Artifacts

For each `proposed_artifact`:

1. **Determine ID**: Read current registry, assign next available ID
   - Requirements: `REQ-{NNN}`
   - Conflicts: `CONF-{NNN}`
   - Open questions: `OQ-{NNN}`
   - Etc.

2. **Write artifact file**: `{session_folder}/{ID}.yaml`

3. **Update registry** in session file

For each `resolved_conflict`:

1. **Update conflict file**: Add `resolved_round` and `resolution`
2. **Update registry** if needed

### Step 2.6: Update Session File

Append round to `rounds[]`:
```yaml
- number: {round_number + 1}
  focus:
    type: "{focus_type}"
    topic_id: "{topic_id}"
  created: ["{new artifact IDs}"]
  resolved: ["{resolved conflict IDs}"]
  next: "{next action}"
```

Update `agenda[]` status based on `agenda_update`.

Update `metrics`.

### Step 2.7: Display Round Recap

```
───────────────────────────────────────────────────────────────
ROUND {round_number + 1} COMPLETE
───────────────────────────────────────────────────────────────

Focus: {focus_type} - {topic_id}

Synthesis:
{facilitator's synthesis}

New Artifacts:
{for each created}
  + {ID}: {title}
{/for}

{if resolved_conflicts}
Resolved:
{for each resolved}
  ✓ {conflict_id}: {resolution}
{/for}

Agenda:
{for each topic}
  [{status}] {topic_name}
{/for}

Next: {next_focus or "Conclusion pending"}
───────────────────────────────────────────────────────────────
```

### Step 2.8: Handle Interactive Mode

**IF interactive_flag == true**:
- Use AskUserQuestion:
  - "Continue to next round"
  - "Skip to conclusion"
  - "Pause session"

**IF interactive_flag == false**:
- Proceed automatically

### Step 2.9: Evaluate Next Action

**Check min_rounds override**:
- If `round_number < min_rounds` AND `next == "conclude"`:
- Override to `next = "continue"`

**Based on `next`**:

| Action | Behavior |
|--------|----------|
| continue | Increment round_number, REPEAT from Step 2.1 |
| conclude | EXIT loop, proceed to PHASE 3 |
| escalate | Handle escalation (see below) |

### Step 2.10: Handle Escalation

If `next == "escalate"`:

1. Display escalation reason
2. Use AskUserQuestion:
   - "Accept facilitator recommendation"
   - "Provide your own decision"
   - "Continue discussion"
3. Record user decision
4. Continue or conclude based on choice

### Step 2.11: Safety Limits

**HARD LIMIT**: If `round_number >= max_rounds`:
- Force conclude
- Note in session: "Reached maximum rounds limit"

---

## PHASE 3: Completion

### Step 3.1: Update Session Status

```yaml
status: "completed"
timing:
  completed: "{ISO timestamp}"
  duration_ms: {calculated}
```

### Step 3.2: Clear State

Set `current_session: null` in `.s2s/state.yaml`.

### Step 3.3: Read Session for Summary

**YOU MUST Read session file** to generate summary from Single Source of Truth.

Extract:
- All consensus artifacts
- Unresolved conflicts
- Agenda final status

### Step 3.4: Generate Output

Based on workflow_type, generate appropriate output document:
- **specs**: `docs/specifications/requirements.md`
- **design**: `docs/architecture/` files + ADRs
- **brainstorm**: `.s2s/sessions/{session-id}-summary.md`

### Step 3.5: Display Completion

```
═══════════════════════════════════════════════════════════════
ROUNDTABLE COMPLETE
═══════════════════════════════════════════════════════════════

Session: {session-id}
Rounds: {total_rounds}
Duration: {duration}

Artifacts Created:
  Requirements: {count}
  Business Rules: {count}
  Conflicts Resolved: {count}
  Open Questions: {count}

Output: {output file path}

Next steps:
  /s2s:design   - Design architecture (if specs)
  /s2s:plan     - Generate implementation plans
═══════════════════════════════════════════════════════════════
```

---

## Verbose Dump File Format

When `--verbose` flag is set, write dump files to `rounds/` subfolder.

### Naming Convention

```
{NNN}-{PP}-{actor}.yaml

NNN = 3-digit round number (001, 002, ...)
PP = 2-digit phase (01=question, 02=responses, 03=synthesis)
actor = facilitator, product-manager, etc.
```

### Dump File Content

```yaml
round: {N}
phase: {P}
actor: "{actor-id}"

timing:
  started: "{ISO timestamp}"
  completed: "{ISO timestamp}"
  duration_ms: {calculated}

tokens:
  input: {estimated}
  output: {estimated}

prompt: |
  {exact prompt sent}

response: |
  {exact response received}

result:
  valid: true
  warnings: []
  artifacts_created: [...]  # Only in synthesis
```

---

## Definition of Done Checklist

### After Step 2.2 (Facilitator Question):
- [ ] Task tool was used
- [ ] Facilitator returned valid YAML with `action: "question"`
- [ ] Decision includes focus_type and topic_id
- [ ] Context files list is present
- [ ] Dump file written (if verbose)

### After Step 2.3 (Participant Responses):
- [ ] ALL participants launched in SINGLE message
- [ ] ALL participants returned valid YAML
- [ ] Each response has position, rationale, confidence
- [ ] Dump files written (if verbose)

### After Step 2.4 (Facilitator Synthesis):
- [ ] Task tool was used
- [ ] Synthesis identifies proposed_artifacts
- [ ] next is one of: continue, conclude, escalate
- [ ] Dump file written (if verbose)

### After Step 2.5 (Process Artifacts):
- [ ] New artifact files written
- [ ] Session file updated with new IDs
- [ ] Resolved conflicts updated

---

## Reference Files

- `references/session-schema.md` - Full YAML schema
- `references/agenda-specs.md` - Specs workflow agenda with DoD
- `references/agenda-design.md` - Design workflow agenda with DoD

---

*Referenced by: specs.md, design.md, brainstorm.md*
