import { ApiError } from '../lib/errors.js';
import { isProd } from '../config/env.js';

export function notFoundHandler(_req, res) {
  res.status(404).json({ error: 'Route not found' });
}

// Central error handler. Must have 4 args for Express to treat it as such.
export function errorHandler(err, _req, res, _next) {
  // Known, intentional errors
  if (err instanceof ApiError) {
    return res.status(err.status).json({ error: err.message, details: err.details });
  }

  // Prisma unique-constraint violation
  if (err.code === 'P2002') {
    return res.status(409).json({ error: 'A record with that value already exists.' });
  }
  // Prisma record-not-found (e.g. update/delete of missing row)
  if (err.code === 'P2025') {
    return res.status(404).json({ error: 'Record not found.' });
  }

  if (!isProd) console.error(err);
  res.status(500).json({ error: 'Internal server error' });
}
