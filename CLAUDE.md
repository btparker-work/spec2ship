# Spec2Ship Development Context

Spec2Ship (s2s) is an AI-assisted development framework plugin for Claude Code. It automates the full software lifecycle: specifications → planning → implementation → shipping.

## Project Structure

```
spec2ship/
├── .claude-plugin/           # Plugin manifest
├── commands/                 # Slash commands (/s2s:*)
│   ├── proj/                 # Project management
│   ├── plan/                 # Implementation plans
│   ├── decision/             # ADRs
│   ├── roundtable/           # Multi-agent discussions
│   └── git/                  # Git operations
├── agents/                   # Specialized sub-agents
│   ├── roundtable/           # Discussion participants
│   ├── exploration/          # Codebase analysis
│   └── validation/           # Quality checks
├── skills/                   # Knowledge bases (progressive disclosure)
│   ├── arc42-templates/      # Architecture patterns
│   ├── iso25010-requirements/# Quality standards
│   ├── madr-decisions/       # ADR format
│   └── conventional-commits/ # Git conventions
├── templates/                # File templates for user projects
└── docs/                     # User documentation
```

---

## Strategic Architecture Decisions

### SAD-001: Component Separation (Commands vs Agents vs Skills)

We follow Anthropic's pattern from `plugin-dev` and `feature-dev`:

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| **Commands** | Workflow orchestration | User-facing operations with phases, confirmations, state |
| **Agents** | Parallel specialized tasks | Isolated analysis, domain expertise, parallelizable work |
| **Skills** | Knowledge on-demand | Standards, patterns, templates loaded when needed |

**Example**:
```
/s2s:roundtable:start "API design"
    │
    ├── Command orchestrates the discussion
    │
    ├── Launches agents in parallel:
    │   ├── software-architect (architecture perspective)
    │   ├── technical-lead (implementation perspective)
    │   └── qa-lead (quality perspective)
    │
    └── Loads skills as needed:
        ├── arc42-templates (for architecture context)
        └── madr-decisions (for ADR format)
```

### SAD-002: Roundtable Implementation

Roundtable is our unique multi-agent discussion system. Pattern:

1. **Facilitator agent** orchestrates the discussion
2. **Domain expert agents** contribute perspectives
3. **Command** manages flow, consensus, and output

```
┌─────────────────────────────────────────────────┐
│  /s2s:roundtable:start "topic"                  │
│                                                 │
│  ┌─────────────┐                                │
│  │ Facilitator │ ◄── Orchestrates turns         │
│  └──────┬──────┘                                │
│         │                                       │
│    ┌────┴────┬────────┬────────┐                │
│    ▼         ▼        ▼        ▼                │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             │
│ │Arch  │ │Tech  │ │QA    │ │DevOps│             │
│ │itect │ │Lead  │ │Lead  │ │Eng   │             │
│ └──────┘ └──────┘ └──────┘ └──────┘             │
│                                                 │
│  Output: Consensus → ADR or Plan                │
└─────────────────────────────────────────────────┘
```

### SAD-003: Agent Tiers

Following wshobson/agents pattern, assign model tiers by complexity:

| Tier | Model | Use Case | Examples |
|------|-------|----------|----------|
| **Critical** | opus | Architecture decisions, security | software-architect, security-reviewer |
| **Complex** | sonnet | Analysis, code review | codebase-analyzer, plan-validator |
| **Fast** | haiku | Simple checks, formatting | spec-formatter, branch-checker |

### SAD-004: Skill Progressive Disclosure

Skills load incrementally to minimize token usage:

```
skills/arc42-templates/
├── SKILL.md              # Always: triggers + overview (< 500 words)
├── references/
│   ├── building-blocks.md   # On-demand: detailed patterns
│   ├── runtime-view.md
│   └── deployment-view.md
└── examples/
    └── sample-component.md  # On-demand: concrete examples
```

### SAD-005: State Management

Use `.s2s/state.yaml` as single source of truth:

```yaml
current_plan: "20241228-143022-user-auth"
current_session: null  # roundtable session ID
plans:
  "20241228-143022-user-auth":
    status: "active"
    branch: "feature/F01-user-auth"
```

---

## Component Writing Guidelines

### Commands

Commands are workflow orchestrators. Structure:

```markdown
---
description: What this command does
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "TodoWrite", "AskUserQuestion", "Task"]
argument-hint: "required" [--optional]
---

# Command Title

Brief description.

## Core Principles
- Use TodoWrite to track progress
- Ask confirmation before significant operations
- Launch agents for parallel analysis

## Arguments
Parse `$ARGUMENTS`: ...

## Phase 1: Validation
**Goal**: Ensure prerequisites are met
**Actions**: ...

## Phase N: Confirmation
**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

## Phase N+1: Execution
**Goal**: Perform the operation
**Actions**:
1. For exploration, launch agents via Task tool
2. Collect results
3. Apply changes

## Output
Present results and next steps.

## Error Handling
- **Error case**: How to handle
```

