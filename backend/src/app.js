import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { env, isProd } from './config/env.js';
import { notFoundHandler, errorHandler } from './middleware/errorHandler.js';

import authRoutes from './routes/auth.routes.js';
import usersRoutes from './routes/users.routes.js';
import membersRoutes from './routes/members.routes.js';
import reportsRoutes from './routes/reports.routes.js';
import profileRequestsRoutes from './routes/profileRequests.routes.js';
import statisticsRoutes from './routes/statistics.routes.js';
import announcementsRoutes from './routes/announcements.routes.js';
import leadersRoutes from './routes/leaders.routes.js';
import lookupsRoutes from './routes/lookups.routes.js';

export function createApp() {
  const app = express();

  app.set('trust proxy', 1); // behind Railway's proxy
  app.use(helmet());
  app.use(express.json({ limit: '1mb' }));
  if (!isProd) app.use(morgan('dev'));

  // CORS: allow only the configured browser origins.
  app.use(
    cors({
      origin(origin, cb) {
        // Allow same-origin/non-browser requests (no Origin header) and whitelisted origins.
        if (!origin || env.corsOrigins.includes(origin)) return cb(null, true);
        cb(new Error(`Origin ${origin} not allowed by CORS`));
      },
      credentials: true,
    })
  );

  // Tighter rate limit on auth to slow brute-force / spam registration.
  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many attempts. Please try again later.' },
  });

  app.get('/health', (_req, res) => res.json({ ok: true, service: 'tpm-api' }));

  app.use('/api/auth', authLimiter, authRoutes);
  app.use('/api/users', usersRoutes);
  app.use('/api/members', membersRoutes);
  app.use('/api/reports', reportsRoutes);
  app.use('/api/profile-requests', profileRequestsRoutes);
  app.use('/api/statistics', statisticsRoutes);
  app.use('/api/announcements', announcementsRoutes);
  app.use('/api/leaders', leadersRoutes);
  app.use('/api/lookups', lookupsRoutes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
