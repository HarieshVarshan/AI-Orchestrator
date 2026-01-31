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

# Default template URL (can be overridden)
DEFAULT_TEMPLATE_URL="https://github.com/username/Flutter-Android-Team.git"

# Files/folders that should be synced from template
SYNC_PATHS=(
    "tools/"
    "ai/prompts/"
    "templates/"
    "Makefile"
    "CLAUDE.md"
)

# Files/folders that should NEVER be synced (project-specific)
IGNORE_PATHS=(
    "ai/features/"
    "ai/bugs/"
    "ai/reviews/"
    "ai/session-logs/"
    "ai/decisions/"
    "ai/changelogs/"
    "ai/state.json"
    "app/"
    "reference/"
    "docs/"
    ".gitignore"
    ".git/"
    "CHANGELOG.md"
    "PROJECT.md"
)

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << EOF
Template Sync Tool
==================

Syncs framework updates from the template repository to your project.

Usage: $0 [OPTIONS]

Options:
    --url URL       Template repository URL (required for first sync)
    --check         Check for updates without applying
    --list          List what files would be synced
    --help          Show this help message

What gets synced:
    - tools/            Orchestration scripts
    - ai/prompts/       Agent prompts
    - templates/        Project templates
    - Makefile          Build commands
    - CLAUDE.md         AI guidelines

What is preserved (never synced):
    - PROJECT.md        Your project-specific instructions
    - ai/features/      Your feature specs
    - ai/bugs/          Your bug specs
    - ai/reviews/       Generated reviews
    - ai/session-logs/  Session logs
    - ai/decisions/     Your decisions
    - app/              Your Flutter app
    - reference/        Your reference materials
    - docs/             Your project documentation
    - .gitignore        Your gitignore
    - CHANGELOG.md      Your changelog

Example:
    # First time - add template remote
    $0 --url https://github.com/username/Flutter-Android-Team.git

    # Check for updates
    $0 --check

    # Apply updates
    $0

EOF
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not a git repository. Initialize git first."
        exit 1
    fi
}

setup_template_remote() {
    local url="$1"

    if git remote | grep -q "^template$"; then
        log_info "Template remote already exists"
        # Update URL if provided
        if [[ -n "$url" ]]; then
            git remote set-url template "$url"
            log_info "Updated template remote URL"
        fi
    else
        if [[ -z "$url" ]]; then
            log_error "Template remote not set. Use --url to specify template repository."
            exit 1
        fi
        git remote add template "$url"
        log_success "Added template remote: $url"
    fi
}

fetch_template() {
    log_info "Fetching from template repository..."
    git fetch template --quiet
    log_success "Fetched template updates"
}

check_updates() {
    log_info "Checking for template updates..."

    # Get the latest template commit
    local template_branch="template/master"
    if ! git rev-parse "$template_branch" > /dev/null 2>&1; then
        template_branch="template/main"
    fi

    local changes=false
    for path in "${SYNC_PATHS[@]}"; do
        if git diff HEAD "$template_branch" --name-only -- "$path" 2>/dev/null | grep -q .; then
            changes=true
            log_info "Updates available in: $path"
            git diff HEAD "$template_branch" --stat -- "$path" 2>/dev/null
        fi
    done

    if ! $changes; then
        log_success "Your framework files are up to date!"
    fi
}

list_sync_files() {
    log_info "Files that would be synced from template:"
    echo ""
    for path in "${SYNC_PATHS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $path"
    done
    echo ""
    log_info "Files that are preserved (never synced):"
    echo ""
    for path in "${IGNORE_PATHS[@]}"; do
        echo -e "  ${YELLOW}✗${NC} $path"
    done
}

sync_template() {
    log_info "Syncing template updates..."

    # Get the latest template commit
    local template_branch="template/master"
    if ! git rev-parse "$template_branch" > /dev/null 2>&1; then
        template_branch="template/main"
    fi

    # Create a backup branch
    local backup_branch="backup-before-sync-$(date +%Y%m%d-%H%M%S)"
    git branch "$backup_branch"
    log_info "Created backup branch: $backup_branch"

    # Sync each path
    for path in "${SYNC_PATHS[@]}"; do
        log_info "Syncing: $path"
        # Checkout the path from template
        git checkout "$template_branch" -- "$path" 2>/dev/null || true
    done

    # Check if there are changes
    if git diff --cached --quiet; then
        log_success "No changes to apply"
        git branch -d "$backup_branch"
    else
        log_info "Changes staged. Review with 'git diff --cached'"
        echo ""
        git diff --cached --stat
        echo ""
        log_warning "Review the changes above."
        log_info "To apply: git commit -m 'chore: sync framework updates from template'"
        log_info "To undo:  git checkout HEAD -- . && git branch -d $backup_branch"
    fi
}

# Main
main() {
    local url=""
    local check_only=false
    local list_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                url="$2"
                shift 2
                ;;
            --check)
                check_only=true
                shift
                ;;
            --list)
                list_only=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    cd "$PROJECT_ROOT"

    if $list_only; then
        list_sync_files
        exit 0
    fi

    check_git_repo
    setup_template_remote "$url"
    fetch_template

    if $check_only; then
        check_updates
    else
        sync_template
    fi
}

main "$@"
