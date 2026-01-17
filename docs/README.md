# Spec2Ship Documentation

Spec2Ship is a Claude Code plugin that automates the software development lifecycle: from specifications through planning, implementation, and shipping.

> **Interactive Help**: For detailed questions about s2s, ask Claude directly:
> - "what is s2s" / "how do I use specs" / "which command for..."
> - "how to create custom agent" / "extend s2s"
>
> This activates the `s2s-guide` skill with comprehensive reference material.

## Quick Start

```bash
# Install the plugin
/plugin marketplace add https://github.com/spec2ship/spec2ship.git
/plugin install s2s@spec2ship

# Initialize a project
/s2s:init

# Define requirements
/s2s:specs

# Design architecture
/s2s:design

# Create implementation plan
/s2s:plan --new "feature-name"
```

**Detailed setup**: See [Getting Started](./getting-started.md)

## Core Workflow

```
/s2s:init → /s2s:specs → /s2s:design → /s2s:plan → Implementation
  Setup      Define        Design        Plan         Build
             WHAT          HOW           STEPS
```

Each phase uses a **roundtable** - multiple AI agents with different perspectives discuss and produce artifacts.

## Key Features

- **AI Roundtables**: Multiple AI agents discuss and debate
- **Anti-Sycophancy**: Agents designed to disagree constructively
- **Session Persistence**: Resume discussions anytime
- **Multiple Strategies**: Disney (creative), Debate, Consensus-Driven, Six Hats
- **Extensible**: Add custom agents, skills, and strategies

## Documentation

### For Users

| Guide | Description |
|-------|-------------|
| [Getting Started](./getting-started.md) | Installation and first project |
| [Concepts](./concepts/) | Core concepts overview |

### For Contributors

| Guide | Description |
|-------|-------------|
| [Architecture](./architecture/) | System architecture and decisions |

### Interactive Help (via Claude)

For detailed reference, ask Claude:
- **Commands**: "what commands does s2s have"
- **Workflows**: "how do I use specs vs design"
- **Extension**: "how to create a new agent"
- **Glossary**: "what is a roundtable in s2s"

---

*Spec2Ship - From Specs to Ship*
