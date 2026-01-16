# Workspace Architecture

This document defines how Spec2Ship supports multi-component projects (workspaces) in addition to standalone projects.

---

## Project Types

### Standalone Project

Single project with one git repository and one `.s2s/` folder.

```
my-project/
├── .git/
├── .s2s/              # Single S2S instance
│   ├── config.yaml
│   ├── CONTEXT.md
│   ├── BACKLOG.md
│   ├── requirements.md
│   ├── architecture.md
│   ├── decisions/
│   ├── plans/
│   └── sessions/
└── src/
```

### Workspace (Multi-Component)

Project with multiple sub-projects (components) such as:
- Frontend, Backend, Mobile App
- Core, Ingestion, Analysis modules
- Shared libraries

---

## Workspace Configuration Options

The `.s2s/` folder placement depends on project structure and versioning strategy.

### Option A: Per-Component `.s2s/`

Each component has its own `.s2s/` folder, versioned with the component.

```
workspace/
├── frontend/
│   ├── .git/
│   └── .s2s/          # Frontend-specific
├── backend/
│   ├── .git/
│   └── .s2s/          # Backend-specific
└── mobile/
    ├── .git/
    └── .s2s/          # Mobile-specific
```

**Use when**:
- Each component has its own git repository
- Components evolve independently
- Teams work on separate components

**Advantages**:
- Clear ownership per component
- Versioned with component code
- Independent evolution

**Disadvantages**:
- No central place for cross-component decisions
- Duplication of shared context

---

### Option B: Single `.s2s/` in Parent Folder

One `.s2s/` folder at workspace level, containing all documentation.

```
workspace/
├── .git/              # Single repo (monorepo)
├── .s2s/              # Shared for all components
│   ├── config.yaml
│   ├── CONTEXT.md
│   ├── requirements.md
│   └── ...
├── frontend/
├── backend/
└── mobile/
```

**Use when**:
- Monorepo with single git repository
- Centralized documentation ownership
- Tightly coupled components

**Advantages**:
- Single source of truth
- Easy cross-component references
- No duplication

**Disadvantages**:
- All teams share same documentation
- Harder to version component-specific decisions

---

### Option C: Sibling Folder for System Documentation

Dedicated sibling folder for system-level documentation, with optional component `.s2s/` folders.

```
workspace/
├── docs-system/           # Sibling folder for system-level docs
│   ├── .git/              # Separate repo for docs
│   └── .s2s/              # High-level architecture, cross-component decisions
│       ├── CONTEXT.md     # System overview
│       ├── architecture.md # System architecture
│       └── decisions/     # Cross-component ADRs
├── frontend/
│   ├── .git/
│   └── .s2s/              # Frontend details (optional)
├── backend/
│   ├── .git/
│   └── .s2s/              # Backend details (optional)
└── mobile/
    ├── .git/
    └── .s2s/              # Mobile details (optional)
```

**Use when**:
- Separate repos per component
- Need for cross-component roundtables and decisions
- Want system-level documentation versioned separately

**Advantages**:
- System-level docs are versionable and shareable
- Component details remain with component code
- Clear separation of concerns

**Disadvantages**:
- More complex structure
- Need to manage references between system and component docs

---

### Option D: Hybrid (Recommended for Complex Projects)

Sibling folder for high-level documentation with references to component `.s2s/` folders.

```
workspace/
├── system-docs/
│   ├── .git/
│   └── .s2s/
│       ├── CONTEXT.md        # System overview, component list
│       ├── architecture.md   # High-level architecture only
│       ├── decisions/        # Cross-component ADRs only
│       └── COMPONENTS.md     # Links to component docs (via repo URLs)
├── frontend/
│   ├── .git/
│   └── .s2s/
│       └── ...               # Detailed frontend specs, architecture
├── backend/
│   └── ...
└── mobile/
    └── ...
```

**COMPONENTS.md structure**:
```markdown
# Components

| Component | Repo | Documentation |
|-----------|------|---------------|
| Frontend | https://github.com/org/frontend | [.s2s/](https://github.com/org/frontend/tree/main/.s2s) |
| Backend | https://github.com/org/backend | [.s2s/](https://github.com/org/backend/tree/main/.s2s) |
```

**Note**: Use absolute URLs (GitHub/GitLab) instead of relative paths. Relative paths don't work across separate repos.

---

## Versioning Considerations

### Critical Rule: Parent Folder Without Git

If the parent folder does NOT have a git repository and user wants to create `.s2s/` there:

**⚠️ WARNING**: The `.s2s/` folder will NOT be versioned.

**Implications**:
1. Documentation cannot be shared with team
2. History will not be preserved
3. Collaboration is impossible
4. Risk of data loss

**Recommendation**: Create a sibling folder with its own git repo instead.

---

## What to Version in `.s2s/`

### Always Version (Commit to Git)

| File/Folder | Purpose |
|-------------|---------|
| `config.yaml` | Project configuration |
| `CONTEXT.md` | Project context and overview |
| `BACKLOG.md` | Planned work and ideas |
| `requirements.md` | Requirements specification |
| `architecture.md` | Architecture documentation |
| `decisions/` | Architecture Decision Records |
| `plans/` | Implementation plans |

### Never Version (Add to .gitignore)

| File/Folder | Reason |
|-------------|--------|
| `sessions/` | Volatile, large, contains conversation artifacts |

**Suggested `.gitignore` entry**:
```
.s2s/sessions/
```

---

## Cross-Component Roundtables

For discussions that span multiple components:

1. **Start from system-docs folder**: Run `/s2s:roundtable` from the sibling docs folder
2. **Reference components**: Use absolute URLs in artifacts
3. **Assign follow-ups**: Create tasks in component-specific BACKLOG.md files

---

## Init Detection Logic

When running `/s2s:init`, detect:

1. **Is parent a git repo?** Check for `.git/` in parent
2. **Are sibling folders git repos?** Check for `.git/` in siblings
3. **Are there existing `.s2s/` folders?** Scan siblings and parent

Based on detection, suggest appropriate workspace configuration.

---

## Implementation Notes

### Future Commands (Not Yet Implemented)

| Command | Purpose |
|---------|---------|
| `/s2s:init --workspace` | Initialize as workspace hub |
| `/s2s:init --component` | Initialize as component of workspace |
| `/s2s:workspace:add` | Register a component in workspace |
| `/s2s:workspace:status` | Show workspace structure |

### Alternative: Guided Setup in `/s2s:init`

Instead of separate commands, enhance `/s2s:init` with interactive prompts:

1. Detect project structure
2. Ask: "Is this part of a larger workspace?"
3. If yes, ask for configuration preference (A/B/C/D)
4. Generate appropriate structure

This approach keeps the command surface small while supporting complex setups.

---

## Open Questions

1. **Component registry format**: Should we use `workspace.yaml` with `components:[]` or a separate `COMPONENTS.md`?
2. **Cross-component references**: How to handle relative vs absolute URLs in artifacts?
3. **Session scope**: Should cross-component sessions be stored in system-docs or replicated?

---

*Last updated: 2026-01-16*
