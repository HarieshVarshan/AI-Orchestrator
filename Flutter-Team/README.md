# Flutter AI Orchestration Framework

A production-grade framework for AI-driven Flutter development across **Android, iOS, and Web**. Uses Claude Code CLI with defined agent roles and orchestration scripts for deterministic, reproducible development workflows.

## Overview

This framework implements an AI orchestration pattern where:
- **Files = Memory**: Markdown specs and review files serve as shared state
- **Prompts = Role Boundaries**: Each agent has a specific, locked-down role
- **Scripts = Control Flow**: Bash scripts orchestrate the development pipeline
- **Git = Audit Log**: All changes are tracked with proper commits

## Quick Start

### Two Makefiles, Clean Separation

| Makefile | Purpose | Usage |
|----------|---------|-------|
| `Makefile` | Flutter commands (analyze, test, apk, run) | `make <target>` |
| `ai/Makefile.ai` | AI orchestration (planning, features, bugs) | `make -f ai/Makefile.ai <target>` |

This keeps your Flutter project clean - AI orchestration is isolated in `ai/`.

### Fastest Path: Idea to Feature

```bash
# 1. Initialize your Flutter app (one time)
make init-app ORG=com.yourcompany

# 2. Plan your app (creates roadmap and feature requests)
make -f ai/Makefile.ai start

# 3. Build your first feature
make -f ai/Makefile.ai build ID=001_login

# Lost? Ask for guidance
make -f ai/Makefile.ai next
```

### Quick Feature (Skip Planning)

```bash
# Create and build a feature in one command
make -f ai/Makefile.ai quick ID=001 NAME=login
```

### Quick Bug Fix

```bash
# Create bug spec and start fixing
make -f ai/Makefile.ai fix ID=003 NAME=login_crash
```

### Flutter Commands

```bash
make analyze      # Run flutter analyze
make test         # Run flutter test
make apk          # Build debug APK
make run          # Run on device
```

---

## Command Reference

### AI Orchestration (`make -f ai/Makefile.ai`)

| Command | What it does |
|---------|--------------|
| `start` | Full planning flow: idea → roadmap → feature requests |
| `build ID=xxx` | Build a feature (auto-generates spec if needed) |
| `quick ID=xxx NAME=yyy` | Create + build feature in one go |
| `next` | Smart suggestions based on project state |
| `fix ID=xxx NAME=yyy` | Quick bug fix workflow |

### Flutter (`make`)

| Command | What it does |
|---------|--------------|
| `analyze` | Run flutter analyze |
| `test` | Run flutter test |
| `check` | Run analyze + test |
| `apk` | Build debug APK |
| `apk-release` | Build release APK |
| `run` | Run on device |

---

## Power User Commands

For fine-grained control over AI orchestration:

### Plan Your App (Step by Step)

```bash
# Create app idea file
make -f ai/Makefile.ai new-idea

# Fill in your app concept
vim ai/planning/app_idea.md

# (Optional) Analyze reference apps for inspiration
make -f ai/Makefile.ai analyze-refs

# Generate comprehensive feature roadmap
make -f ai/Makefile.ai plan-app

# Auto-generate feature requests from roadmap
make -f ai/Makefile.ai roadmap-to-requests              # P0 (MVP) features only
make -f ai/Makefile.ai roadmap-to-requests PRIORITY=P1  # Include P1 features
make -f ai/Makefile.ai roadmap-to-requests PRIORITY=ALL # All features
```

### Create a Feature (Step by Step)

**Option A: Easy Way (Recommended for beginners)**
```bash
make -f ai/Makefile.ai new-request ID=001 NAME=login
vim ai/requests/001_login.md
make -f ai/Makefile.ai generate-spec ID=001 NAME=login
make -f ai/Makefile.ai feature ID=001_login
```

**Option B: Full Template (For detailed specs)**
```bash
make -f ai/Makefile.ai new-feature ID=001 NAME=login
vim ai/features/001_login.md
make -f ai/Makefile.ai feature ID=001_login
```

### Fix a Bug (Step by Step)

```bash
make -f ai/Makefile.ai new-bug ID=003 NAME=login_crash
vim ai/bugs/003_login_crash.md
make -f ai/Makefile.ai bug ID=003_login_crash
```

## Directory Structure

```
Flutter-Android-Team/
├── ai/                     # AI Orchestration (gitignored in app repos)
│   ├── Makefile.ai         # AI orchestration commands
│   ├── tools/              # Orchestration scripts
│   ├── prompts/            # Agent role prompts
│   ├── planning/           # App planning (pre-development)
│   ├── requests/           # Simple feature requests
│   ├── features/           # Formal feature specs (TRACK THESE)
│   ├── bugs/               # Bug specifications (TRACK THESE)
│   ├── decisions/          # Decision documentation (TRACK THESE)
│   ├── reviews/            # Generated review files
│   ├── session-logs/       # Development session logs
│   └── state.json          # Orchestration state
├── app/                    # Flutter application (tracked)
├── reference/              # Reference materials (gitignored)
├── templates/              # Templates for new projects
│   └── gitignore.template  # .gitignore for app repos
├── docs/                   # Documentation
├── Makefile                # Flutter commands only
├── CLAUDE.md               # AI guidelines
└── README.md               # This file
```

