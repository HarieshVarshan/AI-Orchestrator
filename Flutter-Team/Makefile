# Flutter Project Makefile
# Standard Flutter commands for your project

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Directories
APP_DIR := app

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
CYAN := \033[0;36m
BOLD := \033[1m
DIM := \033[2m
NC := \033[0m

.PHONY: help
help: ## Show this help message
	@echo ""
	@echo "$(BOLD)Flutter Project Commands$(NC)"
	@echo "========================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@if [ -f "ai/Makefile.ai" ]; then \
		echo "$(DIM)AI orchestration: make -f ai/Makefile.ai help$(NC)"; \
		echo ""; \
	fi

# =============================================================================
# Flutter Commands - Common
# =============================================================================

.PHONY: analyze
analyze: ## Run flutter analyze
	@cd $(APP_DIR) && flutter analyze

.PHONY: test
test: ## Run flutter test
	@cd $(APP_DIR) && flutter test

.PHONY: check
check: analyze test ## Run analyze and test

.PHONY: run
run: ## Run app on connected device
	@cd $(APP_DIR) && flutter run

.PHONY: clean
clean: ## Clean Flutter build artifacts
	@cd $(APP_DIR) && flutter clean

.PHONY: deps
deps: ## Get Flutter dependencies
	@cd $(APP_DIR) && flutter pub get

.PHONY: upgrade
upgrade: ## Upgrade Flutter dependencies
	@cd $(APP_DIR) && flutter pub upgrade

.PHONY: outdated
outdated: ## Check for outdated dependencies
	@cd $(APP_DIR) && flutter pub outdated

# =============================================================================
# Android Builds
# =============================================================================

.PHONY: apk
apk: ## Build debug APK (Android)
	@cd $(APP_DIR) && flutter build apk --debug

.PHONY: apk-release
apk-release: ## Build release APK (Android)
	@cd $(APP_DIR) && flutter build apk --release

.PHONY: appbundle
appbundle: ## Build release App Bundle (Android - Play Store)
	@cd $(APP_DIR) && flutter build appbundle --release

# =============================================================================
# iOS Builds
# =============================================================================

.PHONY: ios
ios: ## Build iOS app (debug)
	@cd $(APP_DIR) && flutter build ios --debug --no-codesign

.PHONY: ios-release
ios-release: ## Build iOS app (release)
	@cd $(APP_DIR) && flutter build ios --release

.PHONY: ipa
ipa: ## Build IPA for App Store
	@cd $(APP_DIR) && flutter build ipa --release

# =============================================================================
# Web Builds
# =============================================================================

.PHONY: web
web: ## Build web app (debug)
	@cd $(APP_DIR) && flutter build web

.PHONY: web-release
web-release: ## Build web app (release, optimized)
	@cd $(APP_DIR) && flutter build web --release --web-renderer canvaskit

.PHONY: serve
serve: ## Serve web app locally
	@cd $(APP_DIR) && flutter run -d chrome

# =============================================================================
# Multi-Platform
# =============================================================================

.PHONY: build-all
build-all: ## Build all platforms (Android APK, iOS, Web)
	@echo "Building Android..."
	@cd $(APP_DIR) && flutter build apk --release
	@echo "Building iOS..."
	@cd $(APP_DIR) && flutter build ios --release --no-codesign || echo "iOS build skipped (requires macOS)"
	@echo "Building Web..."
	@cd $(APP_DIR) && flutter build web --release
	@echo "All builds complete!"

.PHONY: devices
devices: ## List connected devices
	@flutter devices

# =============================================================================
# Project Setup
# =============================================================================

.PHONY: init-app
init-app: ## Initialize Flutter app (ORG=com.example optional)
	@if [ -d "$(APP_DIR)" ] && [ -f "$(APP_DIR)/pubspec.yaml" ]; then \
		echo "$(YELLOW)App already exists in $(APP_DIR)/$(NC)"; \
	else \
		echo "Creating Flutter app..."; \
		if [ -n "$(ORG)" ]; then \
			flutter create --org $(ORG) $(APP_DIR); \
		else \
			flutter create $(APP_DIR); \
		fi; \
		echo "$(GREEN)Flutter app created in $(APP_DIR)/$(NC)"; \
	fi
