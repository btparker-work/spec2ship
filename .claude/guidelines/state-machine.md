# State Machines

This document defines all state transitions in Spec2Ship.

---

## Session Lifecycle

```
                    ┌─────────┐
                    │  init   │
                    └────┬────┘
                         │
                         ▼
                    ┌─────────┐
          ┌────────►│ active  │◄────────┐
          │         └────┬────┘         │
          │              │              │
          │   ┌──────────┼──────────┐   │
          │   │          │          │   │
          │   ▼          ▼          ▼   │
     ┌────────┐    ┌──────────┐  ┌──────┐
     │ paused │    │completed │  │failed│
     └────────┘    └──────────┘  └──────┘
          │
          ▼
     ┌─────────┐
     │abandoned│
     └─────────┘
```

### Transitions

| From | To | Trigger |
|------|-----|---------|
| init | active | Session created |
| active | paused | User interruption / timeout |
| active | completed | All agenda items closed + min_rounds met |
| active | failed | Unrecoverable error |
| paused | active | User resumes |
| paused | abandoned | User declines to continue |

---

## Artifact Lifecycle

```
     ┌────────┐
     │ create │
     └───┬────┘
         │
         ▼
     ┌────────┐
     │ active │◄──────────────┐
     └───┬────┘               │
         │                    │
    ┌────┴────┬───────┐       │
    │         │       │       │
    ▼         ▼       ▼       │
┌───────┐┌──────────┐┌─────────┐
│amended││superseded││withdrawn│
└───┬───┘└──────────┘└─────────┘
    │
    │ (revert)
    └─────────────────────────┘
```

### Transitions

| From | To | Trigger | Requirements |
|------|-----|---------|--------------|
| - | active | Artifact created | Proposal accepted in synthesis |
| active | amended | Modification in later round | Amendment record added |
| active | superseded | Replaced by new artifact | Replacement artifact ID noted |
| active | withdrawn | Removed from scope | Rationale recorded |
| amended | active | Revert to previous version | Amendment reversed |
| amended | superseded | Replaced by new artifact | Replacement artifact ID noted |
| amended | withdrawn | Removed from scope | Rationale recorded |

**Rules**:
- `superseded` and `withdrawn` are terminal states
- `amended` preserves full history in amendments array
- An artifact cannot be both superseded AND withdrawn

---

## Topic Lifecycle

```
     ┌──────┐
     │ open │
     └──┬───┘
        │
        ▼
     ┌─────────┐
     │ partial │
     └────┬────┘
          │
          ▼
     ┌────────┐
     │ closed │
     └────────┘
```

### Transitions

| From | To | Trigger |
|------|-----|---------|
| open | partial | First coverage item addressed |
| partial | closed | All done_when criteria met |
| open | closed | All done_when criteria met in single round (rare) |

**Closure Criteria**:
```yaml
done_when:
  criteria:
    - "Primary user personas identified"
    - "Entry/exit conditions defined"
  min_requirements: 2
```

A topic is closed when:
1. All listed `criteria` appear in `coverage`
2. At least `min_requirements` artifacts created for that topic

---

## Round Lifecycle

```
     ┌───────────────┐
     │ facilitator   │
     │   question    │
     └───────┬───────┘
             │
             ▼
     ┌───────────────┐
     │  participant  │
     │   responses   │
     └───────┬───────┘
             │
             ▼
     ┌───────────────┐
     │ facilitator   │
     │   synthesis   │
     └───────┬───────┘
             │
             ▼
     ┌───────────────┐
     │ process       │
     │ artifacts     │
     └───────┬───────┘
             │
             ▼
     ┌───────────────┐
     │ update        │
     │ session file  │
     └───────┬───────┘
             │
             ▼
     ┌───────────────┐
     │ validate      │
     │ round output  │
     └───────────────┘
```

### Steps (from command perspective)

1. **Step 2.2**: Facilitator generates question + participant_context
2. **Step 2.3**: All participants respond (parallel)
3. **Step 2.4**: Facilitator synthesizes responses
4. **Step 2.5**: Process proposed artifacts
5. **Step 2.6**: Update session file
6. **Step 2.6b**: Validate round output

---

## Next Action Decision

```
                    ┌────────────────────┐
                    │ synthesis complete │
                    └─────────┬──────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
         ┌────────┐     ┌─────────┐     ┌──────────┐
         │continue│     │conclude │     │ escalate │
         └────────┘     └─────────┘     └──────────┘
```

### Decision Logic

| Condition | Result |
|-----------|--------|
| rounds < min_rounds | `continue` (forced) |
| All agenda topics closed | `conclude` |
| rounds >= max_rounds | `conclude` (forced) |
| Low confidence + critical issue | `escalate` |
| Open conflicts remaining | `continue` |

**Escalation Triggers**:
- max_rounds_per_conflict exceeded
- Confidence below threshold on critical keyword
- User explicitly requests

---

## Agent Resume State

```
                    ┌──────────────────┐
                    │ round completed  │
                    └────────┬─────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
         ┌──────────┐  ┌──────────┐  ┌──────────┐
         │ resume   │  │  fresh   │  │ dispose  │
         │(agent_id)│  │(new agent│  │(no track)│
         └──────────┘  └──────────┘  └──────────┘
```

### Resume Policy

| Agent Type | Default | Configurable |
|------------|---------|--------------|
| Facilitator | resume | Yes |
| Participants | fresh | Yes |

When resuming:
1. Agent receives context_reconciliation block
2. Lists artifacts_updated, artifacts_resolved
3. Instruction to treat current context as authoritative
