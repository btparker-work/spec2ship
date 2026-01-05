# Roundtable Flow (v3)

This document describes the complete flow of a roundtable discussion from user command to output document.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  User: /s2s:specs, /s2s:design, /s2s:brainstorm                │
│  • Workflow-specific setup and validation                       │
│  • Delegates via SlashCommand:/s2s:roundtable:start             │
│  • Post-processes results into workflow-specific output         │
└──────────────────────────────┬──────────────────────────────────┘
                               │ SlashCommand
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Command (start.md) - SESSION LIFECYCLE                         │
│  • Auto-detects strategy from topic keywords                    │
│  • Creates session file .s2s/sessions/{id}.yaml                 │
│  • Launches Orchestrator Agent with session context             │
│  • Batch writes results after each round                        │
│  • Generates output document (ADR, requirements, etc.)          │
└──────────────────────────────┬──────────────────────────────────┘
                               │ Task Agent
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Orchestrator Agent - LOOP COORDINATION                         │
│  • Manages roundtable loop (rounds until conclusion)            │
│  • Launches Facilitator for questions and synthesis             │
│  • Launches Participants in parallel (blind voting)             │
│  • Checks escalation triggers                                   │
│  • Returns structured YAML for batch write                      │
│  • skills: roundtable-strategies                                │
│                                                                 │
│    ┌─────────────────────────────────────────────────────────┐  │
│    │ Facilitator Agent (opus) - DECISION MAKER               │  │
│    │ • Generates focused questions per phase                 │  │
│    │ • Synthesizes participant responses                     │  │
│    │ • Identifies consensus and conflicts                    │  │
│    │ • Decides next action: continue, next_phase, conclude   │  │
│    └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│    │Architect│ │TechLead │ │ QA Lead │ │ DevOps  │ │ ProdMgr │ │
│    └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
│    ▲                                                            │
│    │ Launched in PARALLEL (blind voting, no cross-talk)         │
└─────────────────────────────────────────────────────────────────┘
```

## Complete Flow: Single Round

```
┌──────────────────────────────────────────────────────────────────┐
│ ROUND N                                                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│ 1. ORCHESTRATOR: Prepare round context                           │
│    ├── Increment round counter                                   │
│    ├── Check max_rounds limit                                    │
│    └── Build facilitator input with history                      │
│                                                                  │
│ 2. FACILITATOR: Generate question                                │
│    ├── Task(facilitator) with session context                    │
│    ├── Returns: { action, phase, question, focus_areas }         │
│    └── Orchestrator validates YAML response                      │
│                                                                  │
│ 3. PARTICIPANTS: Respond (parallel, blind voting)                │
│    ├── Task(architect) ─┐                                        │
│    ├── Task(tech-lead) ─┼── All launched simultaneously          │
│    ├── Task(qa-lead) ───┤   No agent sees other responses        │
│    ├── Task(devops) ────┤                                        │
│    └── Task(prod-mgr) ──┘                                        │
│                                                                  │
│    Each returns: { position, rationale, confidence }             │
│                                                                  │
│ 4. FACILITATOR: Synthesize responses                             │
│    ├── Task(facilitator) with all participant responses          │
│    ├── Identifies consensus points                               │
│    ├── Identifies conflicts with positions                       │
│    └── Returns: { synthesis, new_consensus, new_conflicts,       │
│                   next_action, escalation_reason }               │
│                                                                  │
│ 5. ORCHESTRATOR: Evaluate next action                            │
│    ├── continue_round → Loop back to step 1                      │
│    ├── next_phase → Update phase, loop back                      │
│    ├── conclude → Prepare final output                           │
│    └── escalate → Return escalation data, await user             │
│                                                                  │
│ 6. ORCHESTRATOR: Return round data to command                    │
│    └── { status, round_data, updated_state }                     │
│                                                                  │
│ 7. COMMAND: Batch write to session file                          │
│    └── Atomic update at end of round                             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Participation Modes

### Parallel Mode (Default)

Used by: Standard, Disney (within phase), Debate (within side)

