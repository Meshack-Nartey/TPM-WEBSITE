import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/worker-groups — the "Get Involved" descriptions (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const workerGroups = await prisma.workerGroupInfo.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ workerGroups });
  })
);

const schema = z.object({
  name: z.string().trim().min(1),
  photo: z.string().trim().min(1),
  blurb: z.string().trim().min(1),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const workerGroup = await prisma.workerGroupInfo.create({ data: req.body });
    res.status(201).json({ workerGroup });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const workerGroup = await prisma.workerGroupInfo.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ workerGroup });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.workerGroupInfo.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