### What Gets Tracked in App Repos

| Tracked | Gitignored |
|---------|------------|
| `app/` (Flutter code) | `ai/tools/`, `ai/prompts/` (framework) |
| `ai/features/` (specs) | `ai/planning/`, `ai/requests/` (intermediate) |
| `ai/bugs/` (specs) | `ai/reviews/`, `ai/session-logs/` (working files) |
| `ai/decisions/` (audit) | `ai/state.json`, `ai/Makefile.ai` |
| `Makefile` (Flutter) | `reference/`, `CLAUDE.md` |

> **Starting a new project?** See `docs/PROJECT_SETUP.md` for setup instructions.

## Workflow Architecture

### App Planning Pipeline (Pre-Development)

```
App Idea → Reference Analysis (Optional) → Feature Discovery → Prioritization → Originality Check → Feature Roadmap → Feature Requests
```

### Frontend-Only Feature Pipeline

```
Feature Spec → Implement → Review (10 parallel) → Fix → Test → Test Review → Commit → Changelog → Session Log → Docs
```

### Full-Stack Feature Pipeline

```
Feature Spec → Database Design → DB Reviews → Backend Implement → Backend Reviews → Frontend Implement → Frontend Reviews (10) → DevOps Reviews (4) → Test → Production Readiness (4) → Commit
```

### Bug Fix Pipeline

```
Bug Spec → Fix (with test) → Safety Review → Fix Review → Test Review → Commit → Changelog → Session Log
```

## Agent Roles

| Agent | Responsibility | Output |
|-------|---------------|--------|
| **Planners** | | |
| App Planner | Comprehensive feature discovery & prioritization | `planning/feature_roadmap.md` |
| Reference Analyzer | Extract features from reference apps | `planning/reference_analysis.md` |
| Roadmap Converter | Convert roadmap features to request files | `requests/{ID}_{name}.md` |
| **Generators** | | |
| Spec Generator | Convert simple request to formal spec | `features/{ID}_{name}.md` |
| **Implementers** | | |
| Frontend Implementer | Code Flutter feature per spec | Modified code files |
| Backend Implementer | Code API endpoints per spec | Modified code files |
| Database Designer | Design database schema | `{ID}_database_schema.md` |
| **Frontend Core Reviewers** | | |
| Safety Reviewer | Security audit | `{ID}_safety.md` |
| Architecture Reviewer | Code structure | `{ID}_architecture.md` |
| Play Store Reviewer | Policy compliance | `{ID}_playstore.md` |
| UI Reviewer | UX and accessibility | `{ID}_ui.md` |
| Android Reviewer | Android platform-specific | `{ID}_android.md` |
| iOS Reviewer | iOS platform-specific | `{ID}_ios.md` |
| Web Reviewer | Web platform-specific | `{ID}_web.md` |
| Originality Reviewer | IP/copycat detection | `{ID}_originality.md` |
| **Frontend Production Reviewers** | | |
| API Integration Reviewer | Backend integration | `{ID}_api.md` |
| Auth Flow Reviewer | Authentication security | `{ID}_auth.md` |
| Data Layer Reviewer | Storage & state | `{ID}_data.md` |
| Production Reviewer | Release readiness | `{ID}_production.md` |
| **Backend Reviewers** | | |
| API Design Reviewer | RESTful conventions | `{ID}_api_design.md` |
| Backend Security Reviewer | OWASP Top 10 | `{ID}_backend_security.md` |
| **Database Reviewers** | | |
| Database Schema Reviewer | Schema design quality | `{ID}_database_schema.md` |
| Migration Safety Reviewer | Zero-downtime migrations | `{ID}_migrations.md` |
| **DevOps Reviewers** | | |
| CI/CD Pipeline Reviewer | Build & deployment automation | `{ID}_cicd.md` |
| Docker/Container Reviewer | Container security & efficiency | `{ID}_docker.md` |
| Environment Config Reviewer | Secret & config management | `{ID}_environment.md` |
| Deployment Safety Reviewer | Release & rollback safety | `{ID}_deployment.md` |
| **Release Validation Reviewers** | | |
| Performance Reviewer | App performance optimization | `{ID}_performance.md` |
| Accessibility Reviewer | WCAG compliance | `{ID}_accessibility.md` |
| Localization Reviewer | i18n/l10n readiness | `{ID}_localization.md` |
| Production Checklist | Final release validation | `{ID}_production_checklist.md` |
| **Other Agents** | | |
| Fixer | Address review comments | Modified code files |
| Tester | Create comprehensive tests | Test files |
| Test Reviewer | Test quality audit | `{ID}_tests.md` |
| Committer | Git commit | Commit with message |
| Changelog | Update CHANGELOG.md | Changelog entry |
| Session Logger | Document session | Session log file |
| Doc Creator | Developer docs | Feature documentation |

