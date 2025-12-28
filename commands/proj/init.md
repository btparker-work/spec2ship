---
description: Initialize a Spec2Ship project. Use --workspace for parent directory, --workspace-hub for stack repo, --component to link to workspace.
allowed-tools: Bash(mkdir:*), Bash(git:*), Bash(ls:*), Read, Write, Glob, Grep, TodoWrite, AskUserQuestion
argument-hint: [--workspace | --workspace-hub | --component]
---

# Initialize Spec2Ship Project

## Context

- Current directory: !`basename "$(pwd)"`
- Is git repo: !`[ -d ".git" ] && echo "yes" || echo "no"`
- S2S already initialized: !`[ -d ".s2s" ] && echo "yes" || echo "no"`
- Parent has workspace: !`[ -f "../.s2s/workspace.yaml" ] && echo "yes" || echo "no"`
- Subdirectories with git: !`for d in */; do [ -d "$d/.git" ] && echo "$d"; done 2>/dev/null | tr -d '/' | head -5 || echo "none"`

## Instructions

### Parse arguments

Check $ARGUMENTS for mode:
- **(no flags)**: Initialize as standalone project
- **--workspace**: Initialize parent directory as workspace
- **--workspace-hub**: Initialize current repo as workspace hub
- **--component**: Initialize as component linking to workspace

### Check existing initialization

If S2S already initialized is "yes":
- Warn user that .s2s/ already exists
- Ask if they want to reinitialize using AskUserQuestion
- If no, stop

### Mode: Standalone Project (no flags)

If not a git repo, suggest running "git init" first but allow continuing.

Create this structure using Write and Bash mkdir:

    .s2s/
    ├── config.yaml
    ├── CONTEXT.md
    ├── plans/
    └── state.yaml

    docs/
    ├── architecture/
    │   ├── README.md
    │   ├── components.md
    │   └── glossary.md
    ├── specifications/
    │   ├── requirements.md
    │   └── api/
    │       └── README.md
    ├── decisions/
    │   └── README.md
    └── guides/
        ├── development.md
        ├── testing.md
        └── deployment.md

    CLAUDE.md

**config.yaml** content:

    name: "{directory-name}"
    type: "standalone"
    version: "0.1.0"

    git:
      branch_convention: "feature/F{id}-{slug}"
      commit_convention: "conventional"
      default_branch: "main"

    roundtable:
      default_participants:
        - software-architect
        - technical-lead
      strategy: "round-robin"

**state.yaml** content:

    current_plan: null
    plans: {}
    last_sync: null

**CONTEXT.md**: Import from plugin templates or create with project overview.

**CLAUDE.md** content:

    # {Project Name}

    @.s2s/CONTEXT.md

**docs/**: Use templates from plugin or create minimal stubs.

### Mode: Workspace (--workspace)

Create in current directory:

    .s2s/
    ├── workspace.yaml
    ├── components.yaml
    ├── CONTEXT.md
    ├── plans/
    ├── sessions/
    └── state.yaml

    docs/
    └── (same structure as standalone)

**workspace.yaml** content:

    name: "{directory-name}"
    type: "workspace"

    shared_docs:
      path: "./docs"

    git:
      branch_convention: "feature/F{id}-{slug}"
      commit_convention: "conventional"

**components.yaml**: List detected git repos from context as comments.

### Mode: Workspace Hub (--workspace-hub)

Same as workspace but:
- type: "workspace-hub" in workspace.yaml
- Component paths use "../" prefix

### Mode: Component (--component)

If parent has workspace is "no":
- Search sibling directories for workspace-hub
- If not found, ask user for workspace path

Create minimal structure:

    .s2s/
    ├── component.yaml
    └── plans/

    CLAUDE.md

**component.yaml** content:

    name: "{directory-name}"
    workspace:
      type: "{parent-directory | peer-repo}"
      path: "{relative-path-to-workspace}"

**CLAUDE.md** content referencing workspace context.

### Confirm before creating

Present summary of what will be created and ask for confirmation.

### Output

Display confirmation:

    Spec2Ship initialized successfully!

    Type: {standalone | workspace | workspace-hub | component}
    Config: .s2s/{config|workspace|component}.yaml
    Context: .s2s/CONTEXT.md
    Docs: docs/

    Next steps:
    - Review configuration in .s2s/*.yaml
    - Define requirements in docs/specifications/requirements.md
    - Start planning: /s2s:plan:new "feature name"
