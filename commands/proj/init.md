---
description: Initialize a Spec2Ship project. Use --workspace for parent directory, --workspace-hub for stack repo, --component to link to workspace.
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "TodoWrite", "AskUserQuestion"]
argument-hint: [--workspace | --workspace-hub | --component]
---

# Initialize Spec2Ship Project

Initialize s2s in the current directory with the appropriate structure.

## Core Principles

- Use TodoWrite to track progress through phases
- Ask for user confirmation before creating files
- Provide clear feedback on what was created

## Arguments

Parse `$ARGUMENTS` for initialization mode:
- (no flags): Standalone project
- `--workspace`: Parent directory workspace (contains multiple repos)
- `--workspace-hub`: Stack repo pattern (this repo is the hub)
- `--component`: Component linking to existing workspace

---

## Phase 1: Detection
**Goal**: Understand current environment and determine initialization mode

**Actions**:
1. Parse `$ARGUMENTS` to determine mode (standalone/workspace/workspace-hub/component)
2. Check if `.s2s/` directory already exists
   - If exists: warn user and ask if they want to reinitialize
3. Check if current directory is a git repository
   - If not a git repo AND mode is not `--workspace`: suggest running `git init` first
4. Get project name from directory name (or ask user if unclear)

---

## Phase 2: Validation
**Goal**: Ensure prerequisites are met for the chosen mode

**For Standalone** (no flags):
- Verify git repo exists (or user confirms to proceed without)

**For Workspace** (`--workspace`):
- Verify running from parent directory containing repos
- Detect git repositories in subdirectories

**For Workspace Hub** (`--workspace-hub`):
- Verify current directory IS a git repo
- Will reference sibling repos with `../` paths

**For Component** (`--component`):
- Search for workspace:
  - Check parent directory for `.s2s/workspace.yaml`
  - Check sibling directories for workspace-hub type
- If not found: ask user for workspace path

---

## Phase 3: Confirmation
**Goal**: Get user approval before creating files

**WAIT FOR USER APPROVAL BEFORE PROCEEDING**

Present to user:
- Detected mode: {standalone | workspace | workspace-hub | component}
- Project/workspace name: {name}
- Files and directories that will be created
- For component: workspace path that will be linked

Ask: "Proceed with initialization?"

---

## Phase 4: Create Structure
**Goal**: Generate all required files and directories

### For Standalone Project

Create directory structure:
```
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
```

**config.yaml** content:
```yaml
name: "{project-name}"
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
```

**state.yaml** content:
```yaml
current_plan: null
plans: {}
last_sync: null
```

**CONTEXT.md**: Load from `${CLAUDE_PLUGIN_ROOT}/templates/project/CONTEXT.md`

**CLAUDE.md** content:
```markdown
# {Project Name}

@.s2s/CONTEXT.md
```

**docs/**: Copy templates from `${CLAUDE_PLUGIN_ROOT}/templates/docs/`

### For Workspace

Create directory structure:
```
.s2s/
├── workspace.yaml
├── components.yaml
├── CONTEXT.md
├── plans/
├── sessions/
└── state.yaml

docs/
└── (same structure as standalone)
```

**workspace.yaml** content:
```yaml
name: "{workspace-name}"
type: "workspace"

shared_docs:
  path: "./docs"

git:
  branch_convention: "feature/F{id}-{slug}"
  commit_convention: "conventional"

roundtable:
  default_scope: "workspace"
  default_participants:
    - software-architect
    - technical-lead
  strategy: "round-robin"
```

**components.yaml**: List detected git repos in subdirectories:
```yaml
components: []
# Detected repos:
# - {list detected subdirectories that are git repos}
# Add with: /s2s:proj:add-component
```

### For Workspace Hub

Same as workspace but:
- `type: "workspace-hub"` in workspace.yaml
- Component paths use `../` prefix (peer repos)

### For Component

Create minimal structure:
```
.s2s/
├── component.yaml
└── plans/

CLAUDE.md
```

**component.yaml** content:
```yaml
name: "{component-name}"
workspace:
  type: "{parent-directory | peer-repo}"
  path: "{relative-path-to-workspace}"
```

**CLAUDE.md** content:
```markdown
# {Component Name}

## Workspace Context
@{workspace-path}/.s2s/CONTEXT.md

## Component Plans
@.s2s/plans/
```

---

## Phase 5: Verification
**Goal**: Confirm successful initialization

**Actions**:
1. Verify all expected files were created
2. Read back config file to confirm content is valid YAML

---

## Output

Present to user:

```
Spec2Ship initialized successfully!

Type: {type}
Config: .s2s/{config|workspace|component}.yaml
Context: .s2s/CONTEXT.md
Docs: docs/

Next steps:
{for standalone/workspace}
- Review configuration in .s2s/*.yaml
- Define requirements in docs/specifications/requirements.md
- Start planning: /s2s:plan:new "feature name"

{for component}
- Review component.yaml
- Workspace linked at: {workspace-path}
- Start planning: /s2s:plan:new "feature name"
```

---

## Error Handling

- **Directory not empty**: Warn but allow (s2s files won't overwrite existing docs/)
- **Git not initialized**: Suggest `git init` but don't block for workspace mode
- **Workspace not found** (for --component): Ask user to provide path or init workspace first
- **Permission denied**: Report specific file/directory that failed
