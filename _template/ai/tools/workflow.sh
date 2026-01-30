#!/bin/bash
set -e

# =============================================================================
# Workflow Orchestrator
# Runs the full pipeline: implement → review → fix → test → commit
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"

# Configuration - CUSTOMIZE THESE
MAX_FIX_ITERATIONS=3
REVIEWERS="quality"  # Add more: "quality security performance"

# Logging
LOG_DIR="$AI_DIR/logs"
mkdir -p "$LOG_DIR"

# =============================================================================
# Utility Functions
# =============================================================================

log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +%H:%M:%S)] ✓${NC} $1"; }
log_error() { echo -e "${RED}[$(date +%H:%M:%S)] ✗${NC} $1"; }
log_stage() { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; }

update_state() {
    local task="$1"
    local stage="$2"
    local status="${3:-in_progress}"
    local timestamp=$(date -Iseconds)

    cat > "$AI_DIR/state.json" << EOF
{
  "current_task": "$task",
  "stage": "$stage",
  "status": "$status",
  "started_at": "$timestamp"
}
EOF
}

get_state() {
    local field="$1"
    grep -o "\"$field\": *\"[^\"]*\"" "$AI_DIR/state.json" 2>/dev/null | cut -d'"' -f4 || echo ""
}

check_spec_exists() {
    local id="$1"
    if [[ ! -f "$AI_DIR/specs/${id}.md" ]]; then
        log_error "Spec not found: ai/specs/${id}.md"
        exit 1
    fi
}

has_critical_issues() {
    local id="$1"
    grep -rli "CRITICAL\|BLOCKER" "$AI_DIR/reviews/${id}_"*.md 2>/dev/null && return 0
    return 1
}

# =============================================================================
# Agent Runner
# =============================================================================

run_agent() {
    local prompt_file="$1"
    local context="$2"
    local description="$3"

    log "Running: $description"

    if [[ ! -f "$AI_DIR/prompts/$prompt_file" ]]; then
        log_error "Prompt not found: $prompt_file"
        return 1
    fi

    # Build the claude command
    # CUSTOMIZE: Add your preferred claude CLI flags
    local cmd="claude -p \"\$(cat $AI_DIR/prompts/$prompt_file)\""

    # Add context if provided
    if [[ -n "$context" ]]; then
        cmd="$cmd $context"
    fi

    # Execute
    # For now, print the command. When ready for automation, uncomment eval.
    echo ""
    echo -e "${YELLOW}Execute:${NC}"
    echo "$cmd"
    echo ""

    # UNCOMMENT FOR FULL AUTOMATION:
    # eval "$cmd"

    # For semi-auto mode, wait for user
    read -p "Press Enter when done..."

    return 0
}

# =============================================================================
# Pipeline Stages
# =============================================================================

stage_implement() {
    local id="$1"
    log_stage "IMPLEMENT: $id"
    update_state "$id" "implementing"

    run_agent "implement.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\"" \
        "Implementation"

    log_success "Implementation complete"
}

stage_review() {
    local id="$1"
    log_stage "REVIEW: $id"
    update_state "$id" "reviewing"

    for reviewer in $REVIEWERS; do
        if [[ -f "$AI_DIR/prompts/review_${reviewer}.txt" ]]; then
            run_agent "review_${reviewer}.txt" \
                "--context \"SPEC_FILE=ai/specs/${id}.md\" --context \"ID=$id\"" \
                "Review: $reviewer"
        fi
    done

    log_success "Reviews complete"
}

stage_fix() {
    local id="$1"
    local iteration="$2"
    log_stage "FIX: $id (iteration $iteration)"
    update_state "$id" "fixing"

    # Collect all review files
    local review_files=$(ls -1 "$AI_DIR/reviews/${id}_"*.md 2>/dev/null | tr '\n' ' ')

    if [[ -z "$review_files" ]]; then
        log "No review files found, skipping fix stage"
        return 0
    fi

    run_agent "fix.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\" --context \"REVIEW_FILES=$review_files\"" \
        "Fixing issues"

    log_success "Fixes applied"
}

stage_test() {
    local id="$1"
    log_stage "TEST: $id"
    update_state "$id" "testing"

    run_agent "test.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\"" \
        "Testing"

    log_success "Tests complete"
}

stage_commit() {
    local id="$1"
    log_stage "COMMIT: $id"
    update_state "$id" "committing"

    # Extract task name from ID
    local task_name="${id#*_}"

    echo ""
    echo -e "${YELLOW}Ready to commit. Suggested message:${NC}"
    echo ""
    echo "feat: implement $task_name"
    echo ""
    echo "Task-ID: $id"
    echo ""

    read -p "Commit? (y/N): " do_commit
    if [[ "$do_commit" == "y" || "$do_commit" == "Y" ]]; then
        git add -A
        git commit -s -m "feat: implement $task_name

Task-ID: $id"
        log_success "Committed"
    else
        log "Skipped commit"
    fi
}

# =============================================================================
# Main Workflow
# =============================================================================

run_workflow() {
    local id="$1"
    local log_file="$LOG_DIR/workflow_${id}_$(date +%Y%m%d_%H%M%S).log"

    echo "Logging to: $log_file"

    {
        log "Starting workflow for: $id"
        check_spec_exists "$id"

        # Stage 1: Implement
        stage_implement "$id"

        # Stage 2: Review
        stage_review "$id"

        # Stage 3: Fix (with iteration limit)
        local iteration=1
        while [[ $iteration -le $MAX_FIX_ITERATIONS ]]; do
            if has_critical_issues "$id"; then
                stage_fix "$id" "$iteration"
                stage_review "$id"  # Re-review after fix
                iteration=$((iteration + 1))
            else
                log "No critical issues found"
                break
            fi
        done

        if [[ $iteration -gt $MAX_FIX_ITERATIONS ]]; then
            log_error "Max fix iterations reached. Manual intervention required."
            update_state "$id" "fix_failed" "failed"
            exit 1
        fi

        # Stage 4: Test
        stage_test "$id"

        # Stage 5: Commit
        stage_commit "$id"

        # Done
        update_state "$id" "complete" "success"
        log_success "Workflow complete for: $id"

    } 2>&1 | tee -a "$log_file"
}

resume_workflow() {
    local current_task=$(get_state "current_task")
    local current_stage=$(get_state "stage")

    if [[ -z "$current_task" || "$current_task" == "null" ]]; then
        log_error "No workflow to resume"
        exit 1
    fi

    log "Resuming: $current_task from stage: $current_stage"
    # TODO: Implement stage-specific resume logic
    run_workflow "$current_task"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    local arg="$1"

    if [[ "$arg" == "--resume" ]]; then
        resume_workflow
    elif [[ -n "$arg" ]]; then
        run_workflow "$arg"
    else
        echo "Usage: $0 <task_id> | --resume"
        exit 1
    fi
}

main "$@"
