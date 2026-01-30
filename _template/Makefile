# Project Makefile Template
# Add your project-specific commands here

SHELL := /bin/bash
.DEFAULT_GOAL := help

PROJECT_DIR := project

.PHONY: help
help: ## Show this help
	@echo ""
	@echo "Project Commands"
	@echo "================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""
	@if [ -f "ai/Makefile.ai" ]; then \
		echo "AI orchestration: make -f ai/Makefile.ai help"; \
		echo ""; \
	fi

# =============================================================================
# Add your project-specific targets below
# =============================================================================

.PHONY: build
build: ## Build the project
	@echo "TODO: Add build command"

.PHONY: test
test: ## Run tests
	@echo "TODO: Add test command"

.PHONY: run
run: ## Run the project
	@echo "TODO: Add run command"

.PHONY: clean
clean: ## Clean build artifacts
	@echo "TODO: Add clean command"
