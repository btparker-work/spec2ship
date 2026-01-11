# SAD-006: Session Architecture

**Status**: Accepted
**Date**: 2026-01-10
**Decision Makers**: Architecture discussion during v5 refactoring

## Context

Roundtable sessions produce artifacts (requirements, decisions, ideas, etc.) that need to be tracked, versioned, and exported. The original design used:
- Separate files per artifact (`{session-folder}/{ID}.yaml`)
- Session file as index only
- Verbose dumps for debugging

This caused complexity in:
- File synchronization (session file vs artifact files)
- Context propagation to participants (who have no tools)
- Validation and recovery

## Decision Drivers

1. **Simplicity**: Minimize file operations and sync requirements
2. **Self-sufficiency**: Session file should be complete without external dependencies
3. **Auditability**: Enable debugging without requiring --verbose flag
4. **LLM-friendly**: Single file readable with one Read tool call
5. **Git-ignorable**: .s2s is in .gitignore - can't rely on git for recovery

## Considered Options

### Option A: Separate Files (Original)
```
.s2s/sessions/{id}/
├── {id}.yaml         # Index only
├── REQ-001.yaml
├── REQ-002.yaml
└── rounds/           # Verbose dumps
```

**Pros**: Clean separation, small files
**Cons**: Sync complexity, multiple reads needed

### Option B: Embedded Artifacts (Chosen)
```
.s2s/sessions/{id}.yaml    # Complete session with embedded artifacts
.s2s/sessions/{id}/rounds/ # Verbose dumps (optional)
```

**Pros**: Single source of truth, atomic updates
**Cons**: Larger file, but within reasonable limits

### Option C: Event Sourcing
Store all changes as events, derive state.

**Pros**: Complete audit trail
**Cons**: Complexity overkill for this use case

## Decision

**Adopt Option B: Embedded Artifacts**

The session file is the single source of truth containing:
- Session metadata
- All artifacts with full content
- Amendments inline within artifacts
- Round summaries for basic audit
- Metrics

## Consequences

### Positive
- Single file read provides complete context
- No sync issues between files
- Participants receive inline context (they have no tools)
- Validation operates on one file

### Negative
- Session file grows with artifacts (~50-100KB typical)
- Must update carefully to avoid corruption

### Mitigations
- Round summary provides basic audit without --verbose
- Verbose dumps remain available for deep debugging
- Validation commands detect inconsistencies

## Related Decisions

- **No index.yaml**: Redundant with session file
- **No events.yaml**: Redundant with rounds[] array
- **Amendment schema**: Generic `changes.*` structure
- **Round summary**: Always included for basic auditability
- **Validation levels**: Structural (fast) + LLM-based (deep)

## Session File Schema (Summary)

```yaml
# Core
id, workflow_type, strategy, status
timing: {started, last_activity, completed}

# Agent resume state
agent_state:
  facilitator: {agent_id, last_round}
  participants: {...}

# Artifacts (embedded, workflow-specific)
artifacts:
  requirements: {REQ-001: {..., amendments: [...]}}
  open_questions: {...}
  conflicts: {...}
  # ... per workflow type

# Progress tracking
agenda: [{topic_id, status, coverage}]
rounds: [{round, topic, synthesis_summary, artifacts_created, ...}]

# Analytics
metrics: {rounds_completed, artifacts: {total, by_type, by_status}, ...}

# Health
validation: {last_check, status, warnings}
```

## Implementation Notes

1. **Specs-first approach**: Implement in specs.md, then decide whether to replicate or centralize
2. **Backward compatibility**: Not required - .s2s is gitignored
3. **Migration**: Not needed - sessions are ephemeral

## References

- Plan file: spec2ship-refactoring-v5.md, sections P2-12, P2-13
- Discussion: Session Architecture Design (2026-01-10)
