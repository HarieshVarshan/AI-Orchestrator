# Backend

This folder contains the backend/API server for the application.

## Technology Choice

Choose your backend technology and initialize it here:

### Option 1: Node.js (Recommended for most Flutter apps)
```bash
cd backend
npm init -y
npm install express cors helmet dotenv
npm install -D typescript @types/node @types/express ts-node nodemon
```

### Option 2: Python (FastAPI)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install fastapi uvicorn sqlalchemy pydantic
```

### Option 3: Firebase Functions (Serverless)
```bash
cd backend
firebase init functions
```

### Option 4: Supabase (Managed Backend)
Use Supabase dashboard - no code needed here initially.

## Folder Structure

```
backend/
├── src/
│   ├── controllers/    # Request handlers
│   ├── services/       # Business logic
│   ├── models/         # Data models
│   ├── middleware/     # Auth, logging, etc.
│   ├── routes/         # API route definitions
│   ├── utils/          # Helper functions
│   └── config/         # Configuration
├── tests/
│   ├── unit/           # Unit tests
│   └── integration/    # Integration tests
├── docs/
│   └── api.md          # API documentation
├── .env.example        # Environment template
├── Dockerfile          # Container config
└── README.md           # This file
```

## Environment Variables

Create a `.env` file (never commit this):

```bash
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Auth
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# External Services
FIREBASE_PROJECT_ID=xxx
AWS_ACCESS_KEY_ID=xxx
```

## API Design Guidelines

1. **RESTful conventions**
   - GET /users - List users
   - GET /users/:id - Get single user
   - POST /users - Create user
   - PUT /users/:id - Update user
   - DELETE /users/:id - Delete user

2. **Response format**
   ```json
   {
     "success": true,
     "data": { ... },
     "message": "Operation successful"
   }
   ```

3. **Error format**
   ```json
   {
     "success": false,
     "error": {
       "code": "VALIDATION_ERROR",
       "message": "Email is required",
       "details": { ... }
     }
   }
   ```

4. **Versioning**
   - Use URL versioning: `/api/v1/users`

## Running the Backend

```bash
# Development
npm run dev      # or: uvicorn main:app --reload

# Production
npm start        # or: uvicorn main:app

# Tests
npm test         # or: pytest
```

## Integration with Flutter App

Update `app/` configuration to point to this backend:

```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
```
