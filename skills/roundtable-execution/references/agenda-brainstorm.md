# Brainstorm Workflow Agenda

This file defines the phase-based agenda for `/s2s:brainstorm` roundtable sessions.

## Purpose

Brainstorm uses the Disney Creative Strategy with three mandatory phases: Dreamer, Realist, Critic.
Unlike specs/design, brainstorm doesn't have topic-based agenda - it follows a fixed phase progression.

---

## Phase-Based Agenda

```yaml
phases:
  - id: "dreamer"
    name: "Dreamer Phase"
    description: "Generate ideas without constraints or criticism"
    order: 1
    done_when:
      criteria:
        - "At least 3 ideas generated per participant"
        - "Ideas are bold and unconstrained"
        - "No criticism or feasibility concerns raised"
      min_artifacts: 3  # IDEA-* artifacts
    facilitator_directive: |
      DREAMER PHASE: Generate creative ideas freely.
      - No criticism allowed - ALL ideas are valid
      - Think big, ignore constraints for now
      - Build on each other's ideas
      - Focus on "What if?" not "Why not?"
    exploration: "What other possibilities exist? What would be ideal?"

  - id: "realist"
    name: "Realist Phase"
    description: "Ground ideas in practical reality"
    order: 2
    done_when:
      criteria:
        - "Each dreamer idea evaluated for feasibility"
        - "Implementation approach sketched"
        - "Resource requirements identified"
      min_artifacts: 0  # Feasibility notes, not formal artifacts
    facilitator_directive: |
      REALIST PHASE: Make ideas practical.
      - Take dreamer ideas and ground them in reality
      - Consider resources, timeline, dependencies
      - Identify MVP version of each idea
      - Keep the vision but add practical constraints
    exploration: "How would we actually implement this? What's the MVP?"

  - id: "critic"
    name: "Critic Phase"
    description: "Identify risks and concerns constructively"
    order: 3
    done_when:
      criteria:
        - "Risks identified for viable ideas"
        - "Mitigations proposed for key risks"
        - "Final recommendations formed"
      min_artifacts: 2  # RISK-* and MIT-* artifacts
    facilitator_directive: |
      CRITIC PHASE: Identify what could go wrong.
      - Analyze risks and failure modes
      - Reference specific ideas: "IDEA-001 has risk..."
      - Propose mitigations where possible
      - Be constructive - improve the plan, don't just criticize
    exploration: "What could go wrong? What are we missing?"
```

---

## Phase Transition Rules

| Transition | Condition |
|------------|-----------|
| dreamer → realist | At least 3 IDEA-* artifacts created, no blocking concerns |
| realist → critic | All viable ideas have implementation sketch |
| critic → complete | Risks identified, mitigations proposed, recommendations formed |

---

## Artifact Types

| Phase | Primary Artifact | Description |
|-------|-----------------|-------------|
| **dreamer** | IDEA-* | Creative idea without constraints |
| **realist** | (notes only) | Feasibility assessment attached to ideas |
| **critic** | RISK-*, MIT-* | Identified risks and proposed mitigations |

### IDEA Artifact Format

```yaml
type: "idea"
id: "IDEA-001"
title: "Real-time collaboration feature"
phase: "dreamer"
description: "Allow multiple users to edit simultaneously"
proposed_by: "software-architect"
builds_on: null  # or reference to another IDEA
```

### RISK Artifact Format

```yaml
type: "risk"
id: "RISK-001"
title: "Conflict resolution complexity"
phase: "critic"
related_idea: "IDEA-001"
description: "Real-time sync requires conflict resolution"
severity: "high"  # high | medium | low
likelihood: "medium"
proposed_by: "technical-lead"
```

### MIT (Mitigation) Artifact Format

```yaml
type: "mitigation"
id: "MIT-001"
title: "Use CRDTs for conflict-free sync"
phase: "critic"
addresses: "RISK-001"
description: "Implement Conflict-free Replicated Data Types"
effort: "high"
effectiveness: "high"
proposed_by: "software-architect"
```

---

## Output Generation

At session completion, generate summary with:

1. **Ideas Summary**: All IDEA-* artifacts ranked by feasibility
2. **Risk Assessment**: All RISK-* with mitigations
3. **Recommendations**: Top 3 ideas to pursue
4. **Open Questions**: Any unresolved OQ-* artifacts

Output file: `.s2s/sessions/{session-id}-summary.md`

---

## Key Differences from specs/design

| Aspect | specs/design | brainstorm |
|--------|--------------|------------|
| Agenda type | Topic-based | Phase-based |
| Strategy | Configurable | Disney (forced) |
| Progression | By topic closure | By phase completion |
| Criticism | Always allowed | Only in critic phase |
| Artifacts | Requirements/Architecture | Ideas/Risks/Mitigations |

---

## Facilitator Notes

### Dreamer Phase
- Actively encourage bold ideas
- Redirect any criticism: "We'll evaluate feasibility in the next phase"
- Build energy and momentum

### Realist Phase
- Reference specific ideas from dreamer phase
- Focus on HOW, not WHETHER
- Identify dependencies and blockers

### Critic Phase
- Be thorough but constructive
- Every criticism should have a potential mitigation
- Prioritize risks by severity × likelihood
