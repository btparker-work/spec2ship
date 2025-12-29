---
description: Define functional requirements through a roundtable discussion. Reads CONTEXT.md and produces structured requirements.md.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(mkdir:*), Bash(date:*), Read, Write, Edit, Glob, Task, AskUserQuestion, TodoWrite
argument-hint: [--skip-roundtable] [--format srs|volere|simple]
---

# Define Functional Requirements

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`
- Current timestamp: !`date -u +"%Y-%m-%dT%H:%M:%SZ"`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"

If S2S is initialized, use Read tool to:
- Read `.s2s/CONTEXT.md` to get project context
- Check if `docs/specifications/requirements.md` already exists
- Read `.s2s/state.yaml` to check current phase

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Check prerequisites

Read `.s2s/CONTEXT.md` and verify it has been populated (not just template).

If CONTEXT.md is still a template (contains placeholder text like "{Project description"):

    Error: Project context not defined.

    Run /s2s:discover first to gather project context,
    then run /s2s:specs to define requirements.

### Check for existing requirements

If `docs/specifications/requirements.md` exists and has content:
- Display current requirements summary
- Ask user using AskUserQuestion: "Requirements already exist. What would you like to do?"
  - Options: "Refine existing requirements" / "Start fresh" / "Cancel"
- If cancel, stop execution
- If start fresh, backup existing file

### Parse arguments

Extract from $ARGUMENTS:
- **--skip-roundtable**: Skip discussion, generate from CONTEXT.md directly
- **--format**: Requirements document format
  - `srs` - IEEE SRS-inspired structure (default)
  - `volere` - Volere template style
  - `simple` - Simple bullet-point list

### Display context summary

Show the user what we're working with:

    Starting requirements definition...

    Project Context:
    ────────────────
    Overview: {from CONTEXT.md}
    Domain: {from CONTEXT.md}
    Scope: {MVP/Full/PoC from CONTEXT.md}

    Objectives:
    {list objectives from CONTEXT.md}

    Constraints:
    {list constraints from CONTEXT.md}

### Phase 1: Gather Initial Requirements

If --skip-roundtable is NOT present:

Launch a roundtable session focused on functional requirements:

```
Task(
  subagent_type="general-purpose",
  prompt="You are facilitating a Requirements Roundtable.

Project Context:
{full CONTEXT.md content}

Participants: product-manager, software-architect, qa-lead

Your task:
1. Based on the project context, identify the key functional areas
2. For each functional area, gather perspectives from participants:
   - Product Manager: user needs, business value, priority
   - Software Architect: feasibility, dependencies, complexity
   - QA Lead: testability, acceptance criteria, edge cases

3. For each requirement, capture:
   - ID (REQ-001, REQ-002, etc.)
   - Title
   - Description (user story format preferred: As a... I want... So that...)
   - Priority (Must/Should/Could/Won't - MoSCoW)
   - Acceptance criteria (testable conditions)
   - Dependencies (other requirements)
   - Notes from discussion

4. Identify:
   - Core requirements (must-have for MVP)
   - Extended requirements (nice-to-have)
   - Out of scope items (explicitly excluded)

5. Flag any conflicts or ambiguities for user resolution

Return a structured list of requirements with all fields populated."
)
```

If --skip-roundtable IS present:
- Analyze CONTEXT.md directly
- Infer requirements from objectives and scope
- Generate basic requirement list

### Phase 2: User Review

Present the gathered requirements to the user:

    Requirements gathered from roundtable:

    Core Requirements (Must Have):
    ─────────────────────────────
    REQ-001: {title}
    {description}
    Priority: Must | Acceptance: {criteria summary}

    REQ-002: {title}
    ...

    Extended Requirements (Should/Could Have):
    ──────────────────────────────────────────
    REQ-003: {title}
    ...

    Questions/Ambiguities:
    ──────────────────────
    - {question 1}
    - {question 2}

Ask user using AskUserQuestion:
- "Review the requirements above. Would you like to:"
  - Options: "Approve and generate document" / "Refine requirements" / "Add more requirements"

If refine or add:
- Gather user input
- Update requirements list
- Show updated list and ask again

### Phase 3: Generate Requirements Document

Create or update `docs/specifications/requirements.md`:

**For SRS format (default):**

```markdown
# Software Requirements Specification

**Project**: {project name}
**Version**: 1.0
**Date**: {current date}
**Phase**: specs

## 1. Introduction

### 1.1 Purpose
{from CONTEXT.md overview}

### 1.2 Scope
{from CONTEXT.md scope}

### 1.3 Definitions and Acronyms
{domain-specific terms from CONTEXT.md}

## 2. Overall Description

### 2.1 Product Perspective
{from CONTEXT.md business domain}

### 2.2 Product Functions
{high-level summary of main functions}

### 2.3 User Classes and Characteristics
{inferred from requirements}

### 2.4 Constraints
{from CONTEXT.md constraints}

### 2.5 Assumptions and Dependencies
{from roundtable discussion}

## 3. Functional Requirements

### 3.1 {Functional Area 1}

#### REQ-001: {Title}
- **Description**: {user story or description}
- **Priority**: {Must/Should/Could/Won't}
- **Rationale**: {why this is needed}
- **Acceptance Criteria**:
  - [ ] {criterion 1}
  - [ ] {criterion 2}
- **Dependencies**: {REQ-xxx or None}

#### REQ-002: {Title}
...

### 3.2 {Functional Area 2}
...

## 4. Non-Functional Requirements

### 4.1 Performance
{if mentioned in constraints}

### 4.2 Security
{if mentioned in constraints}

### 4.3 Usability
{if relevant}

## 5. Out of Scope
{explicit exclusions from CONTEXT.md and roundtable}

---
*Generated by Spec2Ship /s2s:specs*
*Roundtable participants: {list}*
```

**For simple format:**
Use bullet-point structure without IEEE sections.

### Phase 4: Update CONTEXT.md

Update `.s2s/CONTEXT.md`:
- Update phase from "discover" to "specs"
- Add reference to requirements document
- Update "Last updated" date

### Phase 5: Output Summary

Display completion message:

    Requirements defined successfully!

    Document: docs/specifications/requirements.md
    Format: {srs|volere|simple}

    Summary:
    - Core requirements: {count}
    - Extended requirements: {count}
    - Out of scope items: {count}

    Project phase: specs

    Next steps:

    Define technical architecture:
      /s2s:tech

    Or start implementing (skip architecture):
      /s2s:plan:new "feature name"
