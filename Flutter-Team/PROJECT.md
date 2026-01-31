# PROJECT.md - Project-Specific Instructions

> **This file is for YOUR project-specific instructions. It is NOT synced when updating the template.**

## About This File

- `CLAUDE.md` = Framework instructions (synced from template)
- `PROJECT.md` = Your project-specific instructions (never synced)

Claude will read both files when starting a session.

---

## Project Information

**App Name:** [Your App Name]
**Package:** [com.yourcompany.appname]
**Description:** [Brief description of what this app does]

---

## Build Instructions

```bash
# Development build
cd app && flutter run

# Release build
cd app && flutter build apk --release

# Run tests
cd app && flutter test
```

### Environment Setup

1. [List any required environment setup]
2. [API keys needed, etc.]

### Dependencies

[List any external dependencies or services]

---

## Architecture Decisions

[Document your project's architecture choices]

- **State Management:** [e.g., Provider, Riverpod, BLoC]
- **Navigation:** [e.g., GoRouter, Navigator 2.0]
- **API Layer:** [e.g., Dio, http]
- **Local Storage:** [e.g., Hive, SharedPreferences]

---

## Project-Specific Conventions

### Naming Conventions

[Any naming conventions specific to this project]

### Folder Structure

```
app/lib/
├── features/       # Feature modules
├── core/           # Shared code
├── models/         # Data models
└── services/       # API services
```

### Code Patterns

[Any patterns specific to this project]

---

## External Services

| Service | Purpose | Docs |
|---------|---------|------|
| [Service 1] | [Purpose] | [Link] |
| [Service 2] | [Purpose] | [Link] |

---

## Known Issues / Gotchas

[Document any quirks or issues Claude should know about]

---

## Team Contacts

| Role | Name | Contact |
|------|------|---------|
| Lead | [Name] | [Email] |

---

## Quick Reference

[Add any quick reference info that helps during development]
