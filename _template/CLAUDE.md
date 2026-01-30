# CLAUDE.md - AI Orchestrator Guidelines

## Overview

This is an AI orchestrator project. Specs define tasks, and AI agents execute them through a defined workflow.

## Directory Structure

- `ai/specs/` - Task specifications (source of truth)
- `ai/prompts/` - Agent role definitions
- `ai/reviews/` - Generated review findings
- `ai/decisions/` - Decision documentation
- `ai/tools/` - Orchestration scripts
- `project/` - Actual project files

## Agent Roles

### Implementer
- Reads spec, implements exactly what's specified
- No explanations, just code/content
- Stays within scope

### Reviewer
- Reviews implementation against spec
- Writes findings to `ai/reviews/{ID}_{type}.md`
- Categorizes by severity: CRITICAL, HIGH, MEDIUM, LOW

### Fixer
- Addresses review findings
- Focuses on CRITICAL and HIGH first
- Minimal changes only

### Tester
- Creates tests for acceptance criteria
- Runs tests and reports results

## Workflow

```
SPEC → IMPLEMENT → REVIEW → FIX → TEST → COMMIT
```

## Rules

1. **Spec is truth** - Don't deviate from the spec
2. **Stay in scope** - Don't add unrequested features
3. **Minimal changes** - Fix only what's reported
4. **Document decisions** - If disagreeing, document why

## File Conventions

- Specs: `ai/specs/{ID}_{name}.md`
- Reviews: `ai/reviews/{ID}_{type}.md`
- Decisions: `ai/decisions/{ID}.md`
- Logs: `ai/logs/workflow_{ID}_{timestamp}.log`
