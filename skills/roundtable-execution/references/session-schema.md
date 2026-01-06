# Session File Schema

Complete YAML schema for roundtable session files.

## File Location

`.s2s/sessions/{session-id}.yaml`

## Full Schema

```yaml
# === IDENTIFICATION ===
id: "{session-id}"
topic: "{topic}"
workflow_type: "{specs|design|brainstorm}"
strategy: "{standard|disney|debate|consensus-driven|six-hats}"
status: "active"  # active|paused|completed

# === TIMESTAMPS ===
started: "{ISO timestamp}"
paused_at: null  # ISO timestamp if paused
completed_at: null  # ISO timestamp when completed

# === PARTICIPANTS ===
participants:
  - id: "{participant-1}"
    name: "{Display Name}"
  # ... more participants

# === EXECUTION STATE ===
current_phase: "{first phase from strategy}"
total_rounds: 0

# === CONFIG ===
config:
  min_rounds: 3
  max_rounds: 20
  verbose: false
  interactive: false
  escalation:
    max_rounds_per_conflict: 3
    confidence_below: 0.5
    critical_keywords: ["security", "must-have", "blocking", "legal"]

# === ROUNDS (Single Source of Truth) ===
rounds: []

# === ESCALATIONS ===
escalations: []

# === OUTPUT ===
outcome: null
```

## Round Structure

Each round in `rounds[]`:

```yaml
- number: {round_number}
  phase: "{current_phase}"
  timestamp: "{ISO timestamp}"
  question: "{facilitator's question}"
  focus: "{facilitator's focus}"
  synthesis: "{facilitator's synthesis - 2-4 sentences}"
  consensus:
    - "{new agreed point}"
  conflicts:
    - id: "{slug-id}"
      description: "{what the conflict is about}"
      positions:
        participant-id: "{their position}"
  resolved:
    - conflict_id: "{previously open conflict now resolved}"
      resolution: "{how it was resolved}"
      resolution_type: "consensus"
```

## Verbose Mode: Response Structure

When `--verbose` flag is used, include in each round:

```yaml
  responses:
    - participant: "{participant-id}"
      role: "{Display Name}"
      position: "{full position statement}"
      rationale:
        - "{reason 1}"
        - "{reason 2}"
      concerns:
        - "{concern 1}"
      confidence: 0.8
      context_challenge: "{if any, else null}"
```

## Escalation Structure

Each escalation in `escalations[]`:

```yaml
- round: {round_number}
  reason: "{why escalated}"
  positions: "{summary of positions}"
  user_decision: "{what user decided}"
  resolution: "{how resolved}"
```

## Outcome Structure

When session completes:

```yaml
outcome:
  type: "{adr|requirements|architecture|summary}"
  file: "{output file path}"
  consensus_count: {number}
  unresolved_conflicts: {number}
```

---

*Part of roundtable-execution skill*
