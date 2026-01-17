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

### Special Artifact States

Some artifact types have specialized lifecycles:

| Type | States | Notes |
|------|--------|-------|
| **open_questions** | `open`, `resolved` | Questions are answered, not amended |
| **conflicts** | `open`, `resolved` | Conflicts are resolved through discussion |

These do not follow the standard `active→amended→superseded/withdrawn` lifecycle.

---

## Agreement Level

Artifacts have an `agreement` field indicating participant consensus when created.

| Level | Description |
|-------|-------------|
| **consensus** | All participants agreed |
| **draft** | Tentative, needs further discussion |
| **conflict** | Disagreement exists, separate CONF artifact created |

**Note**: `agreement` is separate from lifecycle `status`. An artifact can be `status: "active"` with `agreement: "draft"`.

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
| **active** | Session in progress, can be resumed | closed |
| **closed** | Session finished (successfully or not) | - (terminal) |

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
| **specs** | product-manager, ux-researcher, business-analyst, qa-lead |
| **design** | software-architect, security-champion, technical-lead, devops-engineer |
| **brainstorm** | Varies by --participants flag |

**Override Participants** (available for custom use):
- documentation-specialist
- claude-code-expert
- oss-community-manager
- security-champion (also default for design)
- ux-researcher (also default for specs)

### Workflow-Specific Behavior

Participants adapt their contribution based on workflow type:

| Participant | specs | design | brainstorm |
|-------------|-------|--------|------------|
| product-manager | Primary: user value | Advisory: UX impact | Champion ideas |
| ux-researcher | Primary: user needs | Reviewer: API usability | User advocate |
| business-analyst | Primary: domain model | Validator: alignment | Grounding |
| qa-lead | Primary: testability | Reviewer: quality | Risk spotter |
| software-architect | Feasibility | Primary: structure | Evaluator |
| security-champion | NFR: security reqs | Primary: threat model | Risk identifier |
| technical-lead | Complexity | Primary: code | Practical |
| devops-engineer | Early warning | Primary: ops | Operations lens |
| documentation-specialist | Clarity | Planning | Capture |
| claude-code-expert | Platform | Primary: plugin | Enabler |
| oss-community-manager | Contributor | Extension | Adoption |

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
| **Diagnostic Mode** | Optional validation mode (`--diagnostic`) that analyzes roundtable execution |

---

## Project Structure Terms

| Term | Definition |
|------|------------|
| **Workspace** | Configuration that coordinates multiple related projects |
| **Component** | A project that is part of a workspace |
| **Standalone** | A single project not part of any workspace |
| **Monorepo** | Workspace where all components share ONE git repository |
| **Multi-repo** | Workspace where components have SEPARATE git repositories |
| **Hybrid** | Mix of monorepo and multi-repo (some components share repo, others separate) |

### Project Types

| Type | config.yaml `type` | Has workspace.yaml | Description |
|------|-------------------|-------------------|-------------|
| **Standalone** | `standalone` | No | Single independent project |
| **Workspace** | `workspace` | Yes | Coordinates multiple components |
| **Component** | `component` | No (parent has) | Part of a workspace |

### Reference Patterns

| Context | Pattern | When to Use |
|---------|---------|-------------|
| **Internal reference** | `@../path` | In `.s2s/` files, relative filesystem path |
| **External reference** | `[text](URL)` | In `docs/` files, absolute URL for publication |

**Rule**: Internal = relative, External = absolute.

---

## Diagnostic Mode

Diagnostic mode (`--diagnostic` flag) enables post-round analysis to detect anomalies during roundtable execution.

### Observer Agent

The `session-observer` agent (haiku model) analyzes verbose dumps after each round.

**Input**:
```yaml
mode: "per-round" | "end-session"
session_path: ".s2s/sessions/{session-id}"
round: {N}  # for per-round mode
workflow_type: "specs" | "design" | "brainstorm"
strategy: "{strategy}"
```

**Output**:
```yaml
status: "ok" | "warning" | "anomaly"
findings:
  - type: "missing_context" | "strategy_deviation" | "participant_signal"
    detail: "{description}"
    severity: "low" | "medium" | "high"
recommendation: "Continue" | "Review findings" | "Stop for investigation"
```

### Diagnostic Report Format

Final report displayed at session completion:

```
╔════════════════════════════════════════════════════════════╗
║                    DIAGNOSTIC REPORT                        ║
╠════════════════════════════════════════════════════════════╣
║ Session: {session-id}                                       ║
║ Workflow: {type} | Strategy: {strategy} | Rounds: {N}       ║
╠════════════════════════════════════════════════════════════╣
║ Round 1: ok                                                 ║
║ Round 2: warning (2 findings)                               ║
║ Round 3: ok                                                 ║
╠════════════════════════════════════════════════════════════╣
║ Session-level findings:                                     ║
║ - [medium] strategy_deviation: ...                          ║
╠════════════════════════════════════════════════════════════╣
║ RESULT: PASS | PASS with warnings | NEEDS REVIEW            ║
╚════════════════════════════════════════════════════════════╝
```

### Severity Guidelines

| Severity | Meaning | Action |
|----------|---------|--------|
| **low** | Minor, likely false positive | Continue |
| **medium** | Worth reviewing | Review findings |
| **high** | Significant issue | Stop for investigation |
