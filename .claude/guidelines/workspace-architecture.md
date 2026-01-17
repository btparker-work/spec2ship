# Workspace Architecture

This document defines how Spec2Ship supports multi-component projects (workspaces) in addition to standalone projects.

**Detailed specification**: `.s2s/specs/WORK-001-workspace-specification.md`

---

## Terminology

| Term | Definition |
|------|------------|
| **Workspace** | Configuration that coordinates multiple related projects |
| **Component** | A project that is part of a workspace |
| **Standalone** | A single project not part of any workspace |
| **Monorepo** | Workspace where all components share ONE git repo |
| **Multi-repo** | Workspace where components have SEPARATE git repos |

---

## Supported Structures

### Monorepo

All components in one git repository.

```
workspace/
├── .git/                    # Single git repo
├── .s2s/                    # Workspace-level S2S
│   ├── workspace.yaml       # Component registry
│   ├── config.yaml
│   ├── CONTEXT.md
│   └── ...
├── frontend/
│   └── .s2s/                # Component-level S2S
├── backend/
│   └── .s2s/
└── shared-lib/
    └── .s2s/
```

### Multi-repo

Components in separate git repositories.

```
parent-folder/               # NO .git here
├── system-docs/             # Dedicated docs project
│   ├── .git/                # Own git repo for workspace docs
│   └── .s2s/                # Workspace-level S2S
│       └── workspace.yaml
├── frontend/
│   ├── .git/                # Own git repo
│   └── .s2s/
├── backend/
│   ├── .git/
│   └── .s2s/
└── shared-lib/
    ├── .git/
    └── .s2s/
```

### Hybrid

Some components share parent repo, others have own repos.

---

## Reference Patterns

**Key distinction**:
- **Internal** (`.s2s/` files): ALWAYS use relative paths
- **External** (`docs/` public files): ALWAYS use absolute URLs

| Context | Pattern | Example |
|---------|---------|---------|
| Internal | Relative `@` | `@../backend/.s2s/CONTEXT.md` |
| External | Absolute URL | `[Backend](https://github.com/org/backend/docs/)` |

**Rationale**: Local filesystem structure is predictable (parent + subfolders). Public docs need URLs that work when published anywhere.

---

## Configuration Files

### workspace.yaml

Located at workspace root: `.s2s/workspace.yaml`

Contains:
- Component registry with paths and dependencies
- Cross-cutting concerns (decisions affecting multiple components)
- Roundtable scope configuration

See specification Section 3.1 for full schema.

### Component config.yaml

When a project is part of a workspace:

```yaml
name: "frontend"
type: "component"            # NOT "standalone"

workspace:
  path: ".."                 # Relative path to workspace root
```

---

## Init Behavior

Init is ALWAYS interactive - it detects context and guides the user.

### Key Scenarios

1. **New standalone**: Simple project, no workspace indicators → create .s2s/
2. **New workspace** (`--workspace`): Create workspace.yaml, optionally init components
3. **Detected workspace**: Multiple subfolders found → suggest workspace structure
4. **Adding component**: Parent has workspace.yaml → link as component
5. **Convert to workspace**: Existing standalone → add workspace.yaml

### Dependency Detection

- Only detects dependencies between WORKSPACE COMPONENTS (not third-party libs)
- If uncertain, asks user for confirmation
- No separate command needed - init handles interactively

---

## Versioning

### Always Version (commit to git)

| File | Purpose |
|------|---------|
| `workspace.yaml` | Workspace configuration |
| `config.yaml` | Project configuration |
| `CONTEXT.md` | Context and overview |
| `BACKLOG.md` | Planned work |
| `decisions/` | ADRs |
| `plans/` | Implementation plans |

### Never Version (add to .gitignore)

| File | Reason |
|------|--------|
| `sessions/` | Volatile, large |

---

## Roundtable Scope

Facilitator uses **decision principles** (not topic lists) to determine appropriate scope.

**Workspace-level principle**:
> Does this decision require coordination between teams?

**Component-level principle**:
> Does this affect only this component's implementation?

If topic doesn't match scope, facilitator suggests running from the appropriate location.

---

*Last updated: 2026-01-17*
*See also: `.s2s/specs/WORK-001-workspace-specification.md`*
