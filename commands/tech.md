---
description: Define technical architecture through a roundtable discussion. Reads requirements.md and produces architecture documentation.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(mkdir:*), Bash(date:*), Read, Write, Edit, Glob, Task, AskUserQuestion, TodoWrite
argument-hint: [--skip-roundtable] [--focus components|api|deployment]
---

# Define Technical Architecture

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`
- Current timestamp: !`date -u +"%Y-%m-%dT%H:%M:%SZ"`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"

If S2S is initialized, use Read tool to:
- Read `.s2s/CONTEXT.md` to get project context and phase
- Read `docs/specifications/requirements.md` if exists
- Check existing architecture docs in `docs/architecture/`
- Read `.s2s/state.yaml` for current state

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Check prerequisites

Check if requirements have been defined:

If `docs/specifications/requirements.md` does not exist or is empty:

    Warning: No requirements document found.

    Recommended workflow:
    1. /s2s:discover  - Gather project context
    2. /s2s:specs     - Define requirements
    3. /s2s:tech      - Design architecture (you are here)

    Continue without formal requirements?

Ask user using AskUserQuestion:
- Options: "Continue with CONTEXT.md only" / "Run /s2s:specs first"

### Check for existing architecture

Use Glob to find `docs/architecture/*.md` files.

If architecture docs exist:
- Display summary of existing docs
- Ask user using AskUserQuestion: "Architecture docs exist. What would you like to do?"
  - Options: "Refine existing" / "Start fresh" / "Cancel"

### Parse arguments

Extract from $ARGUMENTS:
- **--skip-roundtable**: Skip discussion, generate from requirements directly
- **--focus**: Focus area for this session
  - `components` - System components and structure
  - `api` - API design and contracts
  - `deployment` - Infrastructure and deployment

### Display context summary

    Starting architecture design...

    Project Context:
    ────────────────
    {from CONTEXT.md}

    Key Requirements:
    ─────────────────
    {list core requirements from requirements.md}

    Constraints:
    ────────────
    {technical constraints from CONTEXT.md}

### Phase 1: Technical Roundtable

If --skip-roundtable is NOT present:

Launch architecture roundtable:

```
Task(
  subagent_type="general-purpose",
  prompt="You are facilitating a Technical Architecture Roundtable.

Project Context:
{CONTEXT.md content}

Requirements:
{requirements.md content or summary}

Participants: software-architect, technical-lead, devops-engineer

Focus: {--focus value or 'full architecture'}

Your task:
1. Analyze requirements and identify architectural concerns:
   - System boundaries and components
   - Data flow and storage
   - Integration points
   - Scalability requirements
   - Security considerations

2. Gather perspectives from each participant:
   - Software Architect: overall structure, patterns, component design
   - Technical Lead: implementation approach, tech stack, code organization
   - DevOps Engineer: deployment, infrastructure, observability

3. For each architectural decision, capture:
   - Decision ID (ARCH-001, etc.)
   - Context (why this decision is needed)
   - Options considered
   - Decision made
   - Rationale
   - Consequences

4. Define:
   - System components and their responsibilities
   - Component interfaces/contracts
   - Technology stack recommendations
   - Deployment topology

5. Identify risks and open questions

Return structured architecture documentation covering:
- System overview
- Component breakdown
- Key decisions
- Deployment view
- Tech stack"
)
```

### Phase 2: User Review

Present architecture decisions:

    Architecture Design Summary:
    ═══════════════════════════

    System Overview:
    {high-level description}

    Components:
    ───────────
    1. {Component 1}: {responsibility}
    2. {Component 2}: {responsibility}
    ...

    Key Decisions:
    ──────────────
    ARCH-001: {decision title}
    Decision: {chosen option}
    Rationale: {why}

    ARCH-002: {decision title}
    ...

    Tech Stack:
    ───────────
    - Backend: {choice}
    - Frontend: {choice}
    - Database: {choice}
    - Infrastructure: {choice}

    Open Questions:
    ───────────────
    - {question 1}

Ask user using AskUserQuestion:
- "Review the architecture above. Would you like to:"
  - Options: "Approve and generate docs" / "Refine decisions" / "Discuss specific area"

### Phase 3: Generate Architecture Documentation

Create/update architecture documents:

**docs/architecture/README.md:**
```markdown
# Architecture Overview

**Project**: {name}
**Version**: 1.0
**Date**: {date}
**Phase**: tech

## System Context

{high-level description of system and its environment}

## Architecture Principles

1. {principle 1}
2. {principle 2}

## Component Overview

| Component | Responsibility | Technology |
|-----------|---------------|------------|
| {name} | {description} | {tech} |

## Key Decisions

See individual ADRs in `/docs/decisions/`

## Documentation Index

- [Components](./components.md) - Detailed component design
- [API Contracts](./api-contracts.md) - Interface definitions
- [Deployment](./deployment.md) - Infrastructure and deployment

---
*Generated by Spec2Ship /s2s:tech*
```

**docs/architecture/components.md:**
```markdown
# Component Design

## {Component 1 Name}

### Responsibility
{what this component does}

### Interfaces
- Input: {what it receives}
- Output: {what it produces}

### Dependencies
- {dependency 1}

### Technology
{stack for this component}

## {Component 2 Name}
...
```

**docs/architecture/deployment.md:**
```markdown
# Deployment Architecture

## Overview
{deployment approach}

## Environments
| Environment | Purpose | Infrastructure |
|-------------|---------|----------------|
| Development | Local dev | {description} |
| Staging | Testing | {description} |
| Production | Live | {description} |

## Infrastructure Components
{from DevOps perspective}

## Deployment Process
{high-level deployment flow}
```

### Phase 4: Generate ADRs

For each architectural decision, create an ADR in `docs/decisions/`:

```markdown
# ARCH-{NNN}: {Title}

**Status**: accepted
**Date**: {date}
**Participants**: {roundtable participants}

## Context
{why this decision was needed}

## Decision
{what was decided}

## Options Considered

### Option 1: {name}
- Pros: {list}
- Cons: {list}

### Option 2: {name}
- Pros: {list}
- Cons: {list}

## Consequences

### Positive
- {benefit}

### Negative
- {trade-off}

## References
- {related decisions or documents}
```

### Phase 5: Update CONTEXT.md

Update `.s2s/CONTEXT.md`:
- Update phase from "specs" to "tech"
- Add Technical Stack section with chosen technologies
- Update "Last updated" date

### Phase 6: Output Summary

    Architecture defined successfully!

    Documents created:
    - docs/architecture/README.md
    - docs/architecture/components.md
    - docs/architecture/deployment.md
    - docs/decisions/ARCH-*.md ({count} decisions)

    Tech Stack:
    {summary of chosen technologies}

    Project phase: tech (ready for implementation)

    Next steps:

    Create implementation plans:
      /s2s:plan:new "feature name"

    Or generate all plans at once:
      /s2s:impl
