# TPM API

Spring Boot service for the Transformation Project Ministries member app, the
branch-leader portal and the pastor's office.

This is the replacement for the Node/Express/Prisma service in [`../backend`](../backend).
**Both exist right now on purpose** — `backend/` is still serving the live
website, and it stays until the port below is finished and the frontend is
repointed. Nothing has been deleted.

## Stack

- **Java 21**, Spring Boot 4.1
- **Postgres** (Neon), schema owned by **Flyway**
- **JPA/Hibernate** with `ddl-auto: validate` — Hibernate never writes DDL
- **JWT** bearer tokens (jjwt), BCrypt password hashing
- Deployed on **Railway**, same as the service it replaces

## Port status

Honest accounting of what is and is not done.

### Done

| Method | Path | Access | Notes |
|--------|------|--------|-------|
| POST | `/api/auth/register` | public | Role comes from the invite code, never the body |
| POST | `/api/auth/login` | public | Constant-time failure for unknown email vs bad password |
| GET | `/api/auth/me` | signed in | Re-reads the user, so role changes apply next launch |
| GET | `/actuator/health` | public | Railway healthcheck |

Also complete: the full Flyway schema (12 tables), all JPA entities, all 12
repositories including the branch-scoped queries, the JWT filter chain, CORS,
and the global error shape.

### Not yet ported

These exist in the Node service and still need writing here. The repositories
and scoping they need are already in place; what is missing is the service and
controller layer.

- `/api/members` — list, search, create, update, delete (leader/admin)
- `/api/reports` — submit and list, with the offline-safe upsert on
  (branch, meeting, date)
- `/api/statistics` — the aggregates behind the dashboards
- `/api/profile-requests` — raise, review queue, approve/reject
- `/api/users` — admin account management
- `/api/announcements`, `/api/leaders`, `/api/lookups` — read and admin writes

New for the mobile app, in the schema but with no endpoints yet:

- `/api/branches`, `/api/events`, `/api/media`, `/api/books`

### Cutover checklist

1. Finish the endpoints above.
2. Point `frontend/` at the new base URL (it currently calls the Node API).
3. Run both against the same database and compare responses.
4. Switch the Railway service, then delete `backend/`.

## Local setup

```bash
cd api
cp .env.example .env    # then fill it in
./mvnw spring-boot:run  # http://localhost:8080
```

Required environment — none of these have defaults, deliberately:

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | Pooled JDBC URL, e.g. `jdbc:postgresql://…-pooler…/tpm?sslmode=require` |
| `DIRECT_DATABASE_URL` | Direct (non-pooled) URL — Flyway uses this; migrations take locks a pooler mishandles |
| `DATABASE_USER` / `DATABASE_PASSWORD` | Database credentials |
| `JWT_SECRET` | At least 32 bytes. `openssl rand -base64 48` |
| `CORS_ORIGINS` | Comma-separated browser origins for the website |

The app refuses to start without `DATABASE_URL` or `JWT_SECRET`. That is the
point: a fallback signing key is how one reaches production.

## Database

Flyway owns the schema; Hibernate is set to `validate` so an entity that drifts
from a migration fails at boot rather than at 2am.

- `V1__initial_schema.sql` — the twelve tables
- `V2__reference_data.sql` — branches and lookup lists

Migrations are never edited once merged; add a new `V3__…`.

**No users or invite codes are seeded.** The first admin and the real invite
codes are created by an operator — secrets do not belong in a file committed to
the repo. To create the first admin, insert a row with a BCrypt hash you
generate yourself, then use the app to create everyone else.

## Tests

```bash
./mvnw test
```

26 tests, all unit or web-slice: no Docker and no database required, so anyone
who can clone the repo can run them. Testcontainers was considered and dropped
for exactly that reason — tests the team cannot run are worse than none.

The trade-off is that the migrations themselves are not exercised here. They
should be run against a real Postgres in CI before deploy.

What is covered: JWT round-trip, forged/expired/foreign-issuer token rejection,
branch scoping for each role, and registration/login including invite-code
redemption, role escalation attempts, and constant-time login failure.

## Deployment

Railway, with the service's **root directory** set to `api`. `railway.json`
runs `flyway migrate` before the app starts, so the schema is applied on every
deploy.
