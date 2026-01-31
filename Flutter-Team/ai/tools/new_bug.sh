#!/bin/bash
set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

main() {
    local ID="$1"
    local NAME="$2"

    if [[ -z "$ID" ]] || [[ -z "$NAME" ]]; then
        echo "Usage: $0 <id> <name>"
        echo "Example: $0 003 login_crash"
        echo ""
        echo "This will create: ai/bugs/003_login_crash.md"
        exit 1
    fi

    local BUG_ID="${ID}_${NAME}"
    local BUG_FILE="$AI_DIR/bugs/${BUG_ID}.md"

    if [[ -f "$BUG_FILE" ]]; then
        echo "Bug already exists: $BUG_FILE"
        exit 1
    fi

    # Copy template
    cp "$AI_DIR/bugs/_TEMPLATE.md" "$BUG_FILE"

    # Replace placeholders
    sed -i "s/{{ID}}/${BUG_ID}/g" "$BUG_FILE"
    sed -i "s/{{BUG_TITLE}}/${NAME}/g" "$BUG_FILE"

    log_success "Created bug file: $BUG_FILE"
    log_info "Edit the file to add bug details, then run:"
    echo "  make bug ID=${BUG_ID}"
}

main "$@"
