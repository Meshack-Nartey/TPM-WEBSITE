# Transformation Project Ministries

Monorepo for the TPM platform.

```
.
├── frontend/   Public website + member/leader portal (static HTML/CSS/JS, deployed on Netlify)
├── backend/    REST API — Node/Express + Prisma + PostgreSQL (deployed on Railway)
└── mobile/     Mobile apps (planned)
```

## frontend/
Static site (no build step). Deployed on Netlify; this repo's root `netlify.toml`
publishes the `frontend/` folder. The leader/member portal (`frontend/leader-portal.html`)
talks to the backend API — set its `API_BASE` to the deployed backend URL.

## backend/
Custom API for the portal: JWT auth, role- and branch-scoped access, church
records, members, statistics, and admin-managed content. See
[backend/README.md](backend/README.md) for setup and deployment.

## Deployments
- **Website:** Netlify → publishes `frontend/`
- **API:** Railway → runs `backend/`
