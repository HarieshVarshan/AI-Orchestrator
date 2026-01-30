# AI Orchestrator Template

A generic template for building AI orchestrators that can run autonomously with minimal human intervention.

## Quick Start

```bash
# 1. Copy this template
cp -r _template/ my-orchestrator/
cd my-orchestrator/

# 2. Create a spec
make -f ai/Makefile.ai new ID=001 NAME=my_task

# 3. Edit the spec
vim ai/specs/001_my_task.md

# 4. Run the workflow
make -f ai/Makefile.ai run ID=001_my_task

# 5. Or run multiple tasks overnight
make -f ai/Makefile.ai batch IDS="001_task1 002_task2 003_task3"
```

## Structure

```
my-orchestrator/
├── ai/                     # AI orchestration (gitignore in real projects)
│   ├── Makefile.ai         # Orchestration commands
│   ├── tools/              # Workflow scripts
│   │   ├── workflow.sh     # Main orchestrator
│   │   ├── batch.sh        # Batch processor
│   │   └── run_stage.sh    # Individual stage runner
│   ├── prompts/            # Agent definitions
│   │   ├── implement.txt   # Implementer agent
│   │   ├── review_*.txt    # Reviewer agents
│   │   ├── fix.txt         # Fixer agent
│   │   └── test.txt        # Tester agent
│   ├── specs/              # Task specifications
│   ├── reviews/            # Generated reviews
│   ├── decisions/          # Decision documentation
│   ├── logs/               # Execution logs
│   └── state.json          # Workflow state
├── project/                # Your actual project
├── Makefile                # Project commands
├── ORCHESTRATOR.md         # Design documentation
└── README.md               # This file
```

## Customization Guide

### 1. Define Your Domain

What kind of tasks will this orchestrator handle?

| Domain | Example Tasks |
|--------|---------------|
| Software | Implement features, fix bugs |
| Content | Write articles, create docs |
| Data | Build pipelines, create reports |
| DevOps | Setup infrastructure, create configs |

### 2. Customize Prompts

Edit files in `ai/prompts/` to match your domain:

**implement.txt** - What should the implementer do?
```
# For a content orchestrator:
"You are a content writer. Create content based on the spec..."

# For a DevOps orchestrator:
"You are a DevOps engineer. Create infrastructure as code..."
```

**review_*.txt** - What should reviewers check?
- Create multiple reviewers for different concerns
- Examples: `review_security.txt`, `review_style.txt`, `review_accuracy.txt`

### 3. Customize Spec Template

Edit `ai/specs/_TEMPLATE.md` for your task type:

```markdown
# For content:
## Topic
## Target Audience
## Key Points
## Tone

# For DevOps:
## Infrastructure
## Requirements
## Constraints
## Rollback Plan
```

### 4. Customize Workflow

Edit `ai/tools/workflow.sh`:

```bash
# Add/remove stages
STAGES="implement review fix test deploy"  # Add deploy stage

# Add/remove reviewers
REVIEWERS="security compliance performance"  # Domain-specific

# Change iteration limits
MAX_FIX_ITERATIONS=5  # More iterations for complex tasks
```

### 5. Add Project Commands

Edit root `Makefile` with your project-specific commands:

```makefile
build:
    npm run build  # or your build command

test:
    npm test  # or your test command
```

## Commands Reference

### Workflow Commands

```bash
# Run full workflow for one task
make -f ai/Makefile.ai run ID=001_task

# Run multiple tasks (overnight mode)
make -f ai/Makefile.ai batch IDS="001 002 003"

# Resume interrupted workflow
make -f ai/Makefile.ai resume
```

### Stage Commands

```bash
# Run individual stages
make -f ai/Makefile.ai implement ID=001_task
make -f ai/Makefile.ai review ID=001_task
make -f ai/Makefile.ai fix ID=001_task
make -f ai/Makefile.ai test ID=001_task
```

### Management Commands

```bash
# Create new spec
make -f ai/Makefile.ai new ID=001 NAME=my_task

# Check status
make -f ai/Makefile.ai status

# View logs
make -f ai/Makefile.ai logs

# Reset state
make -f ai/Makefile.ai reset
```

## Overnight Batch Mode

For running multiple tasks unattended:

```bash
# Run batch with all specs
make -f ai/Makefile.ai batch IDS="001_login 002_profile 003_settings"

# Stop on first failure
STOP_ON_FAILURE=true make -f ai/Makefile.ai batch IDS="..."

# Get notified when done (configure in batch.sh)
NOTIFY_ON_COMPLETE=true make -f ai/Makefile.ai batch IDS="..."
```

Check results in the morning:
```bash
# View batch summary
cat ai/logs/summary_*.md

# View detailed logs
cat ai/logs/batch_*.log
```

## Full Automation

To enable fully automated Claude execution (no manual intervention):

1. Edit `ai/tools/workflow.sh`
2. Find the `run_agent()` function
3. Uncomment the `eval "$cmd"` line
4. Comment out the `read -p "Press Enter..."` line

```bash
run_agent() {
    # ...
    # UNCOMMENT FOR FULL AUTOMATION:
    eval "$cmd"

    # COMMENT OUT FOR FULL AUTOMATION:
    # read -p "Press Enter when done..."
}
```

## Example Use Cases

### 1. Flutter App Orchestrator
See `Flutter-Android-Team/` in this repo.

### 2. Documentation Orchestrator
```bash
cp -r _template/ doc-orchestrator/
# Customize prompts for content writing
# Add reviewers: accuracy, grammar, style
```

### 3. API Backend Orchestrator
```bash
cp -r _template/ api-orchestrator/
# Customize prompts for backend development
# Add reviewers: security, api-design, performance
```

### 4. Data Pipeline Orchestrator
```bash
cp -r _template/ data-orchestrator/
# Customize prompts for ETL development
# Add reviewers: schema, data-quality, performance
```

## Design Documentation

See `ORCHESTRATOR.md` for detailed design patterns and principles.

## License

MIT
