# Spec2Ship (s2s)

AI-assisted development framework for the full software lifecycle — from specifications to shipping.

## Overview

Spec2Ship automates software development workflows using Claude Code:

- **Spec**: Define requirements, architecture, and decisions via roundtable discussions
- **Ship**: Execute implementation plans with automated git workflows

## Features

- **Implementation Plans**: Single-file plans that reference global specs
- **Roundtable Discussions**: Multi-agent discussions for architectural decisions
- **Multi-Repo Support**: Workspace and component coordination across repositories
- **Standards-Based**: Templates based on arc42, ISO 25010, MADR
- **Git-Native**: Branch conventions, timestamp naming, no custom locking

## Installation

```bash
# Add marketplace
/plugin marketplace add spec2ship/spec2ship

# Install plugin
/plugin install s2s
```

## Quick Start

```bash
# Initialize a new project
/s2s:proj:init

# Create an implementation plan
/s2s:plan:new "user authentication" --branch

# Start working on the plan
/s2s:plan:start "20240115-143022-user-authentication"

# Complete the plan
/s2s:plan:complete
```

## Commands

### Project Management
- `/s2s:proj:init` - Initialize project
- `/s2s:proj:init --workspace` - Initialize workspace
- `/s2s:proj:init --component` - Initialize component

### Implementation Plans
- `/s2s:plan:new "topic"` - Create plan
- `/s2s:plan:start "id"` - Start plan
- `/s2s:plan:complete` - Complete plan
- `/s2s:plan:list` - List plans

### Decisions (ADRs)
- `/s2s:decision:new "topic"` - Create ADR
- `/s2s:decision:new "topic" --roundtable` - Create via discussion

### Roundtable
- `/s2s:roundtable:start "topic"` - Start discussion
- `/s2s:roundtable:resume` - Resume session
- `/s2s:roundtable:converge` - Force consensus

## Documentation

- [Getting Started](docs/getting-started.md)
- [Commands Reference](docs/commands-reference.md)
- [Multi-Repo Guide](docs/multi-repo-guide.md)
- [Workflows](docs/workflows.md)

## License

MIT License - see [LICENSE](LICENSE)
