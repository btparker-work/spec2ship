# Roundtable Components

This document describes how Commands, Agents, and Skills work together in the Roundtable system.

## Component Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER                                    │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ COMMAND: roundtable/start.md                            │   │
│  │ (Executor - orchestrates the process)                   │   │
│  │                                                         │   │
│  │ • Loads config.yaml                                     │   │
│  │ • Loads strategy skill                                  │   │
│  │ • Creates session file                                  │   │
│  │ • Executes roundtable loop                              │   │
│  │ • Writes output documents                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│            ┌──────────────┼──────────────┐                     │
│            ▼              ▼              ▼                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   AGENT:    │  │   AGENT:    │  │   AGENT:    │            │
│  │ Facilitator │  │  Architect  │  │  Tech Lead  │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ SKILL: roundtable-strategies/{strategy}.md               │   │
│  │ (Knowledge about facilitation method)                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Commands

### roundtable/start.md

The main orchestrator. Acts as **Executor**:

| Responsibility | Description |
|----------------|-------------|
| Load configuration | Read `.s2s/config.yaml` for strategy, participants |
| Create session | Initialize `.s2s/sessions/{id}.yaml` |
| Execute loop | Call facilitator, launch participants, collect responses |
| Batch write | Update session file at end of each round |
| Check escalation | Evaluate triggers, ask user if needed |
| Generate output | Create ADR, requirements, or architecture docs |

### roundtable/resume.md

Continues an interrupted session:
- Loads full session history
- Passes to facilitator with `resumed: true`
- Continues loop from where it left off

### roundtable/list.md

Displays session status:
- Groups by active/paused/completed
- Shows strategy, phase, round count
- Marks current session

## Agents

### Facilitator Agent

Location: `agents/roundtable/facilitator.md`

**Role**: Orchestrate discussion, generate questions, synthesize responses

**Input**: Structured YAML with session state, history, context
**Output**: Structured YAML with action, question/synthesis, next steps

**Key Decisions Made by Facilitator**:
- What question to ask next
- Which participants are relevant (for targeted mode)
- Whether consensus is reached
- Whether to continue, move to next phase, or conclude
- Whether to recommend escalation

### Participant Agents

Location: `agents/roundtable/`

| Agent | File | Perspective |
|-------|------|-------------|
| Software Architect | `software-architect.md` | Structure, patterns, design |
| Technical Lead | `technical-lead.md` | Implementation, tech stack |
| QA Lead | `qa-lead.md` | Quality, testing, edge cases |
| DevOps Engineer | `devops-engineer.md` | Deploy, infra, operations |
| Product Manager | `product-manager.md` | User needs, business value |

**Input**: Topic, question, context, previous synthesis
**Output**: Position, rationale, confidence, dependencies

## Skills

### roundtable-strategies

Location: `skills/roundtable-strategies/`

**Purpose**: Define facilitation methods

**Structure**:
```
skills/roundtable-strategies/
├── SKILL.md                    # Overview, selection guide
└── references/
    ├── standard.md             # Round-robin
    ├── disney.md               # Dreamer/Realist/Critic
    ├── debate.md               # Pro vs Con
    ├── consensus-driven.md     # Fast convergence
    └── six-hats.md             # De Bono's method
```

**Each strategy defines**:
- Default participation mode
- Phases (if multi-phase)
- Prompt suffixes for each phase
- Consensus policy
- Validation rules

## Data Flow

### Question Generation Flow

```
1. Command builds facilitator input (session state, history)
2. Command calls Task(facilitator)
3. Facilitator returns: { action: "generate_question", question, relevant_participants }
4. Command parses response
```

### Participant Response Flow

```
1. Command builds participant prompts (context, question, synthesis)
2. Command launches Tasks in parallel (for parallel mode)
3. Each participant returns: { position, rationale, confidence }
4. Command collects all responses
```

### Synthesis Flow

```
1. Command builds synthesis input (all responses, history)
2. Command calls Task(facilitator) for synthesis
3. Facilitator returns: { synthesis, new_consensus, new_conflicts, next_action }
4. Command updates session file (batch write)
5. Command evaluates escalation triggers
6. Command proceeds based on next_action
```

## Separation of Concerns

| Component | Decides | Executes |
|-----------|---------|----------|
| Command | When to call agents | Task launching, file I/O |
| Facilitator | What questions, synthesis | Nothing (returns structured data) |
| Participants | Their perspective | Nothing (returns structured data) |
| Strategy Skill | Facilitation method | Nothing (provides prompts) |

**Key Principle**: Facilitator decides, Command executes. Agents don't have side effects.

## Configuration Hierarchy

```
Command line flags
       ↓
.s2s/config.yaml
       ↓
Strategy skill defaults
       ↓
Hardcoded fallbacks
```

---
*See [flow.md](./flow.md) for sequence diagrams*
