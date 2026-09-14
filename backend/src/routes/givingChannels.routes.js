import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/giving-channels — the real MoMo/bank accounts (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const channels = await prisma.givingChannel.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ channels });
  })
);

const schema = z.object({
  name: z.string().trim().min(1),
  logo: z.string().trim().min(1),
  accountName: z.string().trim().min(1),
  number: z.string().trim().min(1),
  numberLabel: z.string().trim().min(1),
  isBank: z.boolean().optional().default(false),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const channel = await prisma.givingChannel.create({ data: req.body });
    res.status(201).json({ channel });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const channel = await prisma.givingChannel.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ channel });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.givingChannel.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
