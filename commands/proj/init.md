---
description: Initialize a Spec2Ship project. Use --workspace for parent directory, --workspace-hub for stack repo, --component to link to workspace.
---

# Initialize Spec2Ship Project

Initialize s2s in the current directory.

## Arguments

- (no args): Initialize as standalone project
- `--workspace`: Initialize parent directory as workspace
- `--workspace-hub`: Initialize current repo as workspace hub (stack pattern)
- `--component`: Initialize as component linking to existing workspace

## Instructions

### For Standalone Project (no flags)

1. **Check for existing init**: If `.s2s/` exists, warn and ask to reinitialize

2. **Check git**: If not a git repo, suggest `git init`

3. **Create directory structure**:
   - `.s2s/config.yaml`
   - `.s2s/CONTEXT.md`
   - `.s2s/plans/`
   - `docs/architecture/` (with README.md, components.md, glossary.md)
   - `docs/specifications/` (with requirements.md)
   - `docs/specifications/api/` (with README.md)
   - `docs/decisions/` (with README.md containing MADR template)
   - `docs/guides/` (with development.md, testing.md, deployment.md)
   - `CLAUDE.md`

4. **Create config.yaml**:
   ```yaml
   name: "{directory-name}"
   type: "standalone"
   version: "0.1.0"
   git:
     branch_convention: "feature/F{id}-{slug}"
     commit_convention: "conventional"
   roundtable:
     default_participants:
       - software-architect
       - technical-lead
     strategy: "round-robin"
   ```

5. **Create CLAUDE.md**: Import `.s2s/CONTEXT.md`

6. **Output**: Confirm what was created and show next steps

### For Workspace (--workspace)

1. Create in current directory:
   - `.s2s/workspace.yaml` with `type: "workspace"`
   - `.s2s/components.yaml`
   - `.s2s/CONTEXT.md`
   - `docs/` structure

2. Detect git repos in subdirectories and list them for components.yaml

### For Workspace Hub (--workspace-hub)

1. Same as workspace but with `type: "workspace-hub"`
2. Component paths will be relative to parent (`../component-name`)

### For Component (--component)

1. Detect workspace:
   - Check parent for `.s2s/workspace.yaml`
   - Check siblings for workspace-hub

2. Create minimal structure:
   - `.s2s/component.yaml` with workspace path
   - `.s2s/plans/`
   - `CLAUDE.md` importing workspace context
