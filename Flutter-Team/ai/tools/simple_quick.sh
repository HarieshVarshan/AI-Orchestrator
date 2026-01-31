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
        echo "  $0 001 login"
        echo "  $0 002 profile_settings"
        echo ""
        echo "This creates a request and immediately starts the build workflow."
        exit 1
    fi

    local FEATURE_ID="${ID}_${NAME}"
    local REQUEST_FILE="$AI_DIR/requests/${FEATURE_ID}.md"

    echo ""
    echo -e "${BOLD}Flutter Android AI Orchestration - Quick Feature${NC}"
    echo "================================================="
    echo ""
    log_info "Creating quick feature: $FEATURE_ID"
    echo ""

    # Check if request or feature already exists
    if [[ -f "$AI_DIR/features/${FEATURE_ID}.md" ]]; then
        log_info "Feature spec already exists."
        log_info "Starting build workflow directly..."
        echo ""
        exec "$SCRIPT_DIR/simple_build.sh" "$FEATURE_ID"
    fi

    if [[ -f "$REQUEST_FILE" ]]; then
        log_info "Request already exists: $REQUEST_FILE"
        log_info "Starting build workflow..."
        echo ""
        exec "$SCRIPT_DIR/simple_build.sh" "$FEATURE_ID"
    fi

    # Create request from template
    log_step "Step 1: Create Feature Request"

    mkdir -p "$AI_DIR/requests"

    if [[ ! -f "$AI_DIR/requests/_TEMPLATE.md" ]]; then
        log_error "Request template not found: ai/requests/_TEMPLATE.md"
        exit 1
    fi

    # Copy template and replace placeholders
    sed "s/{{NAME}}/${NAME}/g" "$AI_DIR/requests/_TEMPLATE.md" > "$REQUEST_FILE"

    log_success "Created request: $REQUEST_FILE"
    echo ""
    echo -e "${YELLOW}ACTION REQUIRED:${NC}"
    echo "  Edit ai/requests/${FEATURE_ID}.md with your feature description"
    echo ""
    echo "  The template has placeholders - fill in:"
    echo "    - What the feature does"
    echo "    - User stories (if known)"
    echo "    - Any specific requirements"
    echo ""

    read -p "Press Enter after editing the request file..."

    # Verify the file was edited (simple check - file modified)
    if ! grep -qv "{{" "$REQUEST_FILE" 2>/dev/null; then
        log_warning "Request file may still contain template placeholders."
        read -p "Continue anyway? (y/N): " continue_anyway
        if [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]]; then
            echo ""
            echo "Edit the file and run:"
            echo "  ${CYAN}make build ID=$FEATURE_ID${NC}"
            exit 0
        fi
    fi

    log_step "Step 2: Build Feature"

    log_info "Starting build workflow..."
    echo ""

    # Hand off to simple_build
    exec "$SCRIPT_DIR/simple_build.sh" "$FEATURE_ID"
}

main "$@"
