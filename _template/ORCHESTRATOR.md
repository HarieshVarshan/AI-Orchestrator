# AI Orchestrator Design Pattern

This document describes the generic pattern for building AI orchestrators that can run autonomously with minimal human intervention.

## Core Concepts

### 1. Files = Memory
AI agents don't have persistent memory across sessions. Files serve as shared state:
- **Specs** define WHAT to build (input)
- **Reviews** capture feedback (intermediate)
- **Decisions** document WHY choices were made (audit)
- **State** tracks WHERE we are in the workflow

### 2. Prompts = Role Boundaries
Each agent has a specific, constrained role:
- **Implementer**: Writes code/content based on spec
- **Reviewer**: Critiques output, finds issues
- **Fixer**: Addresses review feedback
- **Tester**: Validates correctness

Agents should NOT know about other agents or the overall pipeline.

### 3. Scripts = Control Flow
Bash scripts orchestrate the pipeline:
- Invoke Claude with specific prompts
- Pass context (files, IDs)
- Check completion/success
- Move to next stage

### 4. State Machine
The orchestrator is a state machine:
```
IDLE → IMPLEMENTING → REVIEWING → FIXING → TESTING → COMMITTING → IDLE
         ↑                          |
         └──────────────────────────┘ (if review fails)
```

## Directory Structure

```
your-orchestrator/
├── ai/                     # AI orchestration (gitignored in projects)
│   ├── Makefile.ai         # Orchestration commands
│   ├── tools/              # Orchestration scripts
│   │   ├── run_agent.sh    # Generic agent runner
│   │   ├── batch.sh        # Batch processor
│   │   └── workflow.sh     # Main workflow orchestrator
│   ├── prompts/            # Agent role definitions
│   │   ├── implement.txt
│   │   ├── review_*.txt
│   │   ├── fix.txt
│   │   └── test.txt
│   ├── specs/              # Task specifications (SOURCE OF TRUTH)
│   │   ├── _TEMPLATE.md
│   │   └── 001_task.md
│   ├── reviews/            # Generated review findings
│   ├── decisions/          # Decision documentation
│   ├── logs/               # Execution logs
│   └── state.json          # Current orchestration state
├── project/                # Your actual project files (tracked)
├── Makefile                # Project-specific commands only
├── CLAUDE.md               # AI guidelines for this project
└── README.md
```

## Key Design Principles

### 1. Spec-Driven Development
Everything starts with a spec. No spec = no work.

```markdown
# Spec: 001_feature_name

## Objective
What should be accomplished?

## Requirements
- Requirement 1
- Requirement 2

## Constraints
- What NOT to do
- Boundaries

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

### 2. Review Gates
Reviews are checkpoints that must pass before proceeding:
- Multiple reviewers catch different issues
- Severity levels: CRITICAL (blocks), HIGH, MEDIUM, LOW
- CRITICAL issues must be fixed before continuing

### 3. Idempotent Operations
Each stage should be re-runnable:
- If interrupted, can resume from last state
- If failed, can retry without side effects

### 4. Comprehensive Logging
Log everything for post-run analysis:
- What was executed
- What Claude output
- What succeeded/failed
- Timestamps for debugging

## Workflow Stages

### Stage 1: Spec Validation
```bash
# Check spec exists and is valid
validate_spec "$SPEC_FILE"
```

### Stage 2: Implementation
```bash
# Run implementer agent
claude -p "$(cat ai/prompts/implement.txt)" \
  --context "SPEC_FILE=$SPEC_FILE" \
  --allowedTools "Read,Write,Edit,Bash"
```

### Stage 3: Review (Parallel)
```bash
# Run multiple reviewers in parallel
for reviewer in safety architecture quality; do
  claude -p "$(cat ai/prompts/review_${reviewer}.txt)" \
    --context "SPEC_FILE=$SPEC_FILE" &
done
wait
```

### Stage 4: Fix
```bash
# If reviews found issues, run fixer
if has_critical_issues; then
  claude -p "$(cat ai/prompts/fix.txt)" \
    --context "REVIEW_FILES=ai/reviews/${ID}_*.md"
