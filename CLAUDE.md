# Spec2Ship Development Context

This is the Spec2Ship (s2s) plugin repository - an AI-assisted development framework for Claude Code.

## Project Structure

```
spec2ship/
├── .claude-plugin/          # Plugin manifest files
├── commands/                # Slash commands (/s2s:*)
├── agents/                  # Roundtable agent personas
├── skills/                  # Core skills
├── templates/               # Project/workspace templates
└── docs/                    # User documentation
```

## Development Guidelines

### Command Writing Best Practices

Commands are instructions FOR Claude, not scripts to execute. Follow these conventions:

#### 1. Frontmatter Format

```yaml
---
description: Clear, concise description of what the command does
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep"]
argument-hint: "required-arg" [--optional-flag]
---
```

- `allowed-tools`: Use JSON array format (Anthropic standard)
- `argument-hint`: Show usage pattern with required args first

#### 2. Phase Structure with Goals

Organize commands in phases, each with a clear goal:

```markdown
## Phase 1: Validation
**Goal**: Ensure we're in a valid environment

**Actions**:
1. Check for required files
2. Validate prerequisites
```

#### 3. Abstract Instructions (Not Platform-Specific Scripts)

Write instructions that Claude interprets, not bash scripts to copy:

**Avoid**:
```bash
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
```

**Prefer**:
```markdown
Generate identifiers:
1. Timestamp: YYYYMMDD-HHMMSS format (current local time)
2. Slug: lowercase, spaces to hyphens, max 50 chars
3. Plan ID: {timestamp}-{slug}
```

#### 4. User Confirmation Gates

Add explicit confirmation points before destructive or significant operations:

```markdown
## Phase N: Confirmation
**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

Present summary of changes and ask for confirmation.
```

#### 5. Reference Variables

- `$ARGUMENTS`: User-provided arguments to the command
- `${CLAUDE_PLUGIN_ROOT}`: Plugin installation directory (for templates)

#### 6. TodoWrite for Complex Operations

For commands with multiple steps, instruct Claude to use TodoWrite:

```markdown
## Core Principles
- Use TodoWrite to track progress through phases
```

#### 7. Output Format

Always end with a clear output section:

```markdown
## Output
Present to user:
- What was created/modified
- Current state
- Suggested next steps
```

### Cross-Platform Compatibility

- Commands run on macOS, Linux, and Windows (via Git Bash/WSL/native)
- Write abstract instructions; Claude adapts to the platform
- Avoid platform-specific syntax in examples
- Use tool names (Read, Write, Bash) not shell commands (cat, echo)

## Architecture Decisions

### AD-001: Command Format
- **Decision**: Use JSON array for `allowed-tools`
- **Rationale**: Matches Anthropic official examples, avoids parsing ambiguity
- **Example**: `allowed-tools: ["Bash", "Read", "Write"]`

### AD-002: Instruction Style
- **Decision**: Write abstract instructions, not literal bash scripts
- **Rationale**: Cross-platform compatibility, clearer intent for Claude
- **Example**: "Create directory if not exists" vs `mkdir -p .s2s/plans`

### AD-003: Phase Structure
- **Decision**: Organize commands in numbered phases with explicit goals
- **Rationale**: Matches Anthropic's feature-dev pattern, improves readability

### AD-004: User Confirmation
- **Decision**: Require confirmation before git operations and file creation
- **Rationale**: Safety, user control, matches "plan → approve → apply" pattern

### AD-005: File Naming
- **Decision**: Timestamp-based naming YYYYMMDD-HHMMSS-slug.md
- **Rationale**: No collisions, natural sorting, unique IDs

### AD-006: Git Workflow
- **Decision**: Branch naming `feature/F{NN}-{slug}`
- **Rationale**: Numbered for easy reference, descriptive slug

## References

- [Anthropic Plugin Dev](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev)
- [Feature Dev Command](https://github.com/anthropics/claude-code/blob/main/plugins/feature-dev/commands/feature-dev.md)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
