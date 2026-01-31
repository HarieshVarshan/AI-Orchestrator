#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"
APP_DIR="$PROJECT_ROOT/app"  # Flutter app directory

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

update_state() {
    local stage="$1"
    local task_id="$2"
    local timestamp=$(date -Iseconds)

    cat > "$AI_DIR/state.json" << EOF
{
  "current_task": "$task_id",
  "task_type": "bugfix",
  "stage": "$stage",
  "last_updated": "$timestamp",
  "history": []
}
EOF
}

check_bug_exists() {
    local id="$1"
    if [[ ! -f "$AI_DIR/bugs/${id}.md" ]]; then
        log_error "Bug file not found: $AI_DIR/bugs/${id}.md"
        exit 1
    fi
}

run_flutter_checks() {
    log_info "Running Flutter analyze..."
    if ! (cd "$APP_DIR" && flutter analyze); then
        log_error "Flutter analyze failed!"
        return 1
    fi
    log_success "Flutter analyze passed"

    log_info "Running Flutter tests..."
    if ! (cd "$APP_DIR" && flutter test); then
        log_error "Flutter tests failed!"
        return 1
    fi
    log_success "Flutter tests passed"

    return 0
}

# Main script
main() {
    local ID="$1"

    if [[ -z "$ID" ]]; then
        log_error "Usage: $0 <bug_id>"
        log_info "Example: $0 003_login_crash"
        exit 1
    fi

    local BUG_FILE="ai/bugs/${ID}.md"

    check_bug_exists "$ID"

    log_info "Starting bug fix: $ID"
    echo "========================================"

    # Stage 1: Fix Bug (includes writing regression test)
    log_info "Stage 1: Fixing bug (with regression test)..."
    update_state "fixing" "$ID"

    cat << EOF

Run Claude Code with the bugfix prompt:

claude --prompt "\$(cat ai/prompts/bugfix.txt)" \\
  --context "BUG_FILE=$BUG_FILE" \\
  --context "ID=$ID"

EOF

    read -p "Press Enter after bugfix is complete..."

    # Run Flutter checks
    if [[ -d "$APP_DIR" ]]; then
        run_flutter_checks || {
            log_error "Flutter checks failed after bugfix."
            log_warning "The regression test might be failing (expected if TDD)."
            read -p "Press Enter after fixes are applied..."

            # Re-run checks
            run_flutter_checks || {
                log_error "Tests still failing. Please resolve manually."
                exit 1
            }
        }
    fi

    # Stage 2: Safety Review (focused)
    log_info "Stage 2: Safety review of fix..."
    update_state "reviewing" "$ID"

    cat << EOF

Run Claude Code with the safety review prompt:

claude --prompt "\$(cat ai/prompts/review_safety.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after safety review is complete..."

    # Stage 3: Fix review comments if any
    if [[ -f "$AI_DIR/reviews/${ID}_safety.md" ]]; then
        local has_critical=$(grep -c "## Critical Issues" "$AI_DIR/reviews/${ID}_safety.md" || true)
        if [[ "$has_critical" -gt 0 ]]; then
            log_info "Stage 3: Addressing review comments..."
            update_state "fixing_review" "$ID"

            cat << EOF

Run Claude Code with the fix prompt:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$BUG_FILE" \\
  --context "ID=$ID"

EOF

            read -p "Press Enter after fixes are complete..."

            # Re-run checks
            if [[ -d "$APP_DIR" ]]; then
                run_flutter_checks || {
                    log_error "Tests failed after review fixes."
                    exit 1
                }
            fi
        fi
    fi

    # Stage 4: Test Review
    log_info "Stage 4: Reviewing regression test..."
    update_state "test_review" "$ID"

    cat << EOF

Run Claude Code with the test review prompt:

claude --prompt "\$(cat ai/prompts/test_review.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after test review is complete..."

    # Stage 5: Commit
    log_info "Stage 5: Creating commit..."
    update_state "committing" "$ID"

    cat << EOF

Run Claude Code with the commit prompt:

claude --prompt "\$(cat ai/prompts/commit.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=bugfix" \\
  --context "SPEC_FILE=$BUG_FILE"

EOF

    read -p "Press Enter after commit is created..."

    # Stage 6: Changelog
    log_info "Stage 6: Updating changelog..."
    update_state "changelog" "$ID"

    cat << EOF

Run Claude Code with the changelog prompt:

claude --prompt "\$(cat ai/prompts/changelog.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=bugfix" \\
  --context "SPEC_FILE=$BUG_FILE" \\
  --context "VERSION=Unreleased"

EOF

    read -p "Press Enter after changelog is updated..."

    # Stage 7: Session Log
    log_info "Stage 7: Creating session log..."
    update_state "session_log" "$ID"

    local today=$(date +%Y-%m-%d)
    cat << EOF

Run Claude Code with the session log prompt:

claude --prompt "\$(cat ai/prompts/session_log.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=bugfix" \\
  --context "DATE=$today"

EOF

    read -p "Press Enter after session log is created..."

    # Complete
    update_state "complete" "$ID"

    echo "========================================"
    log_success "Bug fix $ID completed successfully!"
    log_info "Review files: $AI_DIR/reviews/${ID}_*.md"
    log_info "Session log: $AI_DIR/session-logs/${today}_${ID}.md"
}

main "$@"
