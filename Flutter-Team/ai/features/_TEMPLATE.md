# Feature ID: {{ID}}
## Name: {{FEATURE_NAME}}

### Objective
<!-- Clear, single-sentence description of what this feature achieves -->

---

## Frontend (Flutter App)

### UI Requirements
<!-- List all UI elements needed -->
-
-
-

### Functional Requirements
<!-- List all behaviors and logic -->
-
-
-

### State Management
<!-- Specify state management approach -->
- Pattern: (ChangeNotifier / Riverpod / BLoC / etc.)
- External packages allowed: (Yes/No - list if yes)

### Navigation
<!-- How users reach this feature and where they can go from here -->
- Entry point:
- Exit points:

### Error Handling
<!-- Expected error states and how to handle them -->
-
-

### Accessibility Requirements
<!-- A11y considerations -->
- Screen reader support: (Yes/No)
- Minimum touch targets: 48x48
- Color contrast requirements: WCAG AA

### Android-Specific Requirements
<!-- Permissions, lifecycle, etc. -->
- Permissions needed:
- Lifecycle considerations:
- Deep link support: (Yes/No)

---

## Backend (API)

### API Endpoints Required
<!-- List all endpoints this feature needs -->

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | /api/v1/... | ... | Yes/No |
| POST | /api/v1/... | ... | Yes/No |

### Request/Response Schemas

#### Endpoint 1: [METHOD] /api/v1/...
**Request:**
```json
{
  "field": "type"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": { }
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": { "code": "ERROR_CODE", "message": "..." }
}
```

### Data Models
<!-- Database models/tables needed -->
-
-

### Business Logic
<!-- Backend business rules and validations -->
-
-

### Authentication & Authorization
<!-- Auth requirements for this feature -->
- Authentication: (Required / Optional / None)
- Authorization: (List roles/permissions)

---

## Database

### Database Type
<!-- Select one -->
- Type: (PostgreSQL / MySQL / MongoDB / Firestore / Supabase / Other)
- ORM/Client: (Prisma / TypeORM / Mongoose / Knex / etc.)

### Schema Design

#### Tables/Collections Required
<!-- List all database entities needed for this feature -->

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| users | ... | id, email, password_hash, created_at |
| ... | ... | ... |

#### Entity Relationships
<!-- Describe relationships between entities -->
```
[Entity1] 1----* [Entity2]
```

### Schema Definitions
<!-- Detailed schema for each new/modified table -->

#### Table: table_name
```sql
CREATE TABLE table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- fields here
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Indexes Required
<!-- List indexes needed for query performance -->
| Table | Index | Columns | Type |
|-------|-------|---------|------|
| ... | idx_... | ... | B-tree/GIN/etc. |

### Migrations
<!-- Migration requirements and considerations -->
- New tables: (List)
- Modified tables: (List)
- Data migrations: (Describe if any)
- Backwards compatible: (Yes/No)
- Estimated migration time: (For large tables)

### Data Seeding
<!-- Initial data requirements -->
- Seed data needed: (Yes/No)
- Seed data description: (If yes)

---

## Integration

### Data Flow
<!-- How data flows between frontend and backend -->
```
User Action → Flutter UI → ViewModel → Repository → API Client
                                                      ↓
                                              Backend API
                                                      ↓
                                              Database
```

### Offline Support
<!-- How this feature works offline -->
- Offline capable: (Yes / No / Partial)
- Sync strategy: (Describe if applicable)

### Caching Strategy
<!-- How data is cached -->
- Cache duration:
- Cache invalidation:

---

## Out of Scope
<!-- Explicitly state what this feature does NOT include -->
-
-

## Acceptance Criteria

### Frontend
- [ ] App builds successfully (`flutter build apk`)
- [ ] `flutter analyze` passes with no issues
- [ ] All widget tests pass
- [ ] UI renders correctly on Android emulator
- [ ] Feature works as specified

### Backend
- [ ] All endpoints implemented
- [ ] API tests pass
- [ ] Proper error handling
- [ ] Authentication working

### Database
- [ ] Schema designed and documented
- [ ] Migrations created and tested
- [ ] Migrations are reversible (down migrations work)
- [ ] Indexes created for query performance
- [ ] Seed data applied (if needed)

### Integration
- [ ] Frontend successfully calls backend
- [ ] Error states handled in UI
- [ ] Loading states shown
- [ ] Offline behavior works (if applicable)

## Dependencies
<!-- Other features or components this depends on -->
-

## Notes
<!-- Any additional context or references -->
