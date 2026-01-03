# Extending Spec2Ship

This guide explains how to extend Spec2Ship with new strategies, skills, and agents.

## Extension Types

| Extension | Description | Guide |
|-----------|-------------|-------|
| **Strategy** | New roundtable facilitation method | [new-strategy.md](./new-strategy.md) |
| **Skill** | New knowledge base (patterns, standards) | [new-skill.md](./new-skill.md) |
| **Agent** | New roundtable participant role | [new-agent.md](./new-agent.md) |

## Quick Reference

### Add a New Strategy

1. Create `skills/roundtable-strategies/references/{strategy}.md`
2. Define: participation mode, phases, consensus policy
3. Add auto-detection keywords to `SKILL.md`
4. Test with `/s2s:roundtable:start "topic" --strategy {strategy}`

### Add a New Skill

1. Create `skills/{skill-name}/SKILL.md`
2. Use third-person description with trigger phrases
3. Optionally add `references/` and `examples/`
4. Reference from agents: `skills: skill-name`

### Add a New Agent

1. Create `agents/roundtable/{agent-name}.md`
2. Define: perspective focus, contribution format
3. Add to workflow participant lists in config
4. Reference skills if needed: `skills: skill-name`

## Architecture Context

```
Spec2Ship Extension Points
───────────────────────────

skills/
├── roundtable-strategies/    ◄── Add strategies here
│   ├── SKILL.md
│   └── references/
│       ├── standard.md
│       ├── disney.md
│       └── {your-strategy}.md   ◄── New strategy
│
├── arc42-templates/          ◄── Add knowledge skills here
├── iso25010-requirements/
└── {your-skill}/             ◄── New skill
    └── SKILL.md

agents/
├── roundtable/               ◄── Add participants here
│   ├── orchestrator.md
│   ├── facilitator.md
│   ├── software-architect.md
│   └── {your-agent}.md       ◄── New agent
└── validation/
    └── {your-validator}.md   ◄── New validator
```

## Best Practices

### For Strategies

- Test with different topics
- Define clear phase boundaries
- Include consensus policy
- Document when to use

### For Skills

- Keep SKILL.md under 2,000 words
- Use progressive disclosure (references/)
- Include 3-5 trigger phrases
- Third-person description

### For Agents

- Define unique perspective
- Use standard contribution format
- Specify what to defer to others
- Test in roundtable sessions

## Testing Extensions

```bash
# Test a new strategy
/s2s:roundtable:start "Test topic" --strategy {your-strategy}

# Test agent skills loading
# Agent will have access to declared skills
```

---
*Part of Spec2Ship Documentation*