## Make Commands

### Flutter Commands (`make`)
```bash
make analyze        # Run flutter analyze
make test           # Run flutter test
make check          # Run both
make apk            # Build debug APK (Android)
make apk-release    # Build release APK (Android)
make appbundle      # Build release App Bundle (Play Store)
make ios            # Build iOS app (debug)
make ios-release    # Build iOS app (release)
make ipa            # Build IPA (App Store)
make web            # Build web app
make web-release    # Build optimized web app
make build-all      # Build all platforms
make run            # Run on device
make serve          # Run web app in Chrome
make devices        # List connected devices
make deps           # Get dependencies
make clean          # Clean build artifacts
make init-app       # Initialize Flutter app (ORG=com.example optional)
```

### AI Orchestration Commands (`make -f ai/Makefile.ai`)

**Simple Commands (Recommended):**
```bash
make -f ai/Makefile.ai start                  # Plan your app
make -f ai/Makefile.ai build ID=001_login     # Build a feature
make -f ai/Makefile.ai quick ID=001 NAME=x    # Create + build
make -f ai/Makefile.ai next                   # What's next?
make -f ai/Makefile.ai fix ID=003 NAME=crash  # Quick bug fix
```

**Planning:**
```bash
make -f ai/Makefile.ai new-idea               # Create app idea file
make -f ai/Makefile.ai analyze-refs           # Analyze reference apps
make -f ai/Makefile.ai plan-app               # Generate feature roadmap
make -f ai/Makefile.ai roadmap-to-requests    # Convert roadmap to requests
```

**Features:**
```bash
make -f ai/Makefile.ai new-request ID=001 NAME=login
make -f ai/Makefile.ai generate-spec ID=001 NAME=login
make -f ai/Makefile.ai feature ID=001_login
make -f ai/Makefile.ai fullstack ID=001_login
```

**Bugs:**
```bash
make -f ai/Makefile.ai new-bug ID=003 NAME=crash
make -f ai/Makefile.ai bug ID=003_crash
```

**State & Reviews:**
```bash
make -f ai/Makefile.ai status                 # Show current state
make -f ai/Makefile.ai reset-state            # Reset to idle
make -f ai/Makefile.ai list-reviews           # List all reviews
make -f ai/Makefile.ai clean-reviews          # Remove reviews
```

## Feature Specification Template

```markdown
# Feature ID: 001
## Name: Login Screen

### Objective
Allow user to log in using email and password.

### UI Requirements
- Email TextField
- Password TextField (obscured)
- Login Button

### Functional Requirements
- Validate email format
- Password minimum 8 characters
- Disable button when invalid

### State Management
- Pattern: ChangeNotifier
- External packages: No

### Out of Scope
- API integration
- Persistent storage

### Acceptance Criteria
- [ ] App builds successfully
- [ ] flutter analyze passes
- [ ] UI works on Android emulator
```

## Bug Specification Template

```markdown
# Bug ID: 003
## Title: Login screen crashes on empty submit

### Reproduction Steps
1. Open app
2. Navigate to Login
3. Click Login without data

### Expected Behavior
Error message shown, no crash

### Actual Behavior
App crashes

### Scope
Login feature only
```

## Using with Claude Code CLI

The orchestration scripts guide you through running Claude Code at each stage:

```bash
# Example: Implement feature
claude --prompt "$(cat ai/prompts/implement.txt)" \
  --context "FEATURE_FILE=ai/features/001_login.md" \
  --context "ID=001_login" \
  --context "FEATURE_NAME=login"
```

## Quality Gates

Each workflow includes automatic checks:
- `flutter analyze` - Static analysis
- `flutter test` - Unit and widget tests
- Review completion - All critical issues addressed
- Proper commits - Conventional commit format

## Best Practices

1. **Write complete specs**: The AI can only implement what's specified
2. **Review the reviews**: AI reviews catch issues but need human validation
3. **Track decisions**: Document why, not just what
4. **Keep specs focused**: One feature = one spec
5. **Use conventional commits**: Maintain clean git history

## Customization

### Adding Review Types
1. Create new prompt in `ai/prompts/review_{type}.txt`
2. Update orchestration scripts to include new reviewer
3. Follow existing review output format

### Modifying Workflow
1. Edit `tools/orchestrate_feature.sh` or `tools/orchestrate_bug.sh`
2. Add/remove stages as needed
3. Update Makefile if new commands needed

## Troubleshooting

### Workflow Stuck
```bash
make status           # Check current state
make reset-state      # Reset and restart
```

### Flutter Checks Failing
```bash
make analyze          # See analyze output
make test             # See test output
```

### Missing Reviews
Check that Claude Code completed the review stage and wrote to `ai/reviews/`.

## License

MIT

## Contributing

1. Fork the repository
2. Create feature branch
3. Follow the framework's own workflow
4. Submit pull request
