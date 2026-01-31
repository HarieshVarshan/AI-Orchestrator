#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"
APP_DIR="$PROJECT_ROOT/app"
BACKEND_DIR="$PROJECT_ROOT/backend"

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_stage() { echo -e "${CYAN}[STAGE]${NC} $1"; }

update_state() {
    local stage="$1"
    local task_id="$2"
    local timestamp=$(date -Iseconds)

    cat > "$AI_DIR/state.json" << EOF
{
  "current_task": "$task_id",
  "task_type": "fullstack_feature",
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

run_backend_checks() {
    log_info "Running backend tests..."

    # Detect backend type and run appropriate tests
    if [[ -f "$BACKEND_DIR/package.json" ]]; then
        # Node.js
        (cd "$BACKEND_DIR" && npm test) || return 1
    elif [[ -f "$BACKEND_DIR/requirements.txt" ]] || [[ -f "$BACKEND_DIR/pyproject.toml" ]]; then
        # Python
        (cd "$BACKEND_DIR" && pytest) || return 1
    else
        log_warning "No backend test runner detected. Skipping backend tests."
        return 0
    fi

    log_success "Backend tests passed"
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
    local FEATURE_NAME="${ID#*_}"

    check_feature_exists "$ID"

    log_info "Starting full-stack feature development: $ID"
    echo "========================================"
    echo "This workflow covers: Database → Backend → Frontend → DevOps → Testing → Production"
    echo "========================================"

    # =========================================================================
    # PHASE 1: DATABASE DESIGN
    # =========================================================================

    log_stage "PHASE 1: DATABASE DESIGN"

    # Stage 1.1: Design Database Schema
    log_info "Stage 1.1: Designing database schema..."
    update_state "database_designing" "$ID"

    cat << EOF

Run Claude Code with the database design prompt:

claude --prompt "\$(cat ai/prompts/design_database.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "FEATURE_NAME=$FEATURE_NAME"

EOF

    read -p "Press Enter after database schema design is complete..."

    # Stage 1.2: Database Reviews
    log_info "Stage 1.2: Running database reviews..."
    update_state "database_reviewing" "$ID"

    cat << EOF

Run the following database reviews:

1. Database Schema Review:
   claude --prompt "\$(cat ai/prompts/review_database_schema.txt)" --context "ID=$ID"

2. Migration Safety Review:
   claude --prompt "\$(cat ai/prompts/review_migrations.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after database reviews are complete..."

    # Stage 1.3: Fix Database Issues
    local has_db_reviews=false
    for review_type in database_schema migrations; do
        if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
            has_db_reviews=true
            break
        fi
    done

    if $has_db_reviews; then
        log_info "Stage 1.3: Fixing database review comments..."
        update_state "database_fixing" "$ID"

        cat << EOF

Run Claude Code with the fix prompt for database:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "TARGET=database"

EOF

        read -p "Press Enter after database fixes are complete..."
    fi

    # =========================================================================
    # PHASE 2: BACKEND DEVELOPMENT
    # =========================================================================

    log_stage "PHASE 2: BACKEND DEVELOPMENT"

    # Stage 2.1: Implement Backend
    log_info "Stage 2.1: Implementing backend API..."
    update_state "backend_implementing" "$ID"

    cat << EOF

Run Claude Code with the backend implement prompt:

claude --prompt "\$(cat ai/prompts/implement_backend.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "FEATURE_NAME=$FEATURE_NAME"

EOF

    read -p "Press Enter after backend implementation is complete..."

    # Stage 2.2: Backend Reviews
    log_info "Stage 2.2: Running backend code reviews..."
    update_state "backend_reviewing" "$ID"

    cat << EOF

Run the following backend reviews:

1. API Design Review:
   claude --prompt "\$(cat ai/prompts/review_api_design.txt)" --context "ID=$ID"

2. Backend Security Review:
   claude --prompt "\$(cat ai/prompts/review_backend_security.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after backend reviews are complete..."

    # Stage 1.3: Fix Backend Issues
    local has_backend_reviews=false
    for review_type in api_design backend_security; do
        if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
            has_backend_reviews=true
            break
        fi
    done

    if $has_backend_reviews; then
        log_info "Stage 2.3: Fixing backend review comments..."
        update_state "backend_fixing" "$ID"

        cat << EOF

Run Claude Code with the fix prompt for backend:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "TARGET=backend"

EOF

        read -p "Press Enter after backend fixes are complete..."
    fi

    # Run backend tests
    if [[ -d "$BACKEND_DIR/src" ]]; then
        run_backend_checks || {
            log_warning "Backend tests failed. Fix issues before continuing."
            read -p "Press Enter after fixes are applied..."
        }
    fi

    # =========================================================================
    # PHASE 3: FRONTEND DEVELOPMENT
    # =========================================================================

    log_stage "PHASE 3: FRONTEND DEVELOPMENT"

    # Stage 3.1: Implement Frontend
    log_info "Stage 3.1: Implementing Flutter frontend..."
    update_state "frontend_implementing" "$ID"

    cat << EOF

Run Claude Code with the implement prompt:

claude --prompt "\$(cat ai/prompts/implement.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "FEATURE_NAME=$FEATURE_NAME"

EOF

    read -p "Press Enter after frontend implementation is complete..."

    # Run Flutter checks
    if [[ -d "$APP_DIR" ]]; then
        run_flutter_checks || {
            log_warning "Flutter checks failed. Fix issues before continuing."
            read -p "Press Enter after fixes are applied..."
        }
    fi

    # Stage 3.2: Frontend Reviews (all 10 reviewers)
    log_info "Stage 3.2: Running frontend code reviews..."
    update_state "frontend_reviewing" "$ID"

    cat << EOF

Run the following frontend reviews (can be parallel):

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

    read -p "Press Enter after all frontend reviews are complete..."

    # Stage 2.3: Fix Frontend Issues
    local has_frontend_reviews=false
    for review_type in safety architecture playstore ui android originality api auth data production; do
        if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
            has_frontend_reviews=true
            break
        fi
    done

    if $has_frontend_reviews; then
        log_info "Stage 3.3: Fixing frontend review comments..."
        update_state "frontend_fixing" "$ID"

        cat << EOF

Run Claude Code with the fix prompt for frontend:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID"

EOF

        read -p "Press Enter after frontend fixes are complete..."

        # Re-run Flutter checks
        if [[ -d "$APP_DIR" ]]; then
            run_flutter_checks || {
                log_error "Flutter checks failed after fixes. Please resolve manually."
                exit 1
            }
        fi
    fi

    # =========================================================================
    # PHASE 4: DEVOPS & INFRASTRUCTURE REVIEW (Optional)
    # =========================================================================

    log_stage "PHASE 4: DEVOPS & INFRASTRUCTURE REVIEW"

    # Check if DevOps files exist
    local has_devops_files=false
    if [[ -f "$PROJECT_ROOT/Dockerfile" ]] || \
       [[ -f "$PROJECT_ROOT/docker-compose.yml" ]] || \
       [[ -d "$PROJECT_ROOT/.github/workflows" ]] || \
       [[ -f "$PROJECT_ROOT/.gitlab-ci.yml" ]] || \
       [[ -d "$PROJECT_ROOT/k8s" ]] || \
       [[ -f "$PROJECT_ROOT/.env.example" ]]; then
        has_devops_files=true
    fi

    if $has_devops_files; then
        log_info "Stage 4.1: Running DevOps reviews..."
        update_state "devops_reviewing" "$ID"

        cat << EOF

Run the following DevOps reviews (as applicable):

1. CI/CD Pipeline Review:
   claude --prompt "\$(cat ai/prompts/review_cicd.txt)" --context "ID=$ID"

2. Docker/Container Review:
   claude --prompt "\$(cat ai/prompts/review_docker.txt)" --context "ID=$ID"

3. Environment Configuration Review:
   claude --prompt "\$(cat ai/prompts/review_environment.txt)" --context "ID=$ID"

4. Deployment Safety Review:
   claude --prompt "\$(cat ai/prompts/review_deployment.txt)" --context "ID=$ID"

EOF

        read -p "Press Enter after DevOps reviews are complete..."

        # Stage 4.2: Fix DevOps Issues
        local has_devops_reviews=false
        for review_type in cicd docker environment deployment; do
            if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
                has_devops_reviews=true
                break
            fi
        done

        if $has_devops_reviews; then
            log_info "Stage 4.2: Fixing DevOps review comments..."
            update_state "devops_fixing" "$ID"

            cat << EOF

Run Claude Code with the fix prompt for DevOps:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "TARGET=devops"

EOF

            read -p "Press Enter after DevOps fixes are complete..."
        fi
    else
        log_info "No DevOps files detected. Skipping DevOps review phase."
        log_info "DevOps files include: Dockerfile, docker-compose.yml, CI/CD configs, k8s/, .env.example"
    fi

    # =========================================================================
    # PHASE 5: TESTING & FINALIZATION
    # =========================================================================

    log_stage "PHASE 5: TESTING & FINALIZATION"

    # Stage 5.1: Create Tests
    log_info "Stage 5.1: Creating tests..."
    update_state "testing" "$ID"

    cat << EOF

Run Claude Code with the test prompt:

claude --prompt "\$(cat ai/prompts/test.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "FEATURE_NAME=$FEATURE_NAME" \\
  --context "ID=$ID"

EOF

    read -p "Press Enter after tests are created..."

    # Run all tests
    if [[ -d "$APP_DIR" ]]; then
        run_flutter_checks || {
            log_error "Tests failed. Please fix before continuing."
            exit 1
        }
    fi

    # Stage 5.2: Test Review
    log_info "Stage 5.2: Reviewing tests..."
    update_state "test_review" "$ID"

    cat << EOF

Run Claude Code with the test review prompt:

claude --prompt "\$(cat ai/prompts/test_review.txt)" --context "ID=$ID"

EOF

    read -p "Press Enter after test review is complete..."

    # Stage 5.3: Commit
    log_info "Stage 5.3: Creating commit..."
    update_state "committing" "$ID"

    cat << EOF

Run Claude Code with the commit prompt:

claude --prompt "\$(cat ai/prompts/commit.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=feature" \\
  --context "SPEC_FILE=$FEATURE_FILE"

EOF

    read -p "Press Enter after commit is created..."

    # Stage 5.4: Changelog
    log_info "Stage 5.4: Updating changelog..."
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

    # Stage 5.5: Session Log
    log_info "Stage 5.5: Creating session log..."
    update_state "session_log" "$ID"

    local today=$(date +%Y-%m-%d)
    cat << EOF

Run Claude Code with the session log prompt:

claude --prompt "\$(cat ai/prompts/session_log.txt)" \\
  --context "ID=$ID" \\
  --context "TYPE=fullstack_feature" \\
  --context "DATE=$today"

EOF

    read -p "Press Enter after session log is created..."

    # =========================================================================
    # PHASE 6: PRODUCTION READINESS (Optional - for releases)
    # =========================================================================

    log_stage "PHASE 6: PRODUCTION READINESS (Optional)"
    log_info "This phase runs additional release validation reviews."

    read -p "Run production readiness checks? (y/N): " run_prod_checks

    if [[ "$run_prod_checks" =~ ^[Yy]$ ]]; then
        update_state "production_readiness" "$ID"

        # Stage 6.1: Release Validation Reviews
        log_info "Stage 6.1: Running release validation reviews..."

        cat << EOF

Run the following release validation reviews:

1. Performance Review:
   claude --prompt "\$(cat ai/prompts/review_performance.txt)" --context "ID=$ID"

2. Accessibility Review:
   claude --prompt "\$(cat ai/prompts/review_accessibility.txt)" --context "ID=$ID"

3. Localization Review:
   claude --prompt "\$(cat ai/prompts/review_localization.txt)" --context "ID=$ID"

EOF

        read -p "Press Enter after release validation reviews are complete..."

        # Stage 6.2: Fix Release Issues
        local has_release_reviews=false
        for review_type in performance accessibility localization; do
            if [[ -f "$AI_DIR/reviews/${ID}_${review_type}.md" ]]; then
                has_release_reviews=true
                break
            fi
        done

        if $has_release_reviews; then
            log_info "Stage 6.2: Fixing release validation issues..."
            update_state "release_fixing" "$ID"

            cat << EOF

Run Claude Code with the fix prompt for release issues:

claude --prompt "\$(cat ai/prompts/fix.txt)" \\
  --context "FEATURE_FILE=$FEATURE_FILE" \\
  --context "ID=$ID" \\
  --context "TARGET=release"

EOF

            read -p "Press Enter after release fixes are complete..."
        fi

        # Stage 6.3: Production Checklist
        log_info "Stage 6.3: Running production readiness checklist..."
        update_state "production_checklist" "$ID"

        cat << EOF

Run Claude Code with the production checklist prompt:

claude --prompt "\$(cat ai/prompts/checklist_production.txt)" \\
  --context "ID=$ID" \\
  --context "VERSION=\$(cat $APP_DIR/pubspec.yaml | grep 'version:' | cut -d' ' -f2)"

EOF

        read -p "Press Enter after production checklist is complete..."

        # Check if ready for release
        if [[ -f "$AI_DIR/reviews/${ID}_production_checklist.md" ]]; then
            log_info "Production checklist created: $AI_DIR/reviews/${ID}_production_checklist.md"
            log_info "Review the checklist before proceeding with release."
        fi
    else
        log_info "Skipping production readiness checks."
        log_info "Run 'make release-check ID=$ID' separately before release."
    fi

    # Complete
    update_state "complete" "$ID"

    echo "========================================"
    log_success "Full-stack feature $ID completed successfully!"
    echo "========================================"
    log_info "Backend: $BACKEND_DIR/src/"
    log_info "Frontend: $APP_DIR/lib/"
    log_info "Reviews: $AI_DIR/reviews/${ID}_*.md"
    log_info "Session log: $AI_DIR/session-logs/${today}_${ID}.md"

    if [[ "$run_prod_checks" =~ ^[Yy]$ ]]; then
        log_info "Production checklist: $AI_DIR/reviews/${ID}_production_checklist.md"
    fi
}

main "$@"
