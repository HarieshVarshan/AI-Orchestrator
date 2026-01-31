# CLAUDE.md - AI Orchestration Guidelines

This document provides guidelines for Claude Code when working on this Flutter project.

> **Important:** Also read `PROJECT.md` for project-specific instructions (build commands, architecture, conventions). This file (CLAUDE.md) contains framework instructions and is synced from the template. PROJECT.md contains your project-specific details and is never synced.

## Project Overview

This is an AI-orchestrated Flutter development framework. AI agents work in defined roles with specific responsibilities, orchestrated by scripts to ensure deterministic, reproducible development.

---

## 🚀 First Time Setup (Read This First!)

**When the user says "help me set up" or "I just cloned this" or "let's start":**

### Step 1: Check project state
```bash
git remote -v              # Check if pointing to template repo
ls -la .gitignore          # Check if gitignore exists
ls ai/features/            # Check for example files
ls app/pubspec.yaml        # Check if Flutter app exists
```

### Step 2: Show examples and ask about cleanup

The template includes example files for reference:
- `ai/features/001_login.md` - Example feature spec
- `ai/bugs/_TEMPLATE.md` - Bug template

**Ask the user:**
> "I see example files in the template. Would you like to:
> 1. Keep them for reference
> 2. Remove them to start clean
> ?"

If they want to remove:
```bash
rm ai/features/001_login.md
# Keep _TEMPLATE.md files - those are useful
```

### Step 3: Collect user information

**Ask the user for:**
- Git name (for commits)
- Git email (for commits)
- Organization name (for Flutter app, e.g., `com.yourcompany`)
- Remote repo URL (optional, can add later)

### Step 4: Run setup (in order)
```bash
# 1. Disconnect from template (if remote points to template)
rm -rf .git

# 2. Setup gitignore
cp templates/gitignore.template .gitignore

# 3. Initialize git
git init
git config --local user.name "User Name"
git config --local user.email "user@email.com"

# 4. First commit
git add .
git commit -s -m "chore: initialize project from Flutter-Team framework

- Set up AI orchestration structure
- Configure gitignore for AI files and secrets

Task-ID: 000_init"

# 5. Add remote (if provided)
git remote add origin <user-provided-url>
git push -u origin master

# 6. Create Flutter app
make init-app ORG=<user-provided-org>
```

### Step 5: Ask what to do next

**After setup is complete, ask the user:**
> "Setup complete! What would you like to do next?
> 1. Create a new feature spec (`make new-feature ID=001 NAME=...`)
> 2. Clone reference apps to `reference/repos/`
> 3. Explore the project structure
> 4. Something else?
> "

**Do NOT assume** the user wants to create a feature immediately. Let them decide.

---

## 📋 Documentation Responsibilities

**When the user asks for changes outside the orchestration workflow (ad-hoc requests):**

