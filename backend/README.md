# TPM API

Custom backend for the Transformation Project Ministries leader/member portal.
Replaces the previous Firebase integration with **Node + Express + Prisma + Postgres (Neon)**, deployed on **Railway**.

## Stack

- **Runtime:** Node 18+, Express (ES modules, no build step)
- **DB:** PostgreSQL (Neon) via Prisma ORM
- **Auth:** JWT (Bearer tokens), bcrypt password hashing
- **Security:** helmet, CORS allow-list, rate-limited auth, zod validation
- **Roles:** `MEMBER`, `LEADER`, `ADMIN` — enforced server-side on every route

## Local setup

```bash
cd backend
cp .env.example .env          # then fill in DATABASE_URL, DIRECT_URL, JWT_SECRET
npm install                   # also runs `prisma generate`
npm run prisma:migrate        # creates tables (dev migration)
npm run seed                  # reference lists, invite codes, leaders, announcements, first admin
npm run dev                   # http://localhost:4000
```

Generate a JWT secret:

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

## Database (Neon)

1. Create a project at https://neon.tech and a database named `tpm`.
2. Copy **two** connection strings into `.env`:
   - `DATABASE_URL` → the **pooled** string (host contains `-pooler`), used by the app at runtime.
   - `DIRECT_URL` → the **direct** string, used by Prisma for migrations.
   Both must end with `?sslmode=require`.

## Deploy to Railway

1. This lives in the monorepo under `backend/`. On Railway, set the service's
   **root directory** to `backend` so it builds/deploys only this folder.
2. On https://railway.app → **New Project → Deploy from GitHub repo** → pick the repo.
3. Add environment variables (from your `.env`): `DATABASE_URL`, `DIRECT_URL`, `JWT_SECRET`,
   `JWT_EXPIRES_IN`, `NODE_ENV=production`, `CORS_ORIGINS`, and the `SEED_*` values.
4. Railway auto-runs `npm install` → `npm start`. The `railway.json` start command runs
   `prisma migrate deploy` first, so the schema is applied on every deploy.
5. After the first deploy, run the seed once from the Railway shell: `npm run seed`.
6. Copy the public Railway URL (e.g. `https://tpm-api-production.up.railway.app`) — this is
   your API base URL for the frontend.

> Set `CORS_ORIGINS` to include your Netlify site, e.g.
> `https://transformationpm.netlify.app` (comma-separate multiple origins).

## API reference

Base path: `/api`. All responses are JSON. Protected routes need `Authorization: Bearer <token>`.

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/auth/register` | public | Create account (leader/admin need `inviteCode`) |
| POST | `/auth/login` | public | Returns `{ token, user }` |
| GET  | `/auth/me` | any | Current user from token |
| GET  | `/lookups` | public | Reference lists (branches, departments, …) |
| GET  | `/announcements` | any | Active announcements |
| GET  | `/leaders` | any | Leadership directory |
| POST | `/profile-requests` | any | Request a profile-field change |
| GET  | `/members` | leader/admin | List/search church members |
| POST | `/members` | leader/admin | Register a member |
| PATCH/DELETE | `/members/:id` | leader/admin | Edit / remove a member |
| GET  | `/reports` | leader/admin | Records, filter by `type`, `branch`, `from`, `to` |
| POST | `/reports` | leader/admin | Submit a record |
| DELETE | `/reports/:id` | leader/admin | Remove a record |
| GET  | `/statistics` | leader/admin | Aggregated stats + chart data |
| GET  | `/profile-requests` | admin | Review queue (filter by `status`) |
| PATCH | `/profile-requests/:id` | admin | Approve/reject (approve applies the change) |
| GET  | `/users` | admin | All portal accounts |
| PATCH/DELETE | `/users/:id` | admin | Edit role/status / remove |
| POST/DELETE | `/announcements`,`/leaders`,`/lookups` | admin | Manage content |

`GET /health` → `{ ok: true }` (used by Railway healthcheck).

## Notes

- **Invite codes** live in the `InviteCode` table (seeded from `SEED_LEADER_CODE` /
  `SEED_ADMIN_CODE`) and are validated **server-side** — the old client-side codes are gone.
- **Statistics** are computed from real submitted `reports`, not mock data.
- Passwords are hashed with bcrypt; the hash is never returned to the client.
- The frontend (`leader-portal.html`) still needs its Firebase `Auth`/`DB` layers swapped
  to call these endpoints — that's the next step.
