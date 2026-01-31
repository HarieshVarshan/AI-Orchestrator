#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; }

# Main script
main() {
    local ID="$1"
    local NAME="$2"

    if [[ -z "$ID" ]] || [[ -z "$NAME" ]]; then
        log_error "Usage: $0 <id> <name>"
        echo ""
        echo "Examples:"
        echo "  $0 003 login_crash"
        echo "  $0 004 profile_not_loading"
        echo ""
        echo "This creates a bug spec (if needed) and runs the bug fix workflow."
        echo ""
        echo "Existing bugs:"
        ls -1 "$AI_DIR/bugs/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  $(basename "$f" .md)"
        done || echo "  (none)"
        exit 1
    fi

    local BUG_ID="${ID}_${NAME}"
    local BUG_FILE="$AI_DIR/bugs/${BUG_ID}.md"

    echo ""
    echo -e "${BOLD}Flutter Android AI Orchestration - Quick Bug Fix${NC}"
    echo "================================================="
    echo ""
    log_info "Fixing bug: $BUG_ID"
    echo ""

    # Check if bug spec already exists
    if [[ -f "$BUG_FILE" ]]; then
        log_success "Bug spec found: $BUG_FILE"
        log_info "Starting bug fix workflow..."
        echo ""

        # Run the bug workflow directly
        exec "$SCRIPT_DIR/orchestrate_bug.sh" "$BUG_ID"
    fi

    # Create bug spec from template
    log_step "Step 1: Create Bug Spec"

    mkdir -p "$AI_DIR/bugs"

    if [[ ! -f "$AI_DIR/bugs/_TEMPLATE.md" ]]; then
        log_error "Bug template not found: ai/bugs/_TEMPLATE.md"
        exit 1
    fi

    # Copy template and replace placeholders
    cp "$AI_DIR/bugs/_TEMPLATE.md" "$BUG_FILE"
    sed -i "s/{{ID}}/${BUG_ID}/g" "$BUG_FILE"
    sed -i "s/{{BUG_TITLE}}/${NAME}/g" "$BUG_FILE"

    log_success "Created bug spec: $BUG_FILE"
    echo ""
    echo -e "${YELLOW}ACTION REQUIRED:${NC}"
    echo "  Edit ai/bugs/${BUG_ID}.md with bug details:"
    echo ""
    echo "  Fill in:"
    echo "    - Reproduction steps"
    echo "    - Expected vs actual behavior"
    echo "    - Any error messages or logs"
    echo ""

    read -p "Press Enter after editing the bug spec..."

    log_step "Step 2: Fix Bug"

    log_info "Starting bug fix workflow..."
    echo ""

    # Run the bug workflow
    exec "$SCRIPT_DIR/orchestrate_bug.sh" "$BUG_ID"
}

main "$@"
