#!/bin/bash
set -e

# =============================================================================
# Stage Runner
# Run individual stages of the workflow
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"

# =============================================================================
# Utility Functions
# =============================================================================

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

run_claude() {
    local prompt_file="$1"
    local extra_context="$2"

    if [[ ! -f "$AI_DIR/prompts/$prompt_file" ]]; then
        log_error "Prompt not found: $prompt_file"
        return 1
    fi

    echo ""
    echo -e "${YELLOW}Run Claude with:${NC}"
    echo ""
    echo "claude -p \"\$(cat $AI_DIR/prompts/$prompt_file)\" $extra_context"
    echo ""

    # UNCOMMENT FOR FULL AUTOMATION:
    # claude -p "$(cat $AI_DIR/prompts/$prompt_file)" $extra_context

    read -p "Press Enter when done..."
}

# =============================================================================
# Stages
# =============================================================================

stage_implement() {
    local id="$1"
    log "Running implementation for: $id"

    run_claude "implement.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\""

    log_success "Implementation stage complete"
}

stage_review() {
    local id="$1"
    log "Running reviews for: $id"

    # Get list of reviewers from prompts directory
    local reviewers=$(ls -1 "$AI_DIR/prompts/review_"*.txt 2>/dev/null | \
        xargs -I {} basename {} .txt | sed 's/review_//')

    if [[ -z "$reviewers" ]]; then
        log_error "No review prompts found in ai/prompts/"
        return 1
    fi

    for reviewer in $reviewers; do
        log "Running reviewer: $reviewer"
        run_claude "review_${reviewer}.txt" \
            "--context \"SPEC_FILE=ai/specs/${id}.md\" --context \"ID=$id\""
    done

    log_success "Review stage complete"
}

stage_fix() {
    local id="$1"
    log "Running fixes for: $id"

    local review_files=$(ls -1 "$AI_DIR/reviews/${id}_"*.md 2>/dev/null | tr '\n' ' ')

    if [[ -z "$review_files" ]]; then
        log "No review files found, nothing to fix"
        return 0
    fi

    run_claude "fix.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\" --context \"REVIEW_FILES=$review_files\""

    log_success "Fix stage complete"
}

stage_test() {
    local id="$1"
    log "Running tests for: $id"

    run_claude "test.txt" \
        "--context \"SPEC_FILE=ai/specs/${id}.md\""

    log_success "Test stage complete"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    local stage="$1"
    local id="$2"

    if [[ -z "$stage" ]] || [[ -z "$id" ]]; then
        echo "Usage: $0 <stage> <task_id>"
        echo ""
        echo "Stages: implement, review, fix, test"
        echo ""
        echo "Example: $0 implement 001_login"
        exit 1
    fi

    # Check spec exists
    if [[ ! -f "$AI_DIR/specs/${id}.md" ]]; then
        log_error "Spec not found: ai/specs/${id}.md"
        exit 1
    fi

    case "$stage" in
        implement)
            stage_implement "$id"
            ;;
        review)
            stage_review "$id"
            ;;
        fix)
            stage_fix "$id"
            ;;
        test)
            stage_test "$id"
            ;;
        *)
            log_error "Unknown stage: $stage"
            echo "Valid stages: implement, review, fix, test"
            exit 1
            ;;
    esac
}

main "$@"
