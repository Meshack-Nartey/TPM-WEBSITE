import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/branches — the public branch directory (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const branches = await prisma.branchInfo.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ branches });
  })
);

const schema = z.object({
  name: z.string().trim().min(1),
  region: z.string().trim().min(1),
  address: z.string().trim().min(1),
  phone: z.string().trim().optional().default(''),
  email: z.string().trim().optional().default(''),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const branch = await prisma.branchInfo.create({ data: req.body });
    res.status(201).json({ branch });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const branch = await prisma.branchInfo.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ branch });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.branchInfo.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