Before making any code changes, remind the user:
> "I notice this isn't going through the standard workflow (`make feature` or `make bug`).
> Would you like to:
> 1. Create a proper feature/bug spec first (recommended for tracking)
> 2. Proceed with ad-hoc changes (I'll remind you about docs at commit time)
> ?"

**At commit time, ensure these are handled:**

| Item | Check |
|------|-------|
| `ai/decisions/{ID}.md` | Any assumptions documented? |
| `ai/session-logs/` | Session summary created? |
| `CHANGELOG.md` | Entry added for user-facing changes? |
| `PROJECT.md` | Architecture changes documented? |

**If user skips documentation, gently remind:**
> "Before we commit, should I create:
> - A session log summarizing what we did?
> - A decision doc for [assumption made]?
> - A changelog entry?
> "

---

## 🔄 Resuming Work (New Session)

**When the user says "where did we leave off", "what's the status", "continue", or starts a new session:**

### Step 1: Check these files to understand current state

| File/Folder | What it tells you |
|-------------|-------------------|
| `ai/state.json` | Current task ID, type, and stage (implementing/reviewing/fixing/etc.) |
| `ai/session-logs/` | Recent session summaries - read the latest one |
| `ai/features/*.md` | All planned/in-progress features (ignore `_TEMPLATE.md`) |
| `ai/bugs/*.md` | All reported bugs (ignore `_TEMPLATE.md`) |
| `ai/reviews/{ID}_*.md` | Review findings for a task - shows what needs fixing |
| `ai/decisions/{ID}.md` | Decisions made for a task - important context |
| `CHANGELOG.md` | What's been completed and released |
| `git log --oneline -10` | Recent commits - what was actually done |

### Step 2: Build context and summarize

```bash
# Check orchestration state
cat ai/state.json

# List recent session logs
ls -lt ai/session-logs/ | head -5

# List features (exclude template)
ls ai/features/*.md | grep -v _TEMPLATE

# List bugs (exclude template)
ls ai/bugs/*.md | grep -v _TEMPLATE

# Check for pending reviews
ls ai/reviews/

# Recent commits
git log --oneline -10
```

### Step 3: Report to user

Summarize findings like:
> "Here's the current project state:
>
> **Last session:** 2024-01-20 - Worked on feature 002_profile
> **Current task:** 002_profile (stage: reviewing)
> **Pending reviews:** 3 review files with findings
> **Features:** 2 specs (001_login ✅, 002_profile 🔄)
> **Bugs:** 1 spec (003_crash - pending)
>
> Would you like to:
> 1. Continue with 002_profile (address review comments)
> 2. Work on something else
> ?"

### Step 4: Read relevant files for context

Before continuing work, read:
1. The task's spec file (`ai/features/{ID}.md` or `ai/bugs/{ID}.md`)
2. Any review files (`ai/reviews/{ID}_*.md`)
3. Any decision files (`ai/decisions/{ID}.md`)
4. The latest session log for that task

This gives you full context to continue where the previous session left off.

---

## Usage Modes

This framework has two usage modes:

### 1. Reference Template (This Repository)
The `Flutter-Team/` folder itself is committed as a reference template. All files including `ai/prompts/`, `tools/`, and `templates/` are tracked.

### 2. New App Projects (Copies of This Framework)
When copying this folder to start a new app:
1. Copy the folder and rename to your app name
2. **CRITICAL**: Copy `templates/gitignore.template` to `.gitignore` BEFORE `git init`
3. This ensures AI working files and secrets are never committed

See `docs/PROJECT_SETUP.md` for detailed setup instructions.

### 3. Syncing Template Updates
If the template is updated and you want to sync changes to your project:
```bash
# First time: add template as remote
make sync-template URL=https://github.com/username/Flutter-Team.git

# Check for updates
make check-template

# Apply updates (syncs framework files, preserves your project files)
make sync-template
```

See `docs/PROJECT_SETUP.md` for details on what gets synced vs preserved.

## Directory Structure

```
Flutter-Team/
├── ai/                     # AI orchestration files
│   ├── requests/           # Simple feature requests (easy to fill)
│   ├── features/           # Formal feature specifications (source of truth)
│   ├── bugs/               # Bug specifications
│   ├── reviews/            # Generated review files (ignored in app repos)
│   ├── decisions/          # AI decision documentation
│   ├── prompts/            # Agent role prompts
│   ├── tests/              # Test-related specs
│   ├── changelogs/         # Change documentation (ignored in app repos)
│   ├── session-logs/       # Development session logs (ignored in app repos)
│   └── state.json          # Current orchestration state (ignored in app repos)
├── app/                    # Flutter application (created separately)
├── backend/                # Backend API (optional, for full-stack)
│   ├── src/                # Backend source code
│   └── tests/              # Backend tests
├── reference/              # Reference materials (ignored in app repos)
├── tools/                  # Orchestration scripts
├── templates/              # Templates for new projects
│   └── gitignore.template  # .gitignore template for app repos
├── docs/                   # Project documentation
│   └── PROJECT_SETUP.md    # How to set up new projects
└── Makefile                # One-line commands
```

## AI Modification Rules

### CAN Modify
- `app/lib/` - Flutter application source code
- `app/test/` - Flutter test files
- `backend/src/` - Backend source code
- `backend/tests/` - Backend test files
- `ai/reviews/` - Write review findings
- `ai/decisions/` - Document assumptions and decisions
- `ai/session-logs/` - Create session logs
- `CHANGELOG.md` - Update changelog

### CANNOT Modify
- `ai/features/*.md` - Feature specs (human-authored)
- `ai/bugs/*.md` - Bug specs (human-authored)
- `ai/prompts/*.txt` - Agent prompts (configuration)
- `tools/*.sh` - Orchestration scripts
- `Makefile` - Build configuration
- `CLAUDE.md` - This file

## Agent Roles

Each agent has a specific role. Stay within your role boundaries.

### Spec Generator
- Converts simple feature requests to formal specifications
- Infers missing details from best practices
- Marks inferences and items needing review
- Outputs to `ai/features/{ID}_{name}.md`

### Frontend Implementer
- Implements Flutter feature as specified
- Creates production code only
- No explanations in output

### Backend Implementer
- Implements API endpoints as specified
- Follows RESTful conventions
- Creates database models and migrations
- No explanations in output

### Database Designer
- Designs database schema from feature spec
- Creates ER diagrams and schema definitions
- Generates migrations
- Documents in `ai/decisions/{ID}_database_schema.md`

### Frontend Reviewers (12 specialized reviewers)
- Reviews Flutter code changes only
- Writes findings to review files
- Actionable feedback required

**Core Reviewers:**
- **Safety** - Security vulnerabilities, data protection
- **Architecture** - Code structure, patterns, maintainability
- **Play Store** - Policy compliance, store requirements
- **UI/UX** - User interface, accessibility, design
- **Android** - Android platform-specific issues, lifecycle
- **iOS** - iOS platform-specific issues, App Store compliance
- **Web** - Web platform issues, browser compatibility, PWA
- **Originality** - IP compliance, copycat prevention

**Production Reviewers:**
- **API Integration** - Backend integration, error handling, caching
- **Auth Flow** - Authentication security, token management, login/logout
- **Data Layer** - Local storage, state management, offline support
- **Production Readiness** - Monitoring, CI/CD, release config

### Backend Reviewers (2 specialized reviewers)
- Reviews backend code changes only
- Writes findings to review files
- Actionable feedback required

- **API Design** - RESTful conventions, status codes, pagination, versioning
- **Backend Security** - OWASP Top 10, injection, auth, input validation

### Database Reviewers (2 specialized reviewers)
- Reviews database schema and migrations
- Writes findings to review files
- Actionable feedback required

- **Database Schema** - Normalization, data types, indexes, constraints
- **Migration Safety** - Zero-downtime migrations, reversibility, data integrity

### DevOps Reviewers (4 specialized reviewers)
- Reviews infrastructure and deployment configurations
- Writes findings to review files
- Actionable feedback required

- **CI/CD Pipeline** - Build automation, test coverage, deployment pipelines
- **Docker/Container** - Image security, build efficiency, best practices
- **Environment Config** - Secret management, configuration validation
- **Deployment Safety** - Zero-downtime, rollback, health checks

### Release Validation Reviewers (3 specialized reviewers + 1 checklist)
- Final validation before production release
- Writes findings to review files
- Blocks release if critical issues found

- **Performance** - Widget rebuilds, list performance, memory, network optimization
- **Accessibility** - WCAG compliance, screen reader support, touch targets
- **Localization** - i18n/l10n readiness, string externalization, RTL support
- **Production Checklist** - Comprehensive pre-release validation

### Fixer
- Addresses review comments
- Documents disagreements
- Minimal changes only

### Tester
- Creates comprehensive tests
- TDD for bug fixes
- Tests must pass

### Committer
- Creates proper commit messages
- Stages appropriate files
- Follows the commit format below

## Code Style Requirements

### Flutter/Dart
- Follow official Flutter style guide
- Use `flutter analyze` to validate
- Prefer composition over inheritance
- Use const constructors where possible
- Handle all error cases

### State Management
- Follow spec's designated pattern
- Keep state immutable
- Dispose resources properly

### Testing
- One assertion concept per test
- Descriptive test names
- Mock external dependencies

## Feature Implementation Flow

1. Read feature spec completely
2. Create/modify files in `lib/features/{name}/`
3. Follow MVVM pattern: Page → ViewModel → State
4. Handle all specified edge cases
5. Ensure `flutter analyze` passes

## Bug Fix Flow

1. Read bug spec completely
2. Write failing regression test FIRST
3. Make minimal fix
4. Ensure test passes
5. Document root cause

## Commit Message Format

All commits must follow this format:

```
type: subject

- change 1
- change 2
...
- change n

Task-ID: XXX_name
Signed-off-by: Your Name <your@email.com>
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `chore`: Maintenance, refactoring, config
- `test`: Test-only changes
- `docs`: Documentation changes
- `style`: Formatting, linting
- `perf`: Performance improvements

### Example
```
feat: add user authentication

- Add LoginPage with email/password fields
- Implement form validation
- Create AuthViewModel with state management
- Add error handling for invalid credentials

Task-ID: 001_login
Signed-off-by: Hariesh Varshan <hariesh@example.com>
```

### Git Command
Always use `-s` flag for signoff:
```bash
git commit -s -m "message"
```

### Files to Commit
**DO commit:** `lib/`, `test/`, `ai/decisions/`
**DO NOT commit:** `ai/reviews/`, `ai/session-logs/`, `ai/state.json`, `.env`

## Review Output Format

Reviews must be written to `ai/reviews/{ID}_{type}.md`:

**Frontend Core Reviews:**
- `{ID}_safety.md` - Security findings
- `{ID}_architecture.md` - Architecture findings
- `{ID}_playstore.md` - Play Store compliance
- `{ID}_ui.md` - UI/UX findings
- `{ID}_android.md` - Android-specific findings
- `{ID}_ios.md` - iOS-specific findings
- `{ID}_web.md` - Web-specific findings
- `{ID}_originality.md` - Originality/IP compliance findings

**Frontend Production Reviews:**
- `{ID}_api.md` - API integration findings
- `{ID}_auth.md` - Authentication flow findings
- `{ID}_data.md` - Data layer findings
- `{ID}_production.md` - Production readiness findings

**Backend Reviews:**
- `{ID}_api_design.md` - API design review findings
- `{ID}_backend_security.md` - Backend security findings

**Database Reviews:**
- `{ID}_database_schema.md` - Database schema review findings
- `{ID}_migrations.md` - Migration safety review findings

**DevOps Reviews:**
- `{ID}_cicd.md` - CI/CD pipeline review findings
- `{ID}_docker.md` - Docker/container review findings
- `{ID}_environment.md` - Environment configuration review findings
- `{ID}_deployment.md` - Deployment safety review findings

**Release Validation Reviews:**
- `{ID}_performance.md` - Performance optimization findings
- `{ID}_accessibility.md` - Accessibility/WCAG compliance findings
- `{ID}_localization.md` - Localization readiness findings
- `{ID}_production_checklist.md` - Final production readiness checklist

Each finding must include:
- Problem description
- Why it matters
- Location (file:line)
- Concrete fix

## Decision Documentation

When making assumptions:
1. Check if spec clarifies it
2. If not, choose reasonable default
3. Document in `ai/decisions/{ID}.md`
4. Explain rationale

## Common Commands

```bash
# Create new feature spec
make new-feature ID=001 NAME=login

# Run frontend-only feature workflow
make feature ID=001_login

# Run full-stack feature workflow (backend + frontend)
make fullstack ID=001_login

# Create new bug spec
make new-bug ID=003 NAME=login_crash

# Run bug fix workflow
make bug ID=003_login_crash

# Check code quality
make check

# View current state
make status
```

## Quality Gates

Before completion, ensure:
- [ ] `flutter analyze` - No issues
- [ ] `flutter test` - All pass
- [ ] Reviews addressed - Critical/High fixed
- [ ] Tests created - Coverage appropriate
- [ ] Commit proper - Conventional format

## Important Constraints

1. **No Over-Engineering**: Implement exactly what's specified
2. **No New Packages**: Unless explicitly allowed in spec
3. **No Scope Creep**: Features not in spec are out of scope
4. **No Silent Failures**: Handle and report all errors
5. **No Skipping Steps**: Follow orchestration flow

## Play Store Readiness

All code must be Play Store compliant:
- Target recent Android SDK
- Handle permissions properly
- No policy violations
- Privacy-respecting
- Performant and stable
