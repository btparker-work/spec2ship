---
description: Initialize a Spec2Ship project. Use --workspace for parent directory, --workspace-hub for stack repo, --component to link to workspace.
allowed-tools: Bash(pwd:*), Bash(ls:*), Bash(mkdir:*), Bash(git:*), Read, Write, Glob, Grep, TodoWrite, AskUserQuestion
argument-hint: [--workspace | --workspace-hub | --component]
---

# Initialize Spec2Ship Project

## Context

- Current directory: !`pwd`
- Git directory: !`ls -d .git`
- S2S directory: !`ls -d .s2s`
- S2S config: !`ls .s2s/config.yaml`
- S2S workspace: !`ls .s2s/workspace.yaml`
- S2S component: !`ls .s2s/component.yaml`
- Parent workspace: !`ls ../.s2s/workspace.yaml`
- Subdirectories: !`ls -d */`

---

## Interpret Context

Based on the context output above, determine:

- **Directory name**: Extract the last segment from the `pwd` output
- **Is git repo**: If `ls -d .git` succeeded (no error) → "yes", otherwise → "no"
- **S2S already initialized**: If `ls -d .s2s` succeeded → "yes", otherwise → "no"
- **Parent has workspace**: If `ls ../.s2s/workspace.yaml` succeeded → "yes", otherwise → "no"
- **Subdirs with git**: Check which subdirectories have a `.git` folder by examining the Subdirectories output

---

## Phase 1: Determine Mode

Goal: Parse arguments and determine initialization type.

Actions:
1. Check $ARGUMENTS for flags:
   - **(no flags)**: Standalone project
   - **--workspace**: Parent directory workspace
   - **--workspace-hub**: Stack repo as workspace hub
   - **--component**: Component linking to workspace
2. Store the selected mode for subsequent phases.

---

## Phase 2: Validate Environment

Goal: Check prerequisites and handle existing initialization.

Actions:
1. If S2S already initialized is "yes":
   - Warn user that .s2s/ already exists
   - Ask if they want to reinitialize using AskUserQuestion
   - If user declines, stop execution
2. For standalone/workspace modes: if not a git repo, suggest "git init" but allow continuing
3. For component mode: verify workspace can be located (parent or sibling)

---

## Phase 3: Confirm with User

Goal: Present initialization plan and get user approval.

Actions:
1. Display summary of what will be created:
   - Project type (standalone/workspace/workspace-hub/component)
   - Directories to create
   - Files to generate
   - Configuration values
2. Ask for confirmation using AskUserQuestion
3. If user declines, stop execution

---

## Phase 4: Create Structure

Goal: Generate all required files and directories.

Actions:
1. Create directory structure using Bash mkdir
2. Generate configuration files using Write tool
3. Apply mode-specific content (see Mode Specifications below)

---

## Phase 5: Output Results

Goal: Confirm success and guide next steps.

Actions:
1. Display confirmation message with created resources
2. Show relevant next steps based on project type
3. Suggest immediate actions (review config, define requirements, create plan)

---

## Mode Specifications

### Mode: Standalone Project (no flags)

**Structure**:

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

**config.yaml**:

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

**state.yaml**:

    current_plan: null
    plans: {}
    last_sync: null

**CONTEXT.md**: Import from plugin templates or create with project overview.

**CLAUDE.md**:

    # {Project Name}

    @.s2s/CONTEXT.md

**docs/**: Use templates from plugin or create minimal stubs.

### Mode: Workspace (--workspace)

**Structure**:

    .s2s/
    ├── workspace.yaml
    ├── components.yaml
    ├── CONTEXT.md
    ├── plans/
    ├── sessions/
    └── state.yaml

    docs/
    └── (same structure as standalone)

**workspace.yaml**:

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
- If not found, ask user for workspace path using AskUserQuestion

**Structure**:

    .s2s/
    ├── component.yaml
    └── plans/

    CLAUDE.md

**component.yaml**:

    name: "{directory-name}"
    workspace:
      type: "{parent-directory | peer-repo}"
      path: "{relative-path-to-workspace}"

**CLAUDE.md**: Content referencing workspace context.

---

## Output Template

    Spec2Ship initialized successfully!

    Type: {standalone | workspace | workspace-hub | component}
    Config: .s2s/{config|workspace|component}.yaml
    Context: .s2s/CONTEXT.md
    Docs: docs/

    Next steps:
    - Review configuration in .s2s/*.yaml
    - Define requirements in docs/specifications/requirements.md
    - Start planning: /s2s:plan:new "feature name"
