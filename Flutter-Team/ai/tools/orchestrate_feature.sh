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
  "task_type": "feature",
  "stage": "$stage",
  "last_updated": "$timestamp",
  "history": []
}
EOF
}

check_feature_exists() {
    local id="$1"
    if [[ ! -f "$AI_DIR/features/${id}.md" ]]; then
        log_error "Feature file not found: $AI_DIR/features/${id}.md"
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
        log_error "Usage: $0 <feature_id>"
        log_info "Example: $0 001_login"
        exit 1
    fi

    local FEATURE_FILE="ai/features/${ID}.md"
    local FEATURE_NAME="${ID#*_}"  # Extract name after underscore

    check_feature_exists "$ID"

    log_info "Starting feature development: $ID"
    echo "========================================"

    # Stage 1: Implement
    log_info "Stage 1: Implementing feature..."
    update_state "implementing" "$ID"

    cat << EOF

Run Claude Code with the implement prompt:

claude --prompt "\$(cat ai/prompts/implement.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "FEATURE_NAME=$FEATURE_NAME"

EOF

    read -p "Press Enter after implementation is complete..."

    # Run Flutter checks after implementation
    if [[ -d "$APP_DIR" ]]; then
        run_flutter_checks || {
            log_warning "Flutter checks failed. Fix issues before continuing."
            read -p "Press Enter after fixes are applied..."
        }
    fi

    # Stage 2: Review (parallel reviews)
    log_info "Stage 2: Running code reviews..."
    update_state "reviewing" "$ID"

    cat << EOF

Run the following review prompts (can be parallel):

1. Safety Review:
   claude --prompt "\$(cat ai/prompts/review_safety.txt)" --context "ID=$ID"

2. Architecture Review:
   claude --prompt "\$(cat ai/prompts/review_architecture.txt)" --context "ID=$ID"

3. Play Store Review:
   claude --prompt "\$(cat ai/prompts/review_playstore.txt)" --context "ID=$ID"

4. UI/UX Review:
   claude --prompt "\$(cat ai/prompts/review_ui.txt)" --context "ID=$ID"

5. Android Review:
   claude --prompt "\$(cat ai/prompts/review_android.txt)" --context "ID=$ID"

6. Originality Review:
   claude --prompt "\$(cat ai/prompts/review_originality.txt)" --context "ID=$ID"

7. API Integration Review:
   claude --prompt "\$(cat ai/prompts/review_api.txt)" --context "ID=$ID"

8. Auth Flow Review:
   claude --prompt "\$(cat ai/prompts/review_auth.txt)" --context "ID=$ID"

9. Data Layer Review:
   claude --prompt "\$(cat ai/prompts/review_data.txt)" --context "ID=$ID"

10. Production Readiness Review:
    claude --prompt "\$(cat ai/prompts/review_production.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after all reviews are complete..."

    # Check if reviews exist
    local has_reviews=false
    for review_type in safety architecture playstore ui android originality api auth data production; do
        if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
            has_reviews=true
            break
        fi
    done

    # Stage 3: Fix (if reviews exist)
    if $has_reviews; then
        log_info "Stage 3: Fixing review comments..."
        update_state "fixing" "$ID"

        cat << EOF

Run Claude Code with the fix prompt:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID"

EOF

        read -p "Press Enter after fixes are complete..."

        # Run Flutter checks after fixes
        if [[ -d "$APP_DIR" ]]; then
            run_flutter_checks || {
                log_error "Flutter checks failed after fixes. Please resolve manually."
                exit 1
            }
        fi
    else
        log_success "No critical issues found in reviews!"
    fi

    # Stage 4: Testing
    log_info "Stage 4: Creating tests..."
    update_state "testing" "$ID"

    cat << EOF

Run Claude Code with the test prompt:

claude --prompt "\$(cat ai/prompts/test.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "FEATURE_NAME=$FEATURE_NAME" \\
  --context "ID=$ID"

EOF

    read -p "Press Enter after tests are created..."

    # Run tests
    if [[ -d "$APP_DIR" ]]; then
        run_flutter_checks || {
            log_error "Tests failed. Please fix before continuing."
            exit 1
        }
    fi

    # Stage 5: Test Review
    log_info "Stage 5: Reviewing tests..."
    update_state "test_review" "$ID"

    cat << EOF

Run Claude Code with the test review prompt:

claude --prompt "\$(cat ai/prompts/test_review.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after test review is complete..."

    # Stage 6: Commit
    log_info "Stage 6: Creating commit..."
    update_state "committing" "$ID"

    cat << EOF

Run Claude Code with the commit prompt:

claude --prompt "\$(cat ai/prompts/commit.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=feature" \\
  --context "SPEC_FILE=$FEATURE_FILE"

EOF

    read -p "Press Enter after commit is created..."

    # Stage 7: Changelog
    log_info "Stage 7: Updating changelog..."
    update_state "changelog" "$ID"

    cat << EOF

Run Claude Code with the changelog prompt:

claude --prompt "\$(cat ai/prompts/changelog.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=feature" \\
  --context "SPEC_FILE=$FEATURE_FILE" \\
  --context "VERSION=Unreleased"

EOF

    read -p "Press Enter after changelog is updated..."

    # Stage 8: Session Log
    log_info "Stage 8: Creating session log..."
    update_state "session_log" "$ID"

    local today=$(date +%Y-%m-%d)
    cat << EOF

Run Claude Code with the session log prompt:

claude --prompt "\$(cat ai/prompts/session_log.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=feature" \\
  --context "DATE=$today"

EOF

    read -p "Press Enter after session log is created..."

    # Stage 9: Dev Docs
    log_info "Stage 9: Creating developer documentation..."
    update_state "dev_docs" "$ID"

    cat << EOF

Run Claude Code with the dev docs prompt:

claude --prompt "\$(cat ai/prompts/dev_docs.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "FEATURE_NAME=$FEATURE_NAME" \\
  --context "ID=$ID"

EOF

    read -p "Press Enter after documentation is created..."

    # Complete
    update_state "complete" "$ID"

    echo "========================================"
    log_success "Feature $ID completed successfully!"
    log_info "Review files: $AI_DIR/reviews/${ID}_*.md"
    log_info "Decisions: $AI_DIR/decisions/${ID}.md"
    log_info "Session log: $AI_DIR/session-logs/${today}_${ID}.md"
}

main "$@"
