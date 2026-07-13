import { forbidden } from '../lib/errors.js';

// Route guard: allow only the listed roles. Use after `authenticate`.
// Example: router.get('/users', authenticate, requireRole('ADMIN'), handler)
export function requireRole(...roles) {
  return (req, _res, next) => {
    if (!req.user) return next(forbidden('Not authenticated'));
    if (!roles.includes(req.user.role)) {
      return next(forbidden('You do not have access to this resource'));
    }
    next();
  };
}