**Example - Launching agents from command**:
```markdown
## Phase 2: Codebase Exploration
**Goal**: Understand existing code patterns

**Actions**:
1. Launch exploration agents in parallel via Task tool:
   - codebase-analyzer: "Analyze architecture patterns in src/"
   - requirements-mapper: "Map existing features to requirements"
2. Wait for agent results
3. Synthesize findings for user
```

### Agents

Agents are specialized workers. Structure:

```markdown
---
name: agent-name
description: Use this agent when user asks to "trigger phrase 1", "trigger phrase 2", or needs domain-specific analysis.
model: sonnet
color: cyan
tools: ["Read", "Grep", "Glob", "WebFetch"]
---

# Agent Title

## Role
You are a {role} expert specializing in {domain}.

## Responsibilities
1. Responsibility one
2. Responsibility two

## Process
1. Step one
2. Step two

## Output Format
Return findings as:
- Summary (2-3 sentences)
- Key findings (bullet points)
- Recommendations (if applicable)
- Files to review: [list of paths]
```

**Roundtable agent example**:
```markdown
---
name: software-architect
description: Use in roundtable discussions for architecture perspective. Activated by facilitator agent.
model: sonnet
color: blue
tools: ["Read", "Glob", "Grep"]
---

# Software Architect

## Role
You are the Software Architect in a Technical Roundtable discussion.

## Perspective
Focus on:
- System structure and component boundaries
- Integration patterns and APIs
- Scalability and maintainability
- Technical debt implications

## Speaking Style
Technical but accessible. Reference established patterns (arc42, C4, SOLID).

## Contribution Format
1. State your perspective clearly (2-3 sentences)
2. Reference relevant patterns or standards
3. Identify trade-offs explicitly
4. Propose concrete recommendation if appropriate
```

### Skills

Skills are knowledge bases. Structure:

```markdown
---
name: Skill Name
description: This skill provides knowledge about {domain}. Activate when user needs {specific scenarios}.
version: 0.1.0
---

# Skill Name

## Overview
Brief description of what this skill provides.

## Key Concepts
- Concept 1: explanation
- Concept 2: explanation

## Quick Reference
Essential patterns and templates.

## When to Apply
- Scenario 1
- Scenario 2

## References
For detailed information, see:
- `references/detailed-topic.md`
- `examples/sample-usage.md`
```

---

## Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Plan ID | `YYYYMMDD-HHMMSS-slug` | `20241228-143022-user-auth` |
| ADR | `YYYYMMDD-HHMMSS-slug.md` | `20241228-100000-api-versioning.md` |
| Branch | `feature/F{NN}-slug` | `feature/F01-user-auth` |
| Session | `YYYYMMDD-HHMMSS-topic` | `20241228-150000-auth-strategy` |

---

## Implementation Phases

### Phase 1: Core Foundation ✓
- Commands: proj/init, plan/new, plan/list, plan/start, plan/complete
- Templates: project, workspace, docs

### Phase 2: Roundtable + Agents (Current)
- Agents: roundtable/* (facilitator, architect, tech-lead, qa-lead, devops)
- Agents: exploration/* (codebase-analyzer, requirements-mapper)
- Agents: validation/* (plan-validator, spec-validator)
- Commands: roundtable/start, roundtable/resume, roundtable/converge
- Commands: decision/new, decision/list

### Phase 3: Skills + Standards
- Skills: arc42-templates, iso25010-requirements, madr-decisions
- Integration with commands and agents

### Phase 4: Multi-Repo Support
- Commands: git/branch, git/sync, git/pr
- Workspace coordination across components

### Phase 5: Documentation
- User guides, command reference, workflow examples

---

## Code Style

- **Language**: English for code, comments, and documentation
- **Markdown**: GitHub-flavored, CommonMark compatible
- **YAML**: 2-space indent, quoted strings for values with special chars
- **File encoding**: UTF-8, LF line endings

---

## Testing Commands

After changes, test with:
```bash
/plugin marketplace remove spec2ship
/plugin marketplace add https://github.com/spec2ship/spec2ship.git#develop
/plugin install s2s@spec2ship
```

---

## References

### Patterns We Follow
- [Anthropic plugin-dev](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) - Commands + Agents + Skills structure
- [Anthropic feature-dev](https://github.com/anthropics/claude-code/tree/main/plugins/feature-dev) - Agent parallelism pattern
- [wshobson/agents](https://github.com/wshobson/agents) - Tiered agent architecture
- [ContextKit](https://github.com/FlineDev/ContextKit) - Workflow phases pattern

### Standards We Implement
- arc42 for architecture documentation
- ISO 25010 for quality requirements
- MADR for architecture decisions
- Conventional Commits for git messages
