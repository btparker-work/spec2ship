# Spec2Ship (s2s)

AI-assisted development framework for the full software lifecycle — from specifications to shipping.

## Overview

Spec2Ship automates software development workflows using Claude Code:

- **Discover**: Understand requirements through guided exploration
- **Spec**: Define requirements and architecture via multi-agent roundtable discussions
- **Plan**: Create structured implementation plans
- **Ship**: Execute plans with automated git workflows

## Features

- **Workflow-Driven Development**: Structured phases from discovery to implementation
- **Roundtable Discussions**: Multi-agent discussions with 5 facilitation strategies
- **Implementation Plans**: Single-file plans that reference global specs
- **Multi-Repo Support**: Workspace and component coordination across repositories
- **Standards-Based**: Templates based on arc42, ISO 25010, MADR

## Installation

```bash
# Add marketplace
/plugin marketplace add spec2ship/spec2ship

# Install plugin
/plugin install s2s
```

## Workflow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ discover│ ─► │  specs  │ ─► │  tech   │ ─► │  impl   │
│         │    │         │    │         │    │         │
│ Explore │    │ Define  │    │ Design  │    │ Execute │
│ problem │    │ what    │    │ how     │    │ plan    │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

## Quick Start

```bash
# 1. Initialize a new project
/s2s:proj:init

# 2. Discover requirements (explore the problem space)
/s2s:discover "user authentication for our web app"

# 3. Define specifications (what to build)
/s2s:specs "user authentication requirements"

# 4. Design technical approach (how to build)
/s2s:tech "authentication implementation architecture"

# 5. Create implementation plan
/s2s:plan:new "implement user authentication" --branch

# 6. Start working on the plan
/s2s:plan:start "20240115-143022-implement-user-authentication"

# 7. Complete the plan
/s2s:plan:complete
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/s2s:discover "topic"` | Explore problem space, gather requirements |
| `/s2s:specs "topic"` | Define specifications via roundtable |
| `/s2s:tech "topic"` | Design technical architecture via roundtable |
| `/s2s:impl "topic"` | Implementation guidance and execution |

### Project Management

| Command | Description |
|---------|-------------|
| `/s2s:proj:init` | Initialize project |
| `/s2s:proj:init --workspace` | Initialize workspace |
| `/s2s:proj:init --component` | Initialize component |

### Implementation Plans

| Command | Description |
|---------|-------------|
| `/s2s:plan:new "topic"` | Create plan |
| `/s2s:plan:new "topic" --branch` | Create plan with feature branch |
| `/s2s:plan:start "id"` | Start plan |
| `/s2s:plan:complete` | Complete plan |
| `/s2s:plan:list` | List plans |

### Roundtable

| Command | Description |
|---------|-------------|
| `/s2s:roundtable:start "topic"` | Start discussion |
| `/s2s:roundtable:start "topic" --strategy disney` | Start with specific strategy |
| `/s2s:roundtable:list` | List sessions |
| `/s2s:roundtable:resume "id"` | Resume session |

### Roundtable Strategies

| Strategy | Phases | Best For |
|----------|--------|----------|
| `standard` | 1 | General discussions |
| `disney` | 3 (dreamer, realist, critic) | Creative solutions |
| `debate` | 3 (opening, rebuttal, closing) | Option evaluation |
| `consensus-driven` | 3 | Fast decisions |
| `six-hats` | 7 | Comprehensive analysis |

## Documentation

- [Roundtable Overview](docs/roundtable/README.md)
- [Configuration Guide](docs/roundtable/configuration.md)
- [Strategy Reference](docs/roundtable/strategies/overview.md)
- [Architecture](docs/roundtable/architecture/components.md)

## License

MIT License - see [LICENSE](LICENSE)
