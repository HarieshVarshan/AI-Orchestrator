# Project Setup Guide

This guide explains how to use the Flutter-Android-Team framework to start a new app project.

## Overview

The **Flutter-Android-Team** folder is a reusable AI orchestration framework. There are two ways to start a new project:

| Method | When to Use |
|--------|-------------|
| **Clone from Remote** | Template is hosted on GitHub/GitLab |
| **Local Copy** | Template is on your local machine |

---

## Option A: Clone from Remote (Recommended)

Use this when the template is hosted on a remote repository.

### 1. Clone the Template

```bash
# Clone the template repository
git clone https://github.com/username/Flutter-Android-Team.git MyAwesomeApp

# Navigate to your new project
cd MyAwesomeApp
```

### 2. Disconnect from Template Repository (CRITICAL!)

You must remove the template's git history to start fresh:

```bash
# Remove the template's git folder
rm -rf .git

# Verify it's removed
ls -la | grep .git  # Should show nothing
```

> **Why?** If you skip this step, you'll accidentally push to the template repo instead of your own!

### 3. Set Up .gitignore (CRITICAL - Do This Before `git init`)

```bash
# Copy the template gitignore
cp templates/gitignore.template .gitignore
```

This protects:
- AI orchestration files (reviews, session logs, state)
- Reference materials (cloned repos, inspiration)
- Environment variables and secrets

### 4. Initialize Fresh Git Repository

```bash
# Initialize new git repo
git init

# Set your git config (if not global)
git config --local user.name "Your Name"
git config --local user.email "your@email.com"

# Make initial commit
git add .
git commit -s -m "chore: initialize project from Flutter-Android-Team framework

- Set up AI orchestration structure
- Configure gitignore for AI files and secrets
- Add project documentation

Task-ID: 000_init"
```

### 5. Connect to Your Own Remote Repository

```bash
# Create a repo on GitHub/GitLab first, then:
git remote add origin https://github.com/yourusername/MyAwesomeApp.git

# Push to your repo
git push -u origin master
```

### 6. Create Your Flutter App

```bash
# Create Flutter app with your organization (recommended)
make init-app ORG=com.yourcompany

# Or without organization (uses default com.example)
make init-app
```

---

## Option B: Local Copy

Use this when the template is already on your local machine.

### 1. Copy the Framework

```bash
# Copy the entire framework folder
cp -r Flutter-Android-Team ~/projects/MyAwesomeApp

# Navigate to your new project
cd ~/projects/MyAwesomeApp
```

### 2. Set Up .gitignore (CRITICAL - Do This Before `git init`)

```bash
# Copy the template gitignore
cp templates/gitignore.template .gitignore
```

### 3. Initialize Git Repository

```bash
# Initialize git
git init

# Set your git config (if not global)
git config --local user.name "Your Name"
git config --local user.email "your@email.com"

# Make initial commit
git add .
git commit -s -m "chore: initialize project from Flutter-Android-Team framework

- Set up AI orchestration structure
- Configure gitignore for AI files and secrets
- Add project documentation

Task-ID: 000_init"
```

### 4. Connect to Remote (Optional)

```bash
git remote add origin https://github.com/yourusername/MyAwesomeApp.git
git push -u origin master
```

### 5. Create Your Flutter App

```bash
make init-app ORG=com.yourcompany
```

---

### 5. Verify .gitignore is Working

```bash
# These should NOT appear in git status
touch ai/reviews/test.md
touch ai/session-logs/test.md
touch .env

git status
# The above files should be ignored
```

## What Gets Committed vs Ignored

### ✅ DO Commit (Your App Repository)

| Path | Purpose |
|------|---------|
| `app/lib/` | Application source code |
| `app/test/` | Test files |
| `ai/features/` | Feature specifications |
| `ai/bugs/` | Bug specifications |
| `ai/decisions/` | AI decision documentation |
| `ai/prompts/` | Agent role prompts |
| `docs/` | Project documentation |
| `tools/` | Orchestration scripts |
| `Makefile` | Build commands |
| `CLAUDE.md` | AI guidelines |

### ❌ DO NOT Commit (Ignored)

| Path | Reason |
|------|--------|
| `ai/reviews/` | Internal review findings |
| `ai/session-logs/` | Development session records |
| `ai/state.json` | Orchestration state |
| `ai/changelogs/` | Internal changelog drafts |
| `reference/*` | Reference materials, examples, inspiration (IP protection) |
| `.env`, `.env.*` | Environment secrets |
| `*.keystore`, `*.jks` | Signing keys |
| `google-services.json` | Firebase config with API keys |
| `key.properties` | Android signing config |

## Environment Variables

Create a `.env` file (already in `.gitignore`):

```bash
# .env - NEVER COMMIT THIS FILE

# API Keys
API_BASE_URL=https://api.yourservice.com
API_KEY=your_api_key_here

# Firebase (if not using google-services.json)
FIREBASE_API_KEY=xxx
FIREBASE_PROJECT_ID=xxx

# Other secrets
SENTRY_DSN=xxx
```

