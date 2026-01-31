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
        echo "Example: $0 001 login"
        echo ""
        echo "This will create: ai/features/001_login.md"
        exit 1
    fi

    local FEATURE_ID="${ID}_${NAME}"
    local FEATURE_FILE="$AI_DIR/features/${FEATURE_ID}.md"

    if [[ -f "$FEATURE_FILE" ]]; then
        echo "Feature already exists: $FEATURE_FILE"
        exit 1
    fi

    # Copy template
    cp "$AI_DIR/features/_TEMPLATE.md" "$FEATURE_FILE"

    # Replace placeholders
    sed -i "s/{{ID}}/${FEATURE_ID}/g" "$FEATURE_FILE"
    sed -i "s/{{FEATURE_NAME}}/${NAME}/g" "$FEATURE_FILE"

    log_success "Created feature file: $FEATURE_FILE"
    log_info "Edit the file to add feature requirements, then run:"
    echo "  make feature ID=${FEATURE_ID}"
}

main "$@"
