---
description: Discover project context by analyzing existing files and gathering requirements from the user. Creates or updates CONTEXT.md.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(date:*), Read, Write, Edit, Glob, Grep, AskUserQuestion, TodoWrite
argument-hint: [--refresh]
---

# Discover Project Context

## Context

- Current directory: !`pwd`
- Directory contents: !`ls -la`
- Current date: !`date -u +"%Y-%m-%dT%H:%M:%SZ"`

## Interpret Context

Based on the context output above, determine:

- **S2S initialized**: If `.s2s` directory appears in Directory contents → "yes", otherwise → "NOT_S2S"
- **Directory name**: Extract the last segment from the pwd output

If S2S is initialized, use Read tool to:
- Check if `.s2s/CONTEXT.md` exists and read its content
- Determine if this is a refresh (CONTEXT.md already has content beyond template)

## Instructions

### Validate environment

If S2S initialized is "NOT_S2S", display this message and stop:

    Error: Not an s2s project. Run /s2s:proj:init first.

### Check for existing context

If `.s2s/CONTEXT.md` exists and has project-specific content:
- If $ARGUMENTS contains `--refresh`:
  - Inform user that existing context will be updated
  - Continue with discovery
- If $ARGUMENTS does NOT contain `--refresh`:
  - Display current context summary
  - Ask user using AskUserQuestion: "Update existing context or keep current?"
  - If user wants to keep current, stop execution

### Phase 1: Analyze Existing Project

Scan the project for existing documentation and configuration:

1. **README files**: Use Glob to find `README.md`, `README.txt`, `readme.*`
   - If found, read and extract: project description, features, tech stack mentions

2. **Package/Config files**: Use Glob to find:
   - `package.json` (Node.js) → extract name, description, dependencies
   - `Cargo.toml` (Rust) → extract name, description
   - `pyproject.toml`, `setup.py` (Python) → extract name, description
   - `go.mod` (Go) → extract module name
   - `pom.xml`, `build.gradle` (Java) → extract project info
   - `*.csproj` (C#/.NET) → extract project info

3. **Existing docs**: Use Glob to find `docs/**/*.md`
   - Scan for architecture docs, requirements, API specs

4. **Source structure**: Use Glob to find main source directories
   - `src/`, `lib/`, `app/`, `cmd/`, `pkg/`
   - Infer project type from structure

Store all findings as **Discovered Info**.

### Phase 2: Gather User Input

Present discovered information to user and gather additional context.

#### Step 2.1: Confirm/Refine Overview

Display what was discovered:
- Project name (from config or directory name)
- Description (from README or config)
- Detected tech stack

Ask user using AskUserQuestion:
- "Is this description accurate? Would you like to refine it?"
- Options: "Yes, it's accurate" / "Let me provide a better description"

If user wants to refine, ask for their description.

#### Step 2.2: Business Domain

Ask user using AskUserQuestion:
- "What is the business domain or context for this project?"
- Options with examples:
  - "E-commerce / Retail"
  - "Developer Tools / DevOps"
  - "Data / Analytics"
  - "Other (let me describe)"

#### Step 2.3: Objectives

Ask user using AskUserQuestion:
- "What are the main objectives of this project? (Select all that apply)"
- Options (multiSelect: true):
  - "New product/feature development"
  - "Modernization/refactoring of existing system"
  - "Performance optimization"
  - "Adding new capabilities to existing product"

Follow up with free-form: "Briefly describe the specific goals:"

#### Step 2.4: Scope

Ask user using AskUserQuestion:
- "Is this an MVP or full implementation?"
- Options:
  - "MVP - minimal viable product, speed over completeness"
  - "Full implementation - complete feature set"
  - "Proof of concept - experimental, may be discarded"

Ask follow-up: "What is explicitly OUT of scope for this project?"

#### Step 2.5: Constraints

Ask user using AskUserQuestion:
- "Are there any technical constraints? (Select all that apply)"
- Options (multiSelect: true):
  - "Must use specific tech stack"
  - "Must integrate with existing systems"
  - "Performance requirements (latency, throughput)"
  - "Security/compliance requirements"
  - "No significant constraints"

If constraints selected, ask for details.

### Phase 3: Generate CONTEXT.md

Create or update `.s2s/CONTEXT.md` with the gathered information:

```markdown
# Project Context

## Overview

{Project description - 2-3 sentences combining discovered and user input}

## Business Domain

{Domain from user input}

## Objectives

{Objectives from user input, as bullet points}

## Scope

**Type**: {MVP | Full Implementation | Proof of Concept}

**In scope**:
- {inferred from objectives and user input}

**Out of scope**:
- {from user input}

## Constraints

{Constraints from user input, or "No significant constraints identified."}

## Technical Stack

{Detected stack from Phase 1, or "To be determined in /s2s:tech phase."}

## Open Questions

- {Any ambiguities or decisions to be made}

---
*Last updated: {current date}*
*Phase: discover*
```

### Phase 4: Suggest Next Steps

Based on the gathered information, suggest appropriate next steps:

**If project is simple (MVP/PoC, clear scope, no complex requirements)**:

    Context saved to .s2s/CONTEXT.md

    Your project context has been captured. Based on the scope, you can:

    Quick task or feature:
      /s2s:plan:new "feature name"

    Need more detailed requirements:
      /s2s:specs

**If project is complex (full implementation, unclear scope, multiple objectives)**:

    Context saved to .s2s/CONTEXT.md

    Your project context has been captured. Recommended next steps:

    1. Define detailed requirements:
       /s2s:specs

    2. Then design technical architecture:
       /s2s:tech

    3. Finally, create implementation plans:
       /s2s:plan:new "feature name"

### Output Summary

Display final summary:

    Discovery complete!

    Project: {name}
    Domain: {domain}
    Type: {MVP/Full/PoC}
    Phase: discover

    Context saved to: .s2s/CONTEXT.md

    {Next steps based on complexity}
