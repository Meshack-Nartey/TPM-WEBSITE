import { verifyToken } from '../lib/jwt.js';
import { prisma } from '../lib/prisma.js';
import { unauthorized } from '../lib/errors.js';

// Verifies the Bearer token and loads the fresh user record onto req.user.
// Loading from the DB (rather than trusting the token payload) means a
// deactivated user or a role change takes effect immediately.
export async function authenticate(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw unauthorized('Missing authentication token');

    let payload;
    try {
      payload = verifyToken(token);
    } catch {
      throw unauthorized('Invalid or expired token');
    }

    const user = await prisma.user.findUnique({ where: { id: payload.sub } });
    if (!user || !user.active) throw unauthorized('Account not found or deactivated');

    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
}