```
Orchestrator launches:
    Task(architect) ──┬── All execute simultaneously
    Task(tech-lead) ──┤   Responses collected together
    Task(qa-lead) ────┤   No agent sees others' responses
    Task(devops) ─────┤
    Task(prod-mgr) ───┘
```

**Benefits**:
- Prevents sycophancy (no copying)
- True independent perspectives
- Faster execution

### Sequential Mode

Used by: Six Hats, Consensus-Driven (iterative)

```
Orchestrator launches:
    Task(participant-1) → response
        ↓ passed to
    Task(participant-2) → response
        ↓ passed to
    Task(participant-3) → response
        ...
```

**Benefits**:
- Building on ideas
- Iterative refinement
- Deeper exploration

## Fallback Behavior

When facilitator returns invalid YAML:

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. First failure:                                               │
│    └── Retry facilitator with error message                     │
│                                                                 │
│ 2. Second failure:                                              │
│    └── Use deterministic fallback:                              │
│        ├── For generate_question:                               │
│        │   "What are the key considerations for {topic}?"       │
│        ├── For synthesize:                                      │
│        │   Extract keywords, basic synthesis                    │
│        └── For conclude:                                        │
│            List all consensus + remaining conflicts             │
└─────────────────────────────────────────────────────────────────┘
```

## Escalation Flow

When escalation triggers fire:

```
┌─────────────────────────────────────────────────────────────────┐
│ TRIGGER CONDITIONS:                                             │
│ ├── Same conflict persists after N rounds                       │
│ ├── Participant confidence below threshold                      │
│ ├── Critical keywords detected (security, must-have, blocking)  │
│ └── Facilitator explicitly returns action: escalate             │
├─────────────────────────────────────────────────────────────────┤
│ ESCALATION FLOW:                                                │
│                                                                 │
│ 1. Orchestrator includes escalation data in round result        │
│    { escalation: { triggered: true, reason, positions } }       │
│                                                                 │
│ 2. Command receives escalation status                           │
│                                                                 │
│ 3. Command asks user for decision:                              │
│    "Escalation needed: {reason}"                                │
│    Options: [Choose position A] [Choose position B] [Continue]  │
│                                                                 │
│ 4. Based on user choice:                                        │
│    ├── Position chosen → Add to consensus, continue             │
│    └── Continue → Add user input to context, resume             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Strategy-Specific Flows

### Disney Strategy (3 phases)

```
Phase 1: DREAMER              Phase 2: REALIST              Phase 3: CRITIC
─────────────────────────     ─────────────────────────     ─────────────────────────
"What if anything were        "How do we actually do        "What could go wrong?"
 possible?"                    this?"

No constraints                Ground ideas in reality       Stress-test the plan
No criticism                  Timeline, resources           Risk identification
Focus on ideal solution       Identify MVP                  Edge cases, security

Context: Topic only           Context: + Dreamer output     Context: + Dreamer + Realist
```

### Debate Strategy (Pro vs Con)

```
Opening (parallel)     Rebuttal (parallel)     Closing (parallel)
──────────────────     ────────────────────    ──────────────────
Pro presents case      Pro addresses Con       Pro final summary
Con presents case      Con addresses Pro       Con final summary

                       Facilitator Synthesis
                       ─────────────────────
                       Weighs arguments
                       Produces recommendation
```

## Data Flow Summary

```
User Command
    │
    ▼
┌─────────────┐
│ start.md    │──┬── Creates session file
│             │  └── Launches orchestrator
└─────────────┘
       │
       ▼
┌─────────────┐
│Orchestrator │──┬── Manages loop
│             │  ├── Launches facilitator (2x/round)
│             │  └── Launches participants (parallel)
└─────────────┘
       │
       ▼
┌─────────────┐
│ Facilitator │──┬── Generates questions
│             │  └── Synthesizes responses
└─────────────┘
       │
       ▼
┌─────────────┐
│Participants │──── Provide domain perspectives
└─────────────┘
       │
       ▼
┌─────────────┐
│ start.md    │──┬── Batch writes session
│             │  └── Generates output document
└─────────────┘
       │
       ▼
Output: ADR, Requirements, Architecture, Summary
```

---
*See [components.md](./components.md) for detailed component documentation*
*Part of Spec2Ship Roundtable v3 documentation*
