# Spec2Ship Glossary

This document defines the terminology used throughout Spec2Ship.

---

## Artifact Types

Artifacts are the discrete outputs of roundtable discussions.

| Type | ID Pattern | Workflow | Description |
|------|------------|----------|-------------|
| **Requirement** | `REQ-NNN` | specs | Functional requirement with acceptance criteria |
| **Business Rule** | `BR-NNN` | specs | Business logic or constraint |
| **NFR** | `NFR-NNN` | specs | Non-functional requirement (performance, security, etc.) |
| **Exclusion** | `EX-NNN` | specs | Explicitly out-of-scope item |
| **Open Question** | `OQ-NNN` | all | Unresolved question requiring decision |
| **Conflict** | `CONF-NNN` | all | Disagreement between participants |
| **Architecture Decision** | `ARCH-NNN` | design | Technical architecture choice |
| **Component** | `COMP-NNN` | design | System component definition |
| **Interface** | `INT-NNN` | design | API or integration interface |
| **Idea** | `IDEA-NNN` | brainstorm | Creative idea from discussion |
| **Risk** | `RISK-NNN` | brainstorm | Identified risk |
| **Mitigation** | `MIT-NNN` | brainstorm | Risk mitigation strategy |

---

## Artifact States

Each artifact has a status that changes throughout its lifecycle.

| State | Description | Valid Transitions |
|-------|-------------|-------------------|
| **active** | Current, valid artifact | amended, superseded, withdrawn |
| **amended** | Modified by subsequent round | active (reverted), superseded, withdrawn |
| **superseded** | Replaced by newer artifact | - (terminal) |
| **withdrawn** | Removed from scope | - (terminal) |

**Notes**:
- `active` is the initial state for newly created artifacts
- `amended` preserves history while marking as modified
- `superseded` requires reference to replacement artifact
- `withdrawn` requires rationale

---

## Topic States

Topics are agenda items discussed in roundtable sessions.

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| **open** | Not yet discussed or minimal progress | Initial state |
| **partial** | Discussion started, criteria partially met | Some coverage items addressed |
| **closed** | All done_when criteria satisfied | min_requirements met AND all criteria covered |

---

## Session States

Sessions track the lifecycle of a roundtable discussion.

| State | Description | Transitions |
|-------|-------------|-------------|
| **active** | Session in progress | paused, completed, failed |
| **paused** | Interrupted, can resume | active, abandoned |
| **completed** | Successfully concluded | - (terminal) |
| **failed** | Terminated due to error | - (terminal) |
| **abandoned** | User chose not to continue | - (terminal) |

---

## Amendment

A record of changes made to an existing artifact.

```yaml
amendments:
  - round: 3
    summary: "Added edge case criterion"
    proposed_by: qa-lead
    supported_by: [product-manager]
    changes:
      acceptance:
        added: ["Handle null input"]
      priority:
        changed_from: "should"
        changed_to: "must"
```

**Fields**:
- `round`: When the amendment was made
- `summary`: Human-readable description of the change
- `proposed_by`: Participant who proposed the change
- `supported_by`: Participants who agreed
- `changes`: Structured diff by field

---

## Participant Roles

Standard participants for each workflow.

| Workflow | Default Participants |
|----------|---------------------|
| **specs** | product-manager, business-analyst, qa-lead |
| **design** | software-architect, technical-lead, devops-engineer |
| **brainstorm** | Varies by --participants flag |

**Override Participants** (available for custom use):
- documentation-specialist
- claude-code-expert
- oss-community-manager

---

## Strategies

Discussion strategies determine how rounds are conducted.

| Strategy | Description | Default For |
|----------|-------------|-------------|
| **standard** | Simple parallel discussion | - |
| **consensus-driven** | Proposal→refinement→convergence | specs |
| **debate** | Pro/con with structured rebuttal | design |
| **disney** | Dreamer→realist→critic phases | brainstorm |
| **six-hats** | Six thinking perspectives | - |

---

## Facilitator Actions

The facilitator agent performs two main actions per round.

| Action | Input | Output |
|--------|-------|--------|
| **question** | Session state, agenda | Question, participant_context |
| **synthesis** | Participant responses | Artifacts, next action |

---

## Common Terms

| Term | Definition |
|------|------------|
| **Roundtable** | AI-facilitated discussion between specialized participants |
| **Round** | One cycle of: question → responses → synthesis |
| **Agenda** | Ordered list of topics to discuss |
| **Coverage** | List of criteria already addressed for a topic |
| **done_when** | Criteria that must be met to close a topic |
| **Escalation** | User intervention when consensus cannot be reached |
| **Context Reconciliation** | Block sent to resumed agents about changes since last round |
