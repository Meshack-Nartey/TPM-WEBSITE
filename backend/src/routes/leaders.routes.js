import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/leaders  — leadership directory (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const leaders = await prisma.leader.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ leaders });
  })
);

const schema = z.object({
  name: z.string().trim().min(1),
  title: z.string().trim().optional().default(''),
  branch: z.string().trim().optional().default(''),
  fellowship: z.string().trim().optional().default(''),
  quote: z.string().trim().optional().default(''),
  bio: z.string().trim().optional().default(''),
  highlights: z.array(z.string()).optional().default([]),
  photo: z.string().trim().optional().default(''),
  email: z.string().trim().optional().default(''),
  phone: z.string().trim().optional().default(''),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const leader = await prisma.leader.create({ data: req.body });
    res.status(201).json({ leader });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const leader = await prisma.leader.update({ where: { id: req.params.id }, data: req.body });
    res.json({ leader });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.leader.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
