#!/bin/bash
set -e

# =============================================================================
# Batch Runner
# Process multiple tasks sequentially (overnight mode)
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"

# Configuration
STOP_ON_FAILURE=false  # Set to true to stop on first failure
NOTIFY_ON_COMPLETE=false  # Set to true to send notification when done

# Logging
LOG_DIR="$AI_DIR/logs"
mkdir -p "$LOG_DIR"
BATCH_LOG="$LOG_DIR/batch_$(date +%Y%m%d_%H%M%S).log"

# =============================================================================
# Utility Functions
# =============================================================================

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$msg"
    echo "$msg" >> "$BATCH_LOG"
}

log_success() { log "${GREEN}✓ $1${NC}"; }
log_error() { log "${RED}✗ $1${NC}"; }
log_separator() {
    local sep="=================================================================="
    echo "$sep"
    echo "$sep" >> "$BATCH_LOG"
}

notify() {
    local message="$1"
    # CUSTOMIZE: Add your notification method
    # Examples:
    # - macOS: osascript -e "display notification \"$message\" with title \"AI Orchestrator\""
    # - Linux: notify-send "AI Orchestrator" "$message"
    # - Slack: curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK
    echo "NOTIFICATION: $message"
}

# =============================================================================
# Batch Processing
# =============================================================================

process_batch() {
    local tasks=("$@")
    local total=${#tasks[@]}
    local success=0
    local failed=0
    local skipped=0
    local failed_tasks=()

    log_separator
    log "${BOLD}BATCH RUN STARTED${NC}"
    log "Tasks: ${tasks[*]}"
    log "Total: $total"
    log "Log: $BATCH_LOG"
    log_separator

    local start_time=$(date +%s)

    for i in "${!tasks[@]}"; do
        local task="${tasks[$i]}"
        local num=$((i + 1))

        log_separator
        log "${BLUE}[$num/$total] Processing: $task${NC}"
        log_separator

        # Check if spec exists
        if [[ ! -f "$AI_DIR/specs/${task}.md" ]]; then
            log_error "Spec not found: ai/specs/${task}.md - SKIPPING"
            skipped=$((skipped + 1))
            continue
        fi

        # Run workflow
        if "$SCRIPT_DIR/workflow.sh" "$task" >> "$BATCH_LOG" 2>&1; then
            log_success "Completed: $task"
            success=$((success + 1))
        else
            log_error "Failed: $task"
            failed=$((failed + 1))
            failed_tasks+=("$task")

            if [[ "$STOP_ON_FAILURE" == "true" ]]; then
                log_error "Stopping batch due to failure (STOP_ON_FAILURE=true)"
                break
            fi
        fi
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local duration_min=$((duration / 60))
    local duration_sec=$((duration % 60))

    log_separator
    log "${BOLD}BATCH RUN COMPLETE${NC}"
    log_separator
    log "Duration: ${duration_min}m ${duration_sec}s"
    log "Success:  $success"
    log "Failed:   $failed"
    log "Skipped:  $skipped"

    if [[ $failed -gt 0 ]]; then
        log ""
        log "${RED}Failed tasks:${NC}"
        for task in "${failed_tasks[@]}"; do
            log "  - $task"
        done
    fi

    log_separator
    log "Full log: $BATCH_LOG"

    # Notification
    if [[ "$NOTIFY_ON_COMPLETE" == "true" ]]; then
        if [[ $failed -eq 0 ]]; then
            notify "Batch complete! $success/$total tasks succeeded."
        else
            notify "Batch complete with errors. $success succeeded, $failed failed."
        fi
    fi

    # Exit code
    if [[ $failed -gt 0 ]]; then
        exit 1
    fi
}

# =============================================================================
# Summary Report
# =============================================================================

generate_summary() {
    local summary_file="$LOG_DIR/summary_$(date +%Y%m%d_%H%M%S).md"

    cat > "$summary_file" << EOF
# Batch Run Summary

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Log:** $BATCH_LOG

## Tasks Processed

| Task | Status | Notes |
|------|--------|-------|
EOF

    # Parse log for task results
    grep -E "^\[.*\] (Completed|Failed|SKIPPING):" "$BATCH_LOG" | while read line; do
        if [[ "$line" == *"Completed"* ]]; then
            task=$(echo "$line" | grep -o "Completed: [^ ]*" | cut -d' ' -f2)
            echo "| $task | ✅ Success | |" >> "$summary_file"
        elif [[ "$line" == *"Failed"* ]]; then
            task=$(echo "$line" | grep -o "Failed: [^ ]*" | cut -d' ' -f2)
            echo "| $task | ❌ Failed | Check logs |" >> "$summary_file"
        elif [[ "$line" == *"SKIPPING"* ]]; then
            echo "| (unknown) | ⏭️ Skipped | Spec not found |" >> "$summary_file"
        fi
    done

    echo ""
    echo "Summary written to: $summary_file"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <task1> <task2> ... <taskN>"
        echo ""
        echo "Options (set as environment variables):"
        echo "  STOP_ON_FAILURE=true    Stop on first failure"
        echo "  NOTIFY_ON_COMPLETE=true Send notification when done"
        echo ""
        echo "Example:"
        echo "  $0 001_login 002_profile 003_settings"
        echo "  STOP_ON_FAILURE=true $0 001_login 002_profile"
        exit 1
    fi

    process_batch "$@"
    generate_summary
}

main "$@"
