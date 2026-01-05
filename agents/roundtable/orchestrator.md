---
name: roundtable-orchestration-guide
description: "Reference documentation for roundtable orchestration logic.
  NOT an executable agent. The orchestration is implemented inline in commands/roundtable/start.md.
  This file serves as documentation and implementation guide."
---

# Roundtable Orchestration Guide

> **IMPORTANT**: This is NOT an executable agent. The orchestration logic is implemented
> inline in `commands/roundtable/start.md`. This file documents the orchestration patterns
> for reference and maintenance purposes.

## Why Inline Orchestration?

Claude Code has a fundamental limitation: **subagents cannot spawn other subagents**.

The previous architecture (v3) attempted:
```
start.md → Task(orchestrator) → Task(facilitator) + Task(participants)
```

This **does not work** because the orchestrator, being a subagent launched by start.md,
cannot call Task() to launch facilitator and participants.

The solution is to inline the orchestration logic directly in start.md, which runs
in the main agent context and CAN call Task() multiple times.

## Orchestration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Command (start.md) - ORCHESTRATOR INLINE                       │
│                                                                 │
│  For each round until conclusion:                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ 1. Read session state                                       ││
│  │ 2. Task(facilitator) → generate question                    ││
│  │ 3. Task(participant1), Task(participant2)... (PARALLEL)     ││
│  │ 4. Task(facilitator) → synthesize responses                 ││
│  │ 5. Batch write to session file                              ││
│  │ 6. Evaluate next_action                                     ││
│  │    continue → loop | phase → advance | conclude → exit      ││
│  │    escalate → ask user → continue or conclude               ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Agent Lifecycle

Every Task() call creates a **stateless** agent:
- Agent is created
- Agent executes with provided prompt
- Agent returns result
- Agent terminates

There is **no persistent state** between Task() calls. The command must:
1. Read session file to get current state
2. Build appropriate prompts with necessary context
3. Parse agent responses
4. Update session file

## Context Management

### What Each Agent Receives

| Agent | Receives in Prompt | Does NOT Receive |
|-------|-------------------|------------------|
| **Facilitator (question)** | Phase, consensus, conflicts, previous synthesis | Full participant responses |
| **Facilitator (synthesis)** | All current round responses, phase state | Previous round full responses |
| **Participants** | Topic, question, project context, previous synthesis | Other participant responses, full session |

### Context Isolation

This is critical for mitigating sycophancy:
- Participants respond in **parallel** (blind voting)
- Participants do **NOT** see each other's responses
- Participants only see **synthesis** of previous rounds, not full responses

## Fallback Behavior

If facilitator returns invalid YAML, use deterministic fallbacks:

### Fallback for Question Generation

```yaml
action: "question"
question: "What are the key considerations for {topic}?"
participants: "all"
focus: "Core requirements and constraints"
```

### Fallback for Synthesis

```yaml
action: "synthesis"
synthesis: "Discussion on {topic} requires further exploration."
consensus: []
conflicts: []
resolved: []
next_action: "continue"
next_focus: "Clarify positions"
```

### Fallback for Conclude (max rounds reached)

```yaml
action: "synthesis"
synthesis: "Discussion reached maximum rounds without full consensus."
consensus: {any points agreed on}
conflicts: {remaining open conflicts}
resolved: []
next_action: "conclude"
recommendation: "Review consensus points and address unresolved items separately."
output_type: "summary"
```

## Escalation Logic

Escalation is triggered when:
1. Same conflict persists after `max_rounds_per_conflict` rounds
2. Any participant confidence drops below threshold
3. Critical keywords detected (security, legal, blocking, must-have)
4. Facilitator explicitly returns `next_action: "escalate"`

When escalation occurs:
1. Display all positions with rationale to user
2. Show facilitator's recommendation
3. Ask user to: accept recommendation, provide own decision, or continue discussion
4. Record user decision in session file
5. Continue or conclude based on user choice

## Phase Transitions

For multi-phase strategies (Disney, Six-Hats, Debate):

1. Each phase has a `min_rounds` requirement (default: 1)
2. Facilitator cannot advance phase until min_rounds completed
3. Facilitator evaluates if phase goal is achieved
4. When ready, facilitator returns `next_action: "phase"`
5. Command advances to next phase in strategy's phase list

## Session File Updates

Updates happen at **end of each round** (batch write):

1. Create round data structure
2. Append to `rounds[]` array
3. Update `total_rounds`
4. Update `current_phase` if advancing
5. Write complete session file

This ensures consistency and prevents partial visibility of round data.

## Sequential Mode

For strategies requiring iterative building (sequential participation):

```markdown
If participation_mode == "sequential":
  responses = []
  for participant in participants:
    Task(participant, with previous_responses=responses)
    responses.append(participant_response)
```

This allows each participant to build on previous responses, at the cost
of losing blind voting benefits.

## Safety Limits

- **max_rounds**: 20 (configurable)
  - If reached, force conclude with summary
  - Note in session file

- **max_rounds_per_conflict**: 3 (configurable)
  - Track how many rounds each conflict persists
  - Escalate if limit reached

---

## Implementation Reference

The actual implementation is in:
- `commands/roundtable/start.md` - Main orchestration loop
- `agents/roundtable/facilitator.md` - Question generation and synthesis
- `agents/roundtable/*.md` - Participant agents

For strategy-specific behavior, see:
- `skills/roundtable-strategies/` - Strategy definitions and phases

---
*This file is part of Roundtable v4 documentation.*
*For the executable implementation, see `commands/roundtable/start.md`.*
