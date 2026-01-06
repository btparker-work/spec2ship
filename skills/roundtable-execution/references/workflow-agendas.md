# Workflow Agendas

Different workflow types have different required topics to cover.

## Specs Workflow Agenda

For `workflow_type = "specs"`:

```yaml
REQUIRED_TOPICS:
  - id: "core-functional"
    name: "Core functional requirements"
    critical: true
  - id: "nfr"
    name: "Non-functional requirements (performance, security, scalability)"
    critical: true
  - id: "acceptance-criteria"
    name: "Acceptance criteria format and examples"
    critical: false
  - id: "out-of-scope"
    name: "Out of scope / Won't have"
    critical: false
```

## Design Workflow Agenda

For `workflow_type = "design"`:

```yaml
REQUIRED_TOPICS:
  - id: "high-level-arch"
    name: "High-level architecture and patterns"
    critical: true
  - id: "components"
    name: "Component boundaries and responsibilities"
    critical: true
  - id: "data-flow"
    name: "Data flow and storage"
    critical: false
  - id: "tech-choices"
    name: "Technology choices and rationale"
    critical: false
  - id: "integration"
    name: "Integration points and APIs"
    critical: false
```

## Brainstorm Workflow Agenda

For `workflow_type = "brainstorm"`:

```yaml
REQUIRED_TOPICS: null  # No agenda - free-form creativity
```

## Passing Agenda to Facilitator

In Step 3.1 and 3.3 prompts, include:

```
=== AGENDA ===
Required topics: {REQUIRED_TOPICS list or "None"}
Current coverage: {from previous synthesis or "Not started"}
```

The facilitator will use this to:
1. Generate questions targeting uncovered topics
2. Track coverage in synthesis output
3. Block conclusion until critical topics covered

---

*Part of roundtable-execution skill*
