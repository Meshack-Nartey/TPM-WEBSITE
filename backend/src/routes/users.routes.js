import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { publicUser } from '../lib/serialize.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// All user-management routes are admin-only.
router.use(authenticate, requireRole('ADMIN'));

// GET /api/users
router.get(
  '/',
  asyncHandler(async (_req, res) => {
    const users = await prisma.user.findMany({ orderBy: { createdAt: 'desc' } });
    res.json({ users: users.map(publicUser) });
  })
);

const updateSchema = z.object({
  firstName: z.string().trim().min(1).optional(),
  lastName: z.string().trim().min(1).optional(),
  phone: z.string().trim().optional(),
  branch: z.string().trim().optional(),
  department: z.string().trim().optional(),
  fellowship: z.string().trim().optional(),
  role: z.enum(['MEMBER', 'LEADER', 'ADMIN']).optional(),
  active: z.boolean().optional(),
});

// PATCH /api/users/:id
router.patch(
  '/:id',
  validateBody(updateSchema),
  asyncHandler(async (req, res) => {
    const data = { ...req.body };
    if (data.firstName || data.lastName) {
      const current = await prisma.user.findUnique({ where: { id: req.params.id } });
      const first = data.firstName || current?.firstName || '';
      const last = data.lastName || current?.lastName || '';
      data.fullName = `${first} ${last}`.trim();
    }
    const user = await prisma.user.update({ where: { id: req.params.id }, data });
    res.json({ user: publicUser(user) });
  })
);

// DELETE /api/users/:id
router.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    await prisma.user.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
