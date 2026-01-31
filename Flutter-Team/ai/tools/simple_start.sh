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

update_state() {
    local stage="$1"
    local task_id="$2"
    local timestamp=$(date -Iseconds)

    cat > "$AI_DIR/state.json" << EOF
{
  "current_task": "$task_id",
  "task_type": "planning",
  "stage": "$stage",
  "last_updated": "$timestamp",
  "history": []
}
EOF
}

# Main script
main() {
    echo ""
    echo -e "${BOLD}Flutter Android AI Orchestration - Quick Start${NC}"
    echo "================================================"
    echo ""
    log_info "This will guide you through the full app planning flow."
    echo ""

    # Step 1: Check if app_idea.md exists
    log_step "Step 1: App Idea"

    if [[ ! -f "$AI_DIR/planning/app_idea.md" ]]; then
        log_warning "No app idea found."
        log_info "Creating app idea template..."

        mkdir -p "$AI_DIR/planning"

        if [[ -f "$AI_DIR/planning/_APP_IDEA_TEMPLATE.md" ]]; then
            cp "$AI_DIR/planning/_APP_IDEA_TEMPLATE.md" "$AI_DIR/planning/app_idea.md"
            log_success "Created: ai/planning/app_idea.md"
            echo ""
            echo -e "${YELLOW}ACTION REQUIRED:${NC}"
            echo "  1. Edit ai/planning/app_idea.md with your app concept"
            echo "  2. Run 'make start' again when done"
            echo ""
            exit 0
        else
            log_error "Template not found: ai/planning/_APP_IDEA_TEMPLATE.md"
            exit 1
        fi
    fi

    log_success "Found app idea: ai/planning/app_idea.md"

    # Step 2: Generate feature roadmap
    log_step "Step 2: Generate Feature Roadmap"

    if [[ -f "$AI_DIR/planning/feature_roadmap.md" ]]; then
        log_info "Feature roadmap already exists."
        read -p "Regenerate roadmap? (y/N): " regenerate
        if [[ "$regenerate" != "y" && "$regenerate" != "Y" ]]; then
            log_info "Keeping existing roadmap."
        else
            log_info "Will regenerate roadmap..."
            rm -f "$AI_DIR/planning/feature_roadmap.md"
        fi
    fi

    if [[ ! -f "$AI_DIR/planning/feature_roadmap.md" ]]; then
        update_state "planning" "app_roadmap"

        echo ""
        echo -e "${CYAN}Run Claude Code with the app planner prompt:${NC}"
        echo ""
        echo "claude --prompt \"\$(cat ai/prompts/plan_app.txt)\" \\"
        echo "  --context \"APP_IDEA_FILE=ai/planning/app_idea.md\" \\"
        echo "  --context \"REFERENCE_DIR=reference/\""
        echo ""

        read -p "Press Enter after roadmap generation is complete..."

        if [[ ! -f "$AI_DIR/planning/feature_roadmap.md" ]]; then
            log_error "Roadmap not generated. Please run the Claude command above."
            exit 1
        fi
    fi

    log_success "Feature roadmap ready!"

    # Step 3: Convert to feature requests
    log_step "Step 3: Convert Roadmap to Feature Requests"

    # Check for existing requests
    existing_requests=$(ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE || true)

    if [[ -n "$existing_requests" ]]; then
        log_info "Existing feature requests found:"
        echo "$existing_requests" | head -10
        echo ""
        read -p "Generate more requests from roadmap? (y/N): " generate_more
        if [[ "$generate_more" != "y" && "$generate_more" != "Y" ]]; then
            log_info "Skipping request generation."
        fi
    fi

    if [[ -z "$existing_requests" ]] || [[ "$generate_more" == "y" ]] || [[ "$generate_more" == "Y" ]]; then
        update_state "roadmap_to_requests" "app_roadmap"

        echo ""
        echo -e "${CYAN}Choose priority level:${NC}"
        echo "  P0  - MVP features only (recommended to start)"
        echo "  P1  - MVP + Important features"
        echo "  ALL - All features"
        echo ""
        read -p "Priority [P0]: " priority
        priority=${priority:-P0}

        echo ""
        echo -e "${CYAN}Run Claude Code with the roadmap converter prompt:${NC}"
        echo ""
        echo "claude --prompt \"\$(cat ai/prompts/roadmap_to_requests.txt)\" \\"
        echo "  --context \"ROADMAP_FILE=ai/planning/feature_roadmap.md\" \\"
        echo "  --context \"PRIORITY=$priority\" \\"
        echo "  --context \"REQUEST_TEMPLATE=ai/requests/_TEMPLATE.md\""
        echo ""

        read -p "Press Enter after request generation is complete..."
    fi

    # Step 4: Show results and next steps
    log_step "Planning Complete!"

    update_state "idle" null

    echo -e "${GREEN}Your feature requests:${NC}"
    ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
        basename "$f" .md
    done
    echo ""

    echo -e "${BOLD}Next Steps:${NC}"
    echo ""
    echo "  1. Review your feature requests in ai/requests/"
    echo "  2. Pick a feature and build it:"
    echo ""
    echo "     ${CYAN}make build ID=001_feature_name${NC}"
    echo ""
    echo "  Or create a quick feature without planning:"
    echo ""
    echo "     ${CYAN}make quick ID=002 NAME=new_feature${NC}"
    echo ""
    echo "  Need guidance? Run:"
    echo ""
    echo "     ${CYAN}make next${NC}"
    echo ""
}

main "$@"
