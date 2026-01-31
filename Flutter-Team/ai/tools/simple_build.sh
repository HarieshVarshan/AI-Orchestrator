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

    if [[ -z "$ID" ]]; then
        log_error "Usage: $0 <feature_id>"
        echo ""
        echo "Examples:"
        echo "  $0 001_login"
        echo "  $0 002_profile"
        echo ""
        echo "Available features/requests:"
        echo ""
        echo "Features (ready to build):"
        ls -1 "$AI_DIR/features/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  $(basename "$f" .md)"
        done || echo "  (none)"
        echo ""
        echo "Requests (need spec generation):"
        ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  $(basename "$f" .md)"
        done || echo "  (none)"
        exit 1
    fi

    # Parse ID to extract numeric part and name
    local ID_NUM="${ID%%_*}"
    local ID_NAME="${ID#*_}"

    echo ""
    echo -e "${BOLD}Flutter Android AI Orchestration - Build Feature${NC}"
    echo "================================================="
    echo ""
    log_info "Building feature: $ID"

    # Check if feature spec exists
    if [[ -f "$AI_DIR/features/${ID}.md" ]]; then
        log_success "Feature spec found: ai/features/${ID}.md"
        log_info "Starting feature workflow..."
        echo ""

        # Run the feature workflow directly
        exec "$SCRIPT_DIR/orchestrate_feature.sh" "$ID"

    # Check if request exists (need to generate spec first)
    elif [[ -f "$AI_DIR/requests/${ID}.md" ]]; then
        log_info "Found request file: ai/requests/${ID}.md"
        log_info "Need to generate formal spec first."
        echo ""

        log_step "Step 1: Generate Formal Spec"

        echo -e "${CYAN}Run Claude Code with the spec generator prompt:${NC}"
        echo ""
        echo "claude --prompt \"\$(cat ai/prompts/generate_feature_spec.txt)\" \\"
        echo "  --context \"ID=$ID_NUM\" \\"
        echo "  --context \"NAME=$ID_NAME\" \\"
        echo "  --context \"REQUEST_FILE=ai/requests/${ID}.md\""
        echo ""

        read -p "Press Enter after spec generation is complete..."

        # Verify spec was created
        if [[ ! -f "$AI_DIR/features/${ID}.md" ]]; then
            log_error "Spec not generated. Expected: ai/features/${ID}.md"
            echo ""
            echo "Make sure Claude creates the file at: ai/features/${ID}.md"
            exit 1
        fi

        log_success "Spec generated: ai/features/${ID}.md"
        echo ""

        log_step "Step 2: Build Feature"

        log_info "Starting feature workflow..."
        echo ""

        # Run the feature workflow
        exec "$SCRIPT_DIR/orchestrate_feature.sh" "$ID"

    else
        log_error "No feature or request found for: $ID"
        echo ""
        echo "Expected one of:"
        echo "  - ai/features/${ID}.md (formal spec)"
        echo "  - ai/requests/${ID}.md (simple request)"
        echo ""
        echo "To create a new feature quickly, run:"
        echo ""
        echo "  ${CYAN}make quick ID=$ID_NUM NAME=$ID_NAME${NC}"
        echo ""
        echo "Or create a request first:"
        echo ""
        echo "  ${CYAN}make new-request ID=$ID_NUM NAME=$ID_NAME${NC}"
        exit 1
    fi
}

main "$@"