fi
```

### Stage 5: Test
```bash
# Run tests
claude -p "$(cat ai/prompts/test.txt)" \
  --context "SPEC_FILE=$SPEC_FILE"
```

### Stage 6: Commit
```bash
# Create commit with proper message
git add -A
git commit -s -m "feat: implement ${TASK_NAME}"
```

## State Management

### state.json
```json
{
  "current_task": "001_feature",
  "stage": "reviewing",
  "started_at": "2024-01-30T10:00:00Z",
  "history": [
    {"stage": "implementing", "completed_at": "...", "status": "success"},
    {"stage": "reviewing", "started_at": "...", "status": "in_progress"}
  ]
}
```

### State Transitions
```bash
update_state() {
  local stage="$1"
  local status="$2"
  # Update state.json with new stage/status
}
```

## Batch Processing

For running multiple tasks overnight:

```bash
#!/bin/bash
# batch.sh

TASKS="001_login 002_profile 003_settings"
LOG_FILE="ai/logs/batch_$(date +%Y%m%d_%H%M%S).log"

for task in $TASKS; do
  echo "[$(date)] Starting $task" >> "$LOG_FILE"

  if ./ai/tools/workflow.sh "$task" >> "$LOG_FILE" 2>&1; then
    echo "[$(date)] Completed $task" >> "$LOG_FILE"
  else
    echo "[$(date)] FAILED $task" >> "$LOG_FILE"
    # Decide: continue or abort?
  fi
done

echo "[$(date)] Batch complete" >> "$LOG_FILE"
```

## Error Handling

### Retry Logic
```bash
run_with_retry() {
  local cmd="$1"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    if $cmd; then
      return 0
    fi
    retry=$((retry + 1))
    echo "Retry $retry/$max_retries..."
    sleep 5
  done

  return 1
}
```

### Graceful Degradation
- If a reviewer fails, continue with others
- If non-critical fix fails, log and continue
- If critical fix fails, stop and alert

## Customization Points

### 1. Prompts
Edit `ai/prompts/*.txt` to define agent behavior for your domain.

### 2. Reviewers
Add/remove reviewers based on your needs:
- Code: safety, architecture, style
- Content: accuracy, tone, grammar
- Data: schema, validation, integrity

### 3. Workflow Stages
Modify `ai/tools/workflow.sh` to add/remove stages.

### 4. Spec Template
Customize `ai/specs/_TEMPLATE.md` for your task type.

## Example Use Cases

| Domain | Implementer | Reviewers | Output |
|--------|-------------|-----------|--------|
| Flutter App | Write Flutter code | Safety, UI, Android, PlayStore | `lib/` files |
| API Backend | Write endpoints | Security, Design, Performance | `src/` files |
| Documentation | Write docs | Accuracy, Clarity, Completeness | `.md` files |
| Data Pipeline | Write ETL code | Schema, Performance, Quality | SQL/Python |
| Test Suite | Write tests | Coverage, Quality, Edge cases | `test/` files |

## Anti-Patterns

### DON'T: Monolithic Prompts
```
# Bad: One prompt does everything
"Implement, review, fix, and test this feature..."
```

### DO: Single-Responsibility Prompts
```
# Good: Each prompt has one job
implement.txt: "Implement the feature per spec..."
review.txt: "Review the implementation for issues..."
```

### DON'T: Hardcoded Paths
```bash
# Bad
cat /home/user/project/ai/prompts/implement.txt
```

### DO: Relative Paths
```bash
# Good
SCRIPT_DIR="$(dirname "$0")"
cat "$SCRIPT_DIR/../prompts/implement.txt"
```

### DON'T: Silent Failures
```bash
# Bad
claude -p "..." || true
```

### DO: Explicit Error Handling
```bash
# Good
if ! claude -p "..."; then
  log_error "Implementation failed"
  update_state "implementing" "failed"
  exit 1
fi
```