Use a package like `flutter_dotenv` to load these in your app.

## Android Signing Setup

For release builds, create `app/android/key.properties` (already in `.gitignore`):

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/your/keystore.jks
```

## Project Structure After Setup

```
MyAwesomeApp/
├── .git/                   # Git repository
├── .gitignore              # Configured to ignore AI/secrets
├── ai/
│   ├── features/           # ✅ Committed - Feature specs
│   ├── bugs/               # ✅ Committed - Bug specs
│   ├── reviews/            # ❌ Ignored - Review findings
│   ├── decisions/          # ✅ Committed - Decisions
│   ├── prompts/            # ✅ Committed - Agent prompts
│   ├── session-logs/       # ❌ Ignored - Session logs
│   └── state.json          # ❌ Ignored - State file
├── app/                    # ✅ Committed - Flutter app
│   ├── lib/
│   ├── test/
│   ├── android/
│   └── pubspec.yaml
├── reference/              # ❌ Ignored - Reference materials
│   └── .gitkeep            # ✅ Committed - Keeps folder structure
├── docs/                   # ✅ Committed - Documentation
├── tools/                  # ✅ Committed - Scripts
├── templates/              # ✅ Committed - Templates
├── .env                    # ❌ Ignored - Secrets
├── Makefile                # ✅ Committed
└── CLAUDE.md               # ✅ Committed
```

## Sharing Secrets with Team

For team projects, share secrets securely:

1. **Use a secrets manager** (1Password, AWS Secrets Manager, etc.)
2. **Create `.env.example`** with placeholder values (this CAN be committed):
   ```bash
   # .env.example - Template for environment variables
   API_BASE_URL=https://api.example.com
   API_KEY=your_api_key_here
   ```
3. **Document in onboarding** how team members get real values

## Troubleshooting

### AI files showing in git status
```bash
# Make sure .gitignore exists and has correct entries
cat .gitignore | grep "ai/reviews"

# If files were already tracked, remove them from git
git rm -r --cached ai/reviews/
git rm -r --cached ai/session-logs/
git rm --cached ai/state.json
```

### Accidentally committed secrets
```bash
# Remove from history (if not pushed yet)
git reset HEAD~1

# If already pushed, you need to rotate the secrets immediately!
# Then use git filter-branch or BFG Repo-Cleaner to remove from history
```

## Syncing Template Updates

If you created your project from the template and the template gets updated, you can sync the framework updates without losing your project work.

### What Gets Synced (Framework Files)
- `tools/` - Orchestration scripts
- `ai/prompts/` - Agent prompts
- `templates/` - Project templates
- `Makefile` - Build commands
- `CLAUDE.md` - AI guidelines (framework instructions)

### What Is Preserved (Your Project Files)
- `PROJECT.md` - **Your project-specific instructions for Claude**
- `ai/features/` - Your feature specs
- `ai/bugs/` - Your bug specs
- `ai/reviews/` - Generated reviews
- `ai/session-logs/` - Session logs
- `ai/decisions/` - Your decisions
- `app/` - Your Flutter app
- `reference/` - Your reference materials
- `docs/` - Your project documentation
- `.gitignore` - Your gitignore
- `CHANGELOG.md` - Your changelog

### First Time Setup

```bash
# Add template as a remote (run once)
make sync-template URL=https://github.com/username/Flutter-Android-Team.git
```

### Check for Updates

```bash
# See what updates are available
make check-template
```

### Apply Updates

```bash
# Sync framework updates from template
make sync-template

# Review staged changes
git diff --cached

# If happy, commit
git commit -s -m "chore: sync framework updates from template

- Update orchestration scripts
- Update agent prompts

Task-ID: xxx_sync"

# If not happy, undo
git checkout HEAD -- .
```

### List Sync Paths

```bash
# See what files would be synced vs preserved
make sync-list
```

---

## Checklist Before First Commit

### If Cloned from Remote
- [ ] Cloned template repo (`git clone ... MyAppName`)
- [ ] **Removed `.git` folder** (`rm -rf .git`) ⚠️ CRITICAL
- [ ] Copied `templates/gitignore.template` to `.gitignore`
- [ ] Initialized fresh git (`git init`)
- [ ] Set local git config (name, email)
- [ ] Made initial commit with `-s` signoff
- [ ] Added your own remote (`git remote add origin ...`)
- [ ] Pushed to your repo (`git push -u origin master`)
- [ ] Created Flutter app (`make init-app ORG=com.yourcompany`)

### If Local Copy
- [ ] Copied framework to new folder
- [ ] Copied `templates/gitignore.template` to `.gitignore`
- [ ] Initialized git (`git init`)
- [ ] Set local git config (name, email)
- [ ] Made initial commit with `-s` signoff
- [ ] Created Flutter app (`make init-app ORG=com.yourcompany`)
