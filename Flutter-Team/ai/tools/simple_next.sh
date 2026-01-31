#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AI_DIR")"
APP_DIR="$PROJECT_ROOT/app"

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_suggestion() {
    echo -e "\n${GREEN}${BOLD}Suggested next step:${NC}"
    echo -e "  ${CYAN}$1${NC}"
    echo ""
}

count_files() {
    local pattern="$1"
    ls -1 $pattern 2>/dev/null | grep -v _TEMPLATE | wc -l || echo "0"
}

# Main script
main() {
    echo ""
    echo -e "${BOLD}Flutter Android AI Orchestration - What's Next?${NC}"
    echo "================================================"
    echo ""

    # Read current state
    local current_task=""
    local task_type=""
    local stage=""

    if [[ -f "$AI_DIR/state.json" ]]; then
        current_task=$(grep -o '"current_task": *"[^"]*"' "$AI_DIR/state.json" 2>/dev/null | cut -d'"' -f4 || echo "")
        task_type=$(grep -o '"task_type": *"[^"]*"' "$AI_DIR/state.json" 2>/dev/null | cut -d'"' -f4 || echo "")
        stage=$(grep -o '"stage": *"[^"]*"' "$AI_DIR/state.json" 2>/dev/null | cut -d'"' -f4 || echo "idle")
    fi

    # Count resources
    local feature_count=$(count_files "$AI_DIR/features/*.md")
    local request_count=$(count_files "$AI_DIR/requests/*.md")
    local bug_count=$(count_files "$AI_DIR/bugs/*.md")
    local has_app_idea=false
    local has_roadmap=false

    [[ -f "$AI_DIR/planning/app_idea.md" ]] && has_app_idea=true
    [[ -f "$AI_DIR/planning/feature_roadmap.md" ]] && has_roadmap=true

    # Print current status
    echo -e "${BOLD}Current Status:${NC}"
    echo ""

    if [[ "$stage" != "idle" && -n "$current_task" && "$current_task" != "null" ]]; then
        echo -e "  ${YELLOW}In Progress:${NC} $current_task ($task_type)"
        echo -e "  ${YELLOW}Stage:${NC}       $stage"
    else
        echo -e "  ${DIM}No active task${NC}"
    fi

    echo ""
    echo -e "${BOLD}Project State:${NC}"
    echo ""
    echo -e "  App Idea:     $( $has_app_idea && echo -e "${GREEN}Yes${NC}" || echo -e "${DIM}No${NC}" )"
    echo -e "  Roadmap:      $( $has_roadmap && echo -e "${GREEN}Yes${NC}" || echo -e "${DIM}No${NC}" )"
    echo -e "  Requests:     $request_count"
    echo -e "  Features:     $feature_count"
    echo -e "  Bugs:         $bug_count"
    echo -e "  Flutter App:  $( [[ -d "$APP_DIR" && -f "$APP_DIR/pubspec.yaml" ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${DIM}No${NC}" )"

    echo ""
    echo "---"

    # Determine suggestion based on state

    # Case 1: Work in progress
    if [[ "$stage" != "idle" && "$stage" != "complete" && -n "$current_task" && "$current_task" != "null" ]]; then
        echo ""
        echo -e "${YELLOW}You have work in progress!${NC}"
        echo ""
        echo "Current task: $current_task"
        echo "Stage: $stage"
        echo ""

        case "$stage" in
            "implementing")
                echo "Complete the implementation, then the script will continue."
                ;;
            "reviewing")
                echo "Complete all reviews, then the script will continue."
                ;;
            "fixing")
                echo "Apply the fixes based on review feedback."
                ;;
            "testing")
                echo "Create tests for the feature."
                ;;
            "committing")
                echo "Create the commit with proper format."
                ;;
            *)
                echo "Continue with the workflow prompts."
                ;;
        esac

        print_suggestion "Continue the workflow in your terminal"

        echo -e "${DIM}To start fresh: make -f ai/Makefile.ai reset-state${NC}"
        return
    fi

    # Case 2: Just completed a task
    if [[ "$stage" == "complete" && -n "$current_task" && "$current_task" != "null" ]]; then
        echo ""
        log_success "Task completed: $current_task"
        echo ""

        # Reset state
        echo '{"current_task": null, "task_type": null, "stage": "idle", "last_updated": null, "history": []}' > "$AI_DIR/state.json"

        if [[ "$request_count" -gt "0" ]]; then
            local next_request=$(ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE | head -1 | xargs basename 2>/dev/null | sed 's/.md$//')
            if [[ -n "$next_request" ]]; then
                print_suggestion "make -f ai/Makefile.ai build ID=$next_request"
                return
            fi
        fi

        print_suggestion "make -f ai/Makefile.ai quick ID=XXX NAME=next_feature"
        return
    fi

    # Case 3: No app idea yet - brand new project
    if [[ "$has_app_idea" == false ]]; then
        echo ""
        echo -e "${YELLOW}Looks like a new project!${NC}"
        echo ""
        echo "Start by planning your app:"
        print_suggestion "make -f ai/Makefile.ai start"

        echo "Or jump straight to building a feature:"
        echo -e "  ${CYAN}make -f ai/Makefile.ai quick ID=001 NAME=your_feature${NC}"
        return
    fi

    # Case 4: Has idea but no roadmap
    if [[ "$has_app_idea" == true && "$has_roadmap" == false ]]; then
        echo ""
        echo -e "${YELLOW}You have an app idea but no roadmap.${NC}"
        echo ""
        echo "Generate your feature roadmap:"
        print_suggestion "make -f ai/Makefile.ai start"
        return
    fi

    # Case 5: Has roadmap but no requests
    if [[ "$has_roadmap" == true && "$request_count" -eq "0" && "$feature_count" -eq "0" ]]; then
        echo ""
        echo -e "${YELLOW}You have a roadmap but no feature requests.${NC}"
        echo ""
        echo "Convert your roadmap to feature requests:"
        print_suggestion "make -f ai/Makefile.ai start"
        return
    fi

    # Case 6: Has requests ready to build
    if [[ "$request_count" -gt "0" ]]; then
        echo ""
        echo -e "${GREEN}You have feature requests ready to build!${NC}"
        echo ""
        echo "Available requests:"
        ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  - $(basename "$f" .md)"
        done
        echo ""

        local first_request=$(ls -1 "$AI_DIR/requests/"*.md 2>/dev/null | grep -v _TEMPLATE | head -1 | xargs basename 2>/dev/null | sed 's/.md$//')
        if [[ -n "$first_request" ]]; then
            print_suggestion "make -f ai/Makefile.ai build ID=$first_request"
        fi
        return
    fi

    # Case 7: Has feature specs ready
    if [[ "$feature_count" -gt "0" ]]; then
        echo ""
        echo -e "${GREEN}You have feature specs ready to build!${NC}"
        echo ""
        echo "Available features:"
        ls -1 "$AI_DIR/features/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  - $(basename "$f" .md)"
        done
        echo ""

        local first_feature=$(ls -1 "$AI_DIR/features/"*.md 2>/dev/null | grep -v _TEMPLATE | head -1 | xargs basename 2>/dev/null | sed 's/.md$//')
        if [[ -n "$first_feature" ]]; then
            print_suggestion "make -f ai/Makefile.ai build ID=$first_feature"
        fi
        return
    fi

    # Case 8: Has bugs to fix
    if [[ "$bug_count" -gt "0" ]]; then
        echo ""
        echo -e "${YELLOW}You have bugs to fix!${NC}"
        echo ""
        echo "Available bugs:"
        ls -1 "$AI_DIR/bugs/"*.md 2>/dev/null | grep -v _TEMPLATE | while read f; do
            echo "  - $(basename "$f" .md)"
        done
        echo ""

        local first_bug=$(ls -1 "$AI_DIR/bugs/"*.md 2>/dev/null | grep -v _TEMPLATE | head -1 | xargs basename 2>/dev/null | sed 's/.md$//')
        if [[ -n "$first_bug" ]]; then
            print_suggestion "make -f ai/Makefile.ai bug ID=$first_bug"
        fi
        return
    fi

    # Case 9: Everything done or empty state
    echo ""
    echo -e "${GREEN}All caught up!${NC}"
    echo ""
    echo "Options:"
    echo "  - Create a new feature:  ${CYAN}make -f ai/Makefile.ai quick ID=XXX NAME=feature_name${NC}"
    echo "  - Report a bug:          ${CYAN}make -f ai/Makefile.ai fix ID=XXX NAME=bug_name${NC}"
    echo "  - Start fresh planning:  ${CYAN}make -f ai/Makefile.ai start${NC}"
    echo ""
}

main "$@"
