# Task Parameters Quick Reference

Quick reference for Task() tool parameters used in roundtable execution.

## Facilitator (Question Generation)

```yaml
subagent_type: "general-purpose"
description: "Facilitator generates question"
prompt: |
  You are the Roundtable Facilitator.
  Read your agent definition from: agents/roundtable/facilitator.md

  === SESSION STATE ===
  Topic: {topic}
  Strategy: {strategy}
  Current Phase: {current_phase}
  Round: {round_number + 1}

  === HISTORY ===
  Previous synthesis: {last round's synthesis or 'First round'}
  Current consensus: {accumulated consensus or 'None yet'}
  Open conflicts: {unresolved conflicts or 'None'}

  === TASK ===
  Generate the next question for participants.

  Return YAML:
  action: "question"
  question: "{specific question}"
  participants: "all"
  focus: "{focus area}"
```

## Participant Response

```yaml
subagent_type: "general-purpose"
description: "{Role} provides perspective"
prompt: |
  You are the {Participant Role} in a roundtable discussion.
  Read your agent definition from: agents/roundtable/{participant-id}.md

  === DISCUSSION ===
  Topic: {topic}
  Question: {facilitator's question}
  Focus: {facilitator's focus}

  === TASK ===
  Provide your perspective on the question.

  Return YAML:
  position: "{your position statement}"
  rationale:
    - "{reason 1}"
    - "{reason 2}"
  confidence: 0.8
  concerns:
    - "{any concerns}"
```

## Facilitator (Synthesis)

```yaml
subagent_type: "general-purpose"
description: "Facilitator synthesizes round"
prompt: |
  You are the Roundtable Facilitator.
  Read agents/roundtable/facilitator.md

  === ROUND RESPONSES ===
  {For each participant: role, position, confidence}

  === TASK ===
  Synthesize responses. Identify consensus and conflicts.

  Return YAML:
  action: "synthesis"
  synthesis: "{summary}"
  consensus:
    - "{agreed point}"
  conflicts:
    - id: "{slug}"
      description: "{what}"
  next_action: "continue"  # continue|phase|conclude|escalate
```

## Common Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `subagent_type` | Yes | Always "general-purpose" for roundtable |
| `description` | Yes | Short description for logging |
| `prompt` | Yes | Full prompt with context |
| `model` | No | Defaults to inherit, use "opus" for facilitator |

---

*Part of roundtable-execution skill*
